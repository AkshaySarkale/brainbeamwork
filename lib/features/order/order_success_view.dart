import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopora/app/routes/app_routes.dart';
import 'package:shopora/app/theme/app_text_styles.dart';
import 'package:shopora/app/theme/app_colors.dart';

class OrderSuccessView extends StatelessWidget {
  const OrderSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    final String orderId = Get.arguments?['orderId'] ?? 'Unknown';
    final orderIdDisplay = orderId.length > 6
        ? orderId.substring(orderId.length - 6).toUpperCase()
        : orderId;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.check_circle, size: 100, color: Colors.green),
              const SizedBox(height: 24),
              const Text(
                'Order Placed Successfully!',
                textAlign: TextAlign.center,
                style: AppTextStyles.heading1,
              ),
              const SizedBox(height: 16),
              Text(
                'Order #$orderIdDisplay',
                textAlign: TextAlign.center,
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your order has been placed successfully and will be delivered soon.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Column(
                  children: [
                    Text(
                      'Payment Method',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Cash on Delivery',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  Get.offAllNamed(AppRoutes.home);
                  Get.toNamed(AppRoutes.orders);
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('View My Orders'),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Get.offAllNamed(AppRoutes.home),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('Continue Shopping'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
