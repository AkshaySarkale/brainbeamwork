import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'notification_controller.dart';
import '../../app/theme/app_colors.dart';
import '../../app/routes/app_routes.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Obx(() {
            if (controller.unreadCount == 0) return const SizedBox.shrink();
            return TextButton(
              onPressed: controller.markAllAsRead,
              child: const Text('Mark all read'),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
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
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No notifications yet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'We\'ll let you know when something important happens.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Firestore streams naturally refresh, but this gives visual feedback
            await Future.delayed(const Duration(seconds: 1));
          },
          child: ListView.separated(
            itemCount: controller.notifications.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final notification = controller.notifications[index];
              return Dismissible(
                key: Key(notification.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  controller.deleteNotification(notification.id);
                },
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  tileColor: notification.isRead
                      ? Colors.transparent
                      : AppColors.primary.withValues(alpha: 0.05),
                  leading: CircleAvatar(
                    backgroundColor: _getIconColor(
                      notification.type,
                    ).withValues(alpha: 0.1),
                    child: Icon(
                      _getIcon(notification.type),
                      color: _getIconColor(notification.type),
                    ),
                  ),
                  title: Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(notification.message),
                      const SizedBox(height: 4),
                      if (notification.createdAt != null)
                        Text(
                          _timeAgo(notification.createdAt!),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
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
              );
            },
          ),
        );
      }),
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
