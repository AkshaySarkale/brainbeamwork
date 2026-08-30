import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopora/features/product/product_details/product_details_controller.dart';
import 'package:shopora/app/theme/app_text_styles.dart';
import 'package:shopora/app/theme/app_colors.dart';
import 'package:shopora/core/widgets/shimmer_loading.dart';
import 'package:shopora/core/utils/app_utils.dart';
import 'package:shopora/features/cart/cart_controller.dart';
import 'package:shopora/features/wishlist/wishlist_controller.dart';

class ProductDetailsView extends GetView<ProductDetailsController> {
  const ProductDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          Obx(() {
            if (controller.product.value == null)
              return const SizedBox.shrink();
            final product = controller.product.value!;
            final wishlistCtrl = Get.find<WishlistController>();
            final isFav = wishlistCtrl.isWishlisted(product.id);
            return IconButton(
              icon: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? Colors.red : Colors.black54,
              ),
              onPressed: () => wishlistCtrl.toggleWishlist(product),
            );
          }),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const ProductDetailsShimmer();
          }
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }
        final product = controller.product.value;
        if (product == null) {
          return const Center(child: Text('Product not found.'));
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProductImageSlider(
                images: product.images,
                thumbnail: product.thumbnail,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.brand,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(product.title, style: AppTextStyles.heading2),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '${product.rating}',
                          style: AppTextStyles.bodyLarge,
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: product.stock > 0
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            product.stock > 0
                                ? 'In Stock (${product.stock})'
                                : 'Out of Stock',
                            style: TextStyle(
                              color: product.stock > 0
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${product.displayDiscountPrice.toStringAsFixed(0)}',
                          style: AppTextStyles.heading1.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        if (product.discountPercentage > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '₹${product.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${product.discountPercentage}% OFF',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('Description', style: AppTextStyles.heading2),
                    const SizedBox(height: 8),
                    Text(product.description, style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      ),
      bottomNavigationBar: Obx(() {
        if (controller.product.value == null) return const SizedBox.shrink();

        final cartController = Get.find<CartController>();

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: controller.product.value!.stock > 0
                    ? () async {
                        final success = await cartController.addToCart(controller.product.value!, showSuccessSnackbar: false);
                        if (success) {
                          Get.back();
                          // Show snackbar after navigating back so Get.back() doesn't accidentally pop the snackbar route
                          Future.delayed(const Duration(milliseconds: 100), () {
                            AppUtils.showSnackbar('Success', 'Product added to cart.');
                          });
                        }
                      }
                    : null,
                child: cartController.isUpdating.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Add to Cart'),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _ProductImageSlider extends StatefulWidget {
  final List<String> images;
  final String thumbnail;

  const _ProductImageSlider({required this.images, required this.thumbnail});

  @override
  State<_ProductImageSlider> createState() => _ProductImageSliderState();
}

class _ProductImageSliderState extends State<_ProductImageSlider> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = widget.images.isEmpty ? 1 : widget.images.length;
    
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: itemCount,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final imageUrl = widget.images.isEmpty
                      ? widget.thumbnail
                      : widget.images[index];
                  if (imageUrl.isEmpty) {
                    return const Center(
                      child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                    );
                  }
                  return Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const Center(child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey)),
                  );
                },
              ),
              if (itemCount > 1 && _currentIndex > 0)
                Positioned(
                  left: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withOpacity(0.05),
                        child: const Icon(Icons.chevron_left, color: Colors.black87),
                      ),
                    ),
                  ),
                ),
              if (itemCount > 1 && _currentIndex < itemCount - 1)
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withOpacity(0.05),
                        child: const Icon(Icons.chevron_right, color: Colors.black87),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (itemCount > 1) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              itemCount,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentIndex == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentIndex == index ? AppColors.primary : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
