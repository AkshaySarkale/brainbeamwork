import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'cart_controller.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          Obx(() {
            if (controller.cartItems.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                Get.defaultDialog(
                  title: 'Clear Cart',
                  middleText: 'Are you sure you want to clear your cart?',
                  textConfirm: 'Yes',
                  textCancel: 'No',
                  confirmTextColor: Colors.white,
                  onConfirm: () {
                    controller.clearCart();
                    Get.back();
                  },
                );
              },
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.cartItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🛒', style: TextStyle(fontSize: 80)),
                const SizedBox(height: 16),
                const Text('Your cart is empty.', style: AppTextStyles.heading2),
                const SizedBox(height: 8),
                const Text('Add products to your cart and they will appear here.', 
                  style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Get.offNamed(AppRoutes.products),
                  child: const Text('Continue Shopping'),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: controller.cartItems.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = controller.cartItems[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.thumbnail,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${item.price.toStringAsFixed(0)}',
                                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey.shade300),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove, size: 16),
                                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                              padding: EdgeInsets.zero,
                                              onPressed: controller.isUpdating.value ? null : () => controller.decreaseQuantity(item),
                                            ),
                                            Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                            IconButton(
                                              icon: const Icon(Icons.add, size: 16),
                                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                              padding: EdgeInsets.zero,
                                              onPressed: controller.isUpdating.value ? null : () => controller.increaseQuantity(item),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        onPressed: controller.isUpdating.value ? null : () => controller.removeItem(item),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
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
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Delivery', style: AppTextStyles.bodyMedium),
                            Text(controller.deliveryFee == 0 ? 'Free' : '₹${controller.deliveryFee.toStringAsFixed(0)}', style: AppTextStyles.bodyMedium),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total', style: AppTextStyles.heading2),
                            Text('₹${controller.total.toStringAsFixed(0)}', style: AppTextStyles.heading2),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (controller.cartItems.isEmpty) {
                                Get.snackbar('Empty Cart', 'Your cart is empty.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
                                return;
                              }
                              Get.toNamed(AppRoutes.checkout);
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text('Proceed to Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
    );
  }
}
