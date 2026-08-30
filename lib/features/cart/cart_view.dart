import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopora/features/cart/cart_controller.dart';
import 'package:shopora/app/routes/app_routes.dart';
import 'package:shopora/app/theme/app_text_styles.dart';
import 'package:shopora/app/theme/app_colors.dart';
import 'package:shopora/core/widgets/app_empty_state.dart';
import 'package:shopora/core/widgets/shimmer_loading.dart';
import 'package:shopora/features/notification/notification_controller.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

  void _showOffersBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Available Offers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...controller.availableOffers.map((offer) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all( color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1), 
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(offer['code'], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ),
                          const SizedBox(height: 8),
                          Text(offer['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(offer['description'], style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => controller.applyPromoCode(offer['code']),
                      child: const Text('APPLY', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2EAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: false,
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            'My Cart',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none, color: Colors.black87, size: 26),
                Obx(() {
                  if (!Get.isRegistered<NotificationController>()) return const SizedBox.shrink();
                  final notifCtrl = Get.find<NotificationController>();
                  if (notifCtrl.unreadCount == 0) return const SizedBox.shrink();

                  return Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
            onPressed: () => Get.toNamed(AppRoutes.notifications),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black87, size: 26),
            onPressed: () => Get.toNamed(AppRoutes.wishlist),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black87, size: 26),
            onPressed: () => Get.toNamed(AppRoutes.profile),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const ListShimmer();
          }

        if (controller.cartItems.isEmpty) {
          return AppEmptyState(
            icon: Icons.shopping_cart_outlined,
            title: 'Your cart is empty',
            message: 'Add products to your cart and they will appear here.',
            buttonText: 'Continue Shopping',
            onButtonPressed: () {
              if (Get.currentRoute == AppRoutes.home) {
                // We are inside the dashboard IndexedStack, so switch to home tab.
                // This is a hacky way if we don't have a direct controller for Home. 
                // Better to just push to products.
                Get.toNamed(AppRoutes.products);
              } else {
                Get.offNamed(AppRoutes.products);
              }
            }
          );
        }

        return Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: controller.cartItems.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, color: Color(0xFFF0F0F0)),
                      itemBuilder: (context, index) {
                        final item = controller.cartItems[index];
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item.thumbnail,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        width: 70,
                                        height: 70,
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey,
                                        ),
                                      ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₹${item.price.toStringAsFixed(0)}',
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove, size: 16),
                                            constraints: const BoxConstraints(
                                              minWidth: 36,
                                              minHeight: 36,
                                            ),
                                            padding: EdgeInsets.zero,
                                            onPressed: controller.isUpdating.value
                                                ? null
                                                : () => controller.decreaseQuantity(item),
                                          ),
                                          Text(
                                            '${item.quantity}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add, size: 16),
                                            constraints: const BoxConstraints(
                                              minWidth: 36,
                                              minHeight: 36,
                                            ),
                                            padding: EdgeInsets.zero,
                                            onPressed: controller.isUpdating.value
                                                ? null
                                                : () => controller.increaseQuantity(item),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Color(0xFFE5B2B2),
                                ),
                                onPressed: controller.isUpdating.value
                                    ? null
                                    : () => controller.removeItem(item),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal', style: AppTextStyles.bodyMedium),
                            Text('₹${controller.subtotal.toStringAsFixed(0)}', style: AppTextStyles.bodyMedium),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Delivery', style: AppTextStyles.bodyMedium),
                            Text(
                              controller.deliveryFee == 0
                                  ? 'Free'
                                  : '₹${controller.deliveryFee.toStringAsFixed(0)}',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                        if (controller.discountAmount > 0) ...[
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Discount (${controller.appliedPromoCode.value})', style: const TextStyle(color: Colors.green, fontSize: 14)),
                              Text(
                                '-₹${controller.discountAmount.toStringAsFixed(0)}',
                                style: const TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                        const Divider(height: 32, color: Color(0xFFEEEEEE)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                            Text(
                              '₹${controller.total.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Obx(() {
                          if (controller.appliedPromoCode.value.isNotEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Code ${controller.appliedPromoCode.value} applied',
                                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () => controller.removePromoCode(),
                                    child: const Text('Remove', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () => _showOffersBottomSheet(context),
                                child: const Padding(
                                  padding: EdgeInsets.only(bottom: 8.0),
                                  child: Text('View Available Offers', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: TextField(
                                        controller: controller.promoController,
                                        decoration: InputDecoration(
                                          hintText: 'Enter Promo Code',
                                          hintStyle: TextStyle(color: Colors.grey.shade500),
                                          border: InputBorder.none,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black87),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: TextButton(
                                      onPressed: () {
                                        FocusScope.of(context).unfocus();
                                        controller.applyPromoCode();
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                                        child: Text('Apply', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3F2B4F),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              if (controller.cartItems.isEmpty) {
                                Get.snackbar(
                                  'Empty Cart',
                                  'Your cart is empty.',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }
                              Get.toNamed(AppRoutes.checkout);
                            },
                            child: const Text(
                              'Proceed to Checkout',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (controller.isUpdating.value)
              Container(
                color: Colors.black12,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
        }),
      ),
    );
  }
}
