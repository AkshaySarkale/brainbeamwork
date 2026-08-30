import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopora/features/checkout/checkout_controller.dart';
import 'package:shopora/app/routes/app_routes.dart';
import 'package:shopora/app/theme/app_text_styles.dart';
import 'package:shopora/app/theme/app_colors.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  void _showUpiBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Payment App',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose your preferred UPI app to complete the payment securely.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildUpiOption('Google Pay', 'assets/images/gpay.png', Icons.g_mobiledata, Colors.blue),
                _buildUpiOption('PhonePe', 'assets/images/phonepe.png', Icons.account_balance_wallet, Colors.deepPurple),
                _buildUpiOption('Paytm', 'assets/images/paytm.png', Icons.payment, Colors.lightBlue),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildUpiOption(String name, String assetPath, IconData fallbackIcon, Color fallbackColor) {
    return GestureDetector(
      onTap: () {
        Get.back(); // close bottom sheet
        controller.simulateUpiPayment(name);
      },
      child: Column(
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Icon(fallbackIcon, size: 32, color: fallbackColor),
            // Ideally we'd use Image.asset(assetPath) if we had the logos.
          ),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
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
        centerTitle: true,
        title: const Text(
          'Checkout',
          style: TextStyle(fontFamily: 'serif', fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Delivery Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 12),
                  Obx(() {
                    final address = controller.addressController.selectedAddress.value;
                    if (address == null) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                          border: Border.all(color: Colors.red.shade200, width: 1.5),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.location_off_outlined, color: Colors.red, size: 32),
                            const SizedBox(height: 8),
                            const Text('No address selected', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => Get.toNamed(AppRoutes.addresses, arguments: {'isSelectionMode': true}),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
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
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.location_on, color: AppColors.primary, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(address.fullName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                                ],
                              ),
                              TextButton(
                                onPressed: () => Get.toNamed(AppRoutes.addresses, arguments: {'isSelectionMode': true}),
                                child: Text('Change', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(address.phone, style: AppTextStyles.bodyMedium),
                          const SizedBox(height: 4),
                          Text('${address.addressLine}, ${address.city}', style: AppTextStyles.bodyMedium),
                          Text('${address.state} - ${address.postalCode}', style: AppTextStyles.bodyMedium),
                        ],
                      ),
                    );
                  }),
                  
                  const SizedBox(height: 32),
                  const Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
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
                              Text('₹${(item.price * item.quantity).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                            ],
                          ),
                        )),
                        const Divider(height: 24, color: Color(0xFFF0F0F0)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal', style: TextStyle(color: Colors.grey)),
                            Text('₹${controller.cartController.subtotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Delivery', style: TextStyle(color: Colors.grey)),
                            Text(controller.cartController.deliveryFee == 0 ? 'Free' : '₹${controller.cartController.deliveryFee.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Divider(height: 24, color: Color(0xFFF0F0F0)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                            Text('₹${controller.cartController.total.toStringAsFixed(0)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  const Text('Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 12),
                  Obx(() => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                        RadioListTile<String>(
                          value: 'cash_on_delivery',
                          groupValue: controller.paymentMethod.value,
                          onChanged: (val) {
                            if (val != null) controller.setPaymentMethod(val);
                          },
                          title: const Text('Cash on Delivery', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                          subtitle: const Text('Pay when your order arrives', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          activeColor: AppColors.primary,
                        ),
                        const Divider(height: 1, color: Color(0xFFF0F0F0), indent: 16, endIndent: 16),
                        RadioListTile<String>(
                          value: 'online',
                          groupValue: controller.paymentMethod.value,
                          onChanged: null,
                          title: const Text('Online Payment (Coming Soon)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                          subtitle: const Text('Google Pay, PhonePe, Paytm', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ))),
                  const SizedBox(height: 120), // padding for bottom button
                ],
              ),
            ),
            Obx(() {
              if (controller.isPlacingOrder.value) {
                return Container(
                  color: Colors.white.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: Obx(() {
              final isOnline = controller.paymentMethod.value == 'online';
              return ElevatedButton(
                onPressed: controller.isPlacingOrder.value 
                  ? null 
                  : () {
                      if (isOnline) {
                        _showUpiBottomSheet(context);
                      } else {
                        controller.placeOrder();
                      }
                    },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: controller.isPlacingOrder.value
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        isOnline ? 'Proceed to Pay ₹${controller.cartController.total.toStringAsFixed(0)}' : 'Place Order', 
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                      ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
