import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'wishlist_controller.dart';
import '../cart/cart_controller.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/theme/app_colors.dart';
import '../../data/models/product_model.dart';

class WishlistView extends GetView<WishlistController> {
  const WishlistView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
        actions: [
          Obx(() {
            if (controller.wishlistItems.isNotEmpty) {
              return TextButton(
                onPressed: () {
                  Get.defaultDialog(
                    title: 'Clear Wishlist?',
                    middleText: 'Remove all saved products?',
                    textCancel: 'Cancel',
                    textConfirm: 'Clear',
                    confirmTextColor: Colors.white,
                    onConfirm: () {
                      Get.back(); // close dialog
                      controller.clearWishlist();
                    },
                  );
                },
                child: const Text('Clear All', style: TextStyle(color: Colors.red)),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.wishlistItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite, size: 80, color: Colors.redAccent),
                const SizedBox(height: 16),
                const Text('Your wishlist is empty.', style: AppTextStyles.heading2),
                const SizedBox(height: 8),
                const Text('Save products you love and find them here later.', style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Get.offNamed(AppRoutes.products),
                  child: const Text('Continue Shopping'),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: controller.wishlistItems.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = controller.wishlistItems[index];
            return GestureDetector(
              onTap: () => Get.toNamed('${AppRoutes.productDetails}?id=${item.productId}'),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.thumbnail,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(width: 80, height: 80, color: Colors.grey.shade200),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(item.title, style: AppTextStyles.heading2, maxLines: 2, overflow: TextOverflow.ellipsis),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => controller.removeByProductId(item.productId),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('₹${item.price.toStringAsFixed(0)}', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                final cartController = Get.find<CartController>();
                                // Convert WishlistItem to a mock ProductModel structure just for the cart
                                // The CartController requires a ProductModel, so we fabricate the required fields
                                final mockProduct = ProductModel(
                                  id: item.productId,
                                  title: item.title,
                                  price: item.price,
                                  discountPercentage: 0,
                                  rating: 0,
                                  stock: 99, // default arbitrary safe stock for dummy cart add
                                  brand: '',
                                  category: '',
                                  thumbnail: item.thumbnail,
                                  images: [item.thumbnail],
                                  description: '',
                                );
                                cartController.addToCart(mockProduct);
                              },
                              child: const Text('Add to Cart'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
