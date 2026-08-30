import 'package:get/get.dart';
import 'package:shopora/data/models/wishlist_item_model.dart';
import 'package:shopora/data/models/product_model.dart';
import 'package:shopora/data/repositories/wishlist_repository.dart';
import 'package:shopora/core/utils/app_utils.dart';
import 'package:shopora/features/auth/auth_controller.dart';

class WishlistController extends GetxController {
  final WishlistRepository _wishlistRepo = Get.find<WishlistRepository>();

  final RxList<WishlistItemModel> wishlistItems = <WishlistItemModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Re-fetch wishlist when authentication state changes
    ever(Get.find<AuthController>().firebaseUser, (user) {
      if (user != null) {
        fetchWishlist();
      } else {
        wishlistItems.clear(); // Clear local state on logout
      }
    });

    if (Get.find<AuthController>().firebaseUser.value != null) {
      fetchWishlist();
    }
  }

  bool isWishlisted(int productId) {
    return wishlistItems.any((item) => item.productId == productId);
  }

  Future<void> fetchWishlist() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final items = await _wishlistRepo.getWishlistItems();
      wishlistItems.assignAll(items);
    } catch (e) {
      errorMessage.value = 'Failed to load wishlist.';
      AppUtils.showSnackbar(
        'Error',
        'Failed to load wishlist data.',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addToWishlist(ProductModel product) async {
    if (Get.find<AuthController>().firebaseUser.value == null) {
      AppUtils.showSnackbar(
        'Authentication Required',
        'Please login to add products to your wishlist.',
        isError: true,
      );
      return;
    }

    try {
      isUpdating.value = true;
      if (isWishlisted(product.id)) {
        return; // Already in wishlist
      }

      final newItem = WishlistItemModel(
        productId: product.id,
        title: product.title,
        price: product.displayDiscountPrice,
        thumbnail: product.thumbnail,
        addedAt: DateTime.now(),
      );

      // Optimistic update
      wishlistItems.insert(0, newItem);

      await _wishlistRepo.addToWishlist(newItem);
      AppUtils.showSnackbar('Success', 'Added to wishlist.');
    } catch (e) {
      // Revert on failure
      wishlistItems.removeWhere((item) => item.productId == product.id);
      AppUtils.showSnackbar(
        'Error',
        'Unable to add to wishlist.',
        isError: true,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> removeFromWishlist(ProductModel product) async {
    await removeByProductId(product.id);
  }

  Future<void> removeByProductId(int productId) async {
    int backupIndex = -1;
    WishlistItemModel? backupItem;

    try {
      isUpdating.value = true;

      // Store backup for revert
      backupIndex = wishlistItems.indexWhere(
        (item) => item.productId == productId,
      );
      if (backupIndex == -1) return;
      backupItem = wishlistItems[backupIndex];

      // Optimistic update
      wishlistItems.removeAt(backupIndex);

      await _wishlistRepo.removeFromWishlist(productId);
      AppUtils.showSnackbar('Success', 'Removed from wishlist.');
    } catch (e) {
      // Revert on failure
      if (backupIndex != -1 && backupItem != null) {
        wishlistItems.insert(backupIndex, backupItem);
      }
      AppUtils.showSnackbar(
        'Error',
        'Unable to remove from wishlist.',
        isError: true,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> clearWishlist() async {
    List<WishlistItemModel> backupItems = [];

    try {
      isUpdating.value = true;

      // Keep backup
      backupItems = List<WishlistItemModel>.from(wishlistItems);

      // Optimistic
      wishlistItems.clear();

      await _wishlistRepo.clearWishlist();
      AppUtils.showSnackbar('Success', 'Wishlist cleared successfully.');
    } catch (e) {
      // Revert
      wishlistItems.assignAll(backupItems);
      AppUtils.showSnackbar(
        'Error',
        'Unable to clear wishlist.',
        isError: true,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  void toggleWishlist(ProductModel product) {
    if (isWishlisted(product.id)) {
      removeFromWishlist(product);
    } else {
      addToWishlist(product);
    }
  }
}
