import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopora/features/notification/notification_controller.dart';
import 'package:shopora/app/theme/app_colors.dart';
import 'package:shopora/app/routes/app_routes.dart';
import 'package:shopora/core/widgets/shimmer_loading.dart';
import 'package:shopora/core/widgets/app_empty_state.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2EAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Notifications',
          style: TextStyle(fontFamily: 'serif', fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        actions: [
          Obx(() {
            if (controller.unreadCount == 0) return const SizedBox.shrink();
            return TextButton(
              onPressed: controller.markAllAsRead,
              child: Text('Mark all read', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            );
          }),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const ListShimmer();
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(controller.errorMessage.value),
                ],
              ),
            );
          }

          if (controller.notifications.isEmpty) {
            return const AppEmptyState(
              icon: Icons.notifications_none,
              title: 'No notifications yet',
              message: 'We\'ll let you know when something important happens.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Firestore streams naturally refresh, but this gives visual feedback
              await Future.delayed(const Duration(seconds: 1));
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: controller.notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notification = controller.notifications[index];
                return Dismissible(
                  key: Key(notification.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    controller.deleteNotification(notification.id);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: notification.isRead ? Colors.white : AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: notification.isRead ? null : Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getIconColor(notification.type).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getIcon(notification.type),
                            color: _getIconColor(notification.type),
                          ),
                        ),
                        title: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: notification.isRead
                                ? FontWeight.w500
                                : FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Text(notification.message, style: const TextStyle(color: Colors.black54)),
                            const SizedBox(height: 8),
                            if (notification.createdAt != null)
                              Text(
                                _timeAgo(notification.createdAt!),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                        onTap: () {
                          if (!notification.isRead) {
                            controller.markAsRead(notification.id);
                          }
                          if (notification.orderId != null &&
                              notification.orderId!.isNotEmpty) {
                            Get.toNamed(
                              AppRoutes.orderDetails,
                              arguments: {'orderId': notification.orderId},
                            );
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'order_placed':
        return Icons.shopping_bag;
      case 'order_confirmed':
        return Icons.check_circle;
      case 'order_shipped':
        return Icons.local_shipping;
      case 'order_delivered':
        return Icons.inventory;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'order_placed':
        return Colors.blue;
      case 'order_confirmed':
        return Colors.green;
      case 'order_shipped':
        return Colors.orange;
      case 'order_delivered':
        return Colors.teal;
      default:
        return AppColors.primary;
    }
  }

  String _timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()} years ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} months ago';
    if (diff.inDays > 7) return '${(diff.inDays / 7).floor()} weeks ago';
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} minutes ago';
    return 'just now';
  }
}
