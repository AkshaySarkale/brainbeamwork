import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'order_controller.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/theme/app_colors.dart';
import '../../app/routes/app_routes.dart';
import '../../core/widgets/app_empty_state.dart';

class OrderView extends GetView<OrderController> {
  const OrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.orders.isEmpty) {
          return AppEmptyState(
            icon: Icons.shopping_bag_outlined,
            title: 'No orders yet',
            message: 'Start shopping to place your first order.',
            buttonText: 'Shop Now',
            onButtonPressed: () => Get.offNamed(AppRoutes.products),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: controller.orders.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final order = controller.orders[index];
            final orderIdDisplay = order.id.length > 6
                ? order.id.substring(order.id.length - 6).toUpperCase()
                : order.id;

            final dateStr = order.createdAt != null
                ? '${order.createdAt!.day}/${order.createdAt!.month}/${order.createdAt!.year}'
                : 'Unknown Date';

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
                      Text(
                        'Order #$orderIdDisplay',
                        style: AppTextStyles.heading2,
                      ),
                      Text(
                        '₹${order.total.toStringAsFixed(0)}',
                        style: AppTextStyles.heading2.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${order.items.length} Item(s)',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '● ${order.orderStatus.capitalizeFirst}',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(dateStr, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const Divider(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Get.toNamed(
                        AppRoutes.orderDetails,
                        arguments: {'order': order},
                      ),
                      child: const Text('View Details'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
