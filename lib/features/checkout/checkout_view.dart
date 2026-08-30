import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'checkout_controller.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/theme/app_colors.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Delivery Address', style: AppTextStyles.heading2),
                const SizedBox(height: 12),
                Obx(() {
                  final address = controller.addressController.selectedAddress.value;
                  if (address == null) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Column(
                        children: [
                          const Text('No address selected', style: TextStyle(color: Colors.red)),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => Get.toNamed(AppRoutes.addresses, arguments: {'isSelectionMode': true}),
                            child: const Text('Select Address'),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(address.fullName, style: AppTextStyles.heading2),
                            TextButton(
                              onPressed: () => Get.toNamed(AppRoutes.addresses, arguments: {'isSelectionMode': true}),
                              child: const Text('Change'),
                            ),
                          ],
                        ),
                        Text(address.phone, style: AppTextStyles.bodyMedium),
                        const SizedBox(height: 4),
                        Text('${address.addressLine}, ${address.city}', style: AppTextStyles.bodyMedium),
                        Text('${address.state} - ${address.postalCode}', style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  );
                }),
                
                const SizedBox(height: 32),
                const Text('Order Summary', style: AppTextStyles.heading2),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      ...controller.cartController.cartItems.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item.title} × ${item.quantity}',
                                style: AppTextStyles.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text('₹${(item.price * item.quantity).toStringAsFixed(0)}', style: AppTextStyles.bodyMedium),
                          ],
                        ),
                      )),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal', style: AppTextStyles.bodyMedium),
                          Text('₹${controller.cartController.subtotal.toStringAsFixed(0)}', style: AppTextStyles.bodyMedium),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Delivery', style: AppTextStyles.bodyMedium),
                          Text(controller.cartController.deliveryFee == 0 ? 'Free' : '₹${controller.cartController.deliveryFee.toStringAsFixed(0)}', style: AppTextStyles.bodyMedium),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total', style: AppTextStyles.heading2),
                          Text('₹${controller.cartController.total.toStringAsFixed(0)}', style: AppTextStyles.heading2.copyWith(color: AppColors.primary)),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                const Text('Payment Method', style: AppTextStyles.heading2),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        value: 'cash_on_delivery',
                        groupValue: 'cash_on_delivery', // Hardcoded for now per instructions
                        onChanged: (val) {},
                        title: const Text('Cash on Delivery', style: TextStyle(fontWeight: FontWeight.bold)),
                        activeColor: AppColors.primary,
                      ),
                      const Divider(height: 1),
                      RadioListTile<String>(
                        value: 'online',
                        groupValue: 'cash_on_delivery',
                        onChanged: null, // Disabled
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Online Payment', style: TextStyle(color: Colors.grey)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
                              child: const Text('Coming Soon', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100), // padding for bottom button
              ],
            ),
          ),
          Obx(() {
            if (controller.isPlacingOrder.value) {
              return Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Obx(() => ElevatedButton(
              onPressed: controller.isPlacingOrder.value ? null : controller.placeOrder,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: controller.isPlacingOrder.value
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Place Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )),
          ),
        ),
      ),
    );
  }
}
