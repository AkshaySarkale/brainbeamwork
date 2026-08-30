import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopora/data/models/cart_item_model.dart';
import 'package:shopora/data/models/product_model.dart';
import 'package:shopora/data/repositories/cart_repository.dart';
import 'package:shopora/core/utils/app_utils.dart';
import 'package:shopora/features/auth/auth_controller.dart';

class CartController extends GetxController {
  final CartRepository _cartRepo = Get.find<CartRepository>();

  final RxList<CartItemModel> cartItems = <CartItemModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;
  final RxString errorMessage = ''.obs;

  final TextEditingController promoController = TextEditingController();
  final RxString appliedPromoCode = ''.obs;

  final List<Map<String, dynamic>> availableOffers = [
    {'code': 'FLAT50', 'title': 'Flat 50% Off', 'description': 'Get 50% off on your entire cart.'},
    {'code': 'SAVE20', 'title': 'Save ₹20', 'description': 'Get a flat ₹20 discount.'},
  ];

  @override
  void onInit() {
    super.onInit();
    // Re-fetch cart when authentication state changes
    ever(Get.find<AuthController>().firebaseUser, (user) {
      if (user != null) {
        fetchCart();
      } else {
        cartItems.clear(); // Clear cart state on logout
      }
    });

    if (Get.find<AuthController>().firebaseUser.value != null) {
      fetchCart();
    }
  }

  int get totalItemCount =>
      cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  double get discountAmount {
    final code = appliedPromoCode.value.toUpperCase();
    if (code == 'FLAT50') return subtotal * 0.5;
    if (code == 'SAVE20') return subtotal > 20 ? 20.0 : subtotal;
    return 0.0;
  }

  double get deliveryFee => subtotal > 0 && subtotal < 500 ? 50.0 : 0.0;

  double get total => subtotal - discountAmount + deliveryFee;

  void applyPromoCode([String? specificCode]) {
    final code = (specificCode ?? promoController.text).trim().toUpperCase();
    
    if (code.isEmpty) {
      AppUtils.showSnackbar('Error', 'Please enter a promo code.', isError: true);
      return;
    }
    
    if (appliedPromoCode.value.toUpperCase() == code) {
      AppUtils.showSnackbar('Info', 'Promo code "$code" is already applied.');
      return;
    }

    if (code == 'FLAT50' || code == 'SAVE20') {
      appliedPromoCode.value = code;
      promoController.text = code;
      Get.back(result: true); // close bottom sheet if open
      AppUtils.showSnackbar('Success', 'Promo code "$code" applied successfully!');
    } else {
      AppUtils.showSnackbar('Error', 'Invalid promo code.', isError: true);
    }
  }

  void removePromoCode() {
    appliedPromoCode.value = '';
    promoController.clear();
    AppUtils.showSnackbar('Info', 'Promo code removed.');
  }

  Future<void> fetchCart() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final items = await _cartRepo.getCartItems();
      cartItems.assignAll(items);
    } catch (e) {
      errorMessage.value = 'Failed to load cart: $e';
      AppUtils.showSnackbar(
        'Error',
        'Failed to load cart data.',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addToCart(ProductModel product, {bool showSuccessSnackbar = true}) async {
    if (Get.find<AuthController>().firebaseUser.value == null) {
      AppUtils.showSnackbar(
        'Authentication Required',
        'Please login to add items to cart.',
        isError: true,
      );
      return false;
    }

    try {
      isUpdating.value = true;
      final existingIndex = cartItems.indexWhere(
        (item) => item.productId == product.id,
      );

      if (existingIndex != -1) {
        final existingItem = cartItems[existingIndex];
        if (existingItem.quantity >= product.stock) {
          AppUtils.showSnackbar(
            'Stock Limit Exceeded',
            'Only ${product.stock} items are available.',
            isError: true,
          );
          return false;
        }
        await increaseQuantity(existingItem, stock: product.stock);
      } else {
        if (product.stock < 1) {
          AppUtils.showSnackbar(
            'Out of Stock',
            'This item is currently out of stock.',
            isError: true,
          );
          return false;
        }

        final newItem = CartItemModel(
          productId: product.id,
          title: product.title,
          price: product.displayDiscountPrice,
          thumbnail: product.thumbnail,
          quantity: 1,
          addedAt: DateTime.now(),
        );

        await _cartRepo.addCartItem(newItem);
        cartItems.insert(0, newItem); // Optimistic prepend
        if (showSuccessSnackbar) {
          AppUtils.showSnackbar('Success', 'Product added to cart.');
        }
      }
      return true;
    } catch (e) {
      AppUtils.showSnackbar(
        'Error',
        'Unable to add to cart. $e',
        isError: true,
      );
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> increaseQuantity(CartItemModel item, {int? stock}) async {
    try {
      isUpdating.value = true;

      // Basic stock validation if passed
      if (stock != null && item.quantity >= stock) {
        AppUtils.showSnackbar(
          'Stock Limit Exceeded',
          'Only $stock items are available.',
          isError: true,
        );
        return;
      }

      final newQuantity = item.quantity + 1;
      await _cartRepo.updateCartItemQuantity(item.productId, newQuantity);

      final index = cartItems.indexWhere((e) => e.productId == item.productId);
      if (index != -1) {
        cartItems[index] = item.copyWith(quantity: newQuantity);
      }
    } catch (e) {
      AppUtils.showSnackbar('Error', 'Unable to update cart.', isError: true);
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> decreaseQuantity(CartItemModel item) async {
    try {
      isUpdating.value = true;
      final newQuantity = item.quantity - 1;

      if (newQuantity <= 0) {
        await removeItem(item);
      } else {
        await _cartRepo.updateCartItemQuantity(item.productId, newQuantity);
        final index = cartItems.indexWhere(
          (e) => e.productId == item.productId,
        );
        if (index != -1) {
          cartItems[index] = item.copyWith(quantity: newQuantity);
        }
      }
    } catch (e) {
      AppUtils.showSnackbar('Error', 'Unable to update cart.', isError: true);
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> removeItem(CartItemModel item) async {
    try {
      isUpdating.value = true;
      await _cartRepo.removeCartItem(item.productId);
      cartItems.removeWhere((e) => e.productId == item.productId);
      AppUtils.showSnackbar('Success', 'Item removed from cart.');
    } catch (e) {
      AppUtils.showSnackbar('Error', 'Unable to remove item.', isError: true);
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> clearCart() async {
    try {
      isUpdating.value = true;
      await _cartRepo.clearCart();
      cartItems.clear();
      appliedPromoCode.value = '';
      promoController.clear();
      AppUtils.showSnackbar('Success', 'Cart cleared successfully.');
    } catch (e) {
      AppUtils.showSnackbar('Error', 'Unable to clear cart.', isError: true);
    } finally {
      isUpdating.value = false;
    }
  }
  
  @override
  void onClose() {
    promoController.dispose();
    super.onClose();
  }
}
