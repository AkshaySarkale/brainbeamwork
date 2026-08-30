import 'dart:async';
import 'package:get/get.dart';
import 'package:shopora/data/models/notification_model.dart';
import 'package:shopora/data/repositories/notification_repository.dart';
import 'package:shopora/features/auth/auth_controller.dart';
import 'package:shopora/core/utils/app_utils.dart';

class NotificationController extends GetxController {
  final NotificationRepository _repository = Get.find<NotificationRepository>();

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  StreamSubscription? _subscription;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();

    // Listen to Auth state. Only subscribe if user is logged in.
    ever(AuthController.instance.firebaseUser, (user) {
      if (user != null) {
        _subscribeToNotifications();
      } else {
        _unsubscribe();
      }
    });

    // Initial check
    if (AuthController.instance.firebaseUser.value != null) {
      _subscribeToNotifications();
    } else {
      isLoading.value = false;
    }
  }

  void _subscribeToNotifications() {
    isLoading.value = true;
    _unsubscribe();

    try {
      _subscription = _repository.getNotifications().listen(
        (data) {
          notifications.assignAll(data);
          isLoading.value = false;
          errorMessage.value = '';
        },
        onError: (error) {
          errorMessage.value = 'Failed to load notifications.';
          isLoading.value = false;
        },
      );
    } catch (e) {
      errorMessage.value = 'Failed to connect to notifications.';
      isLoading.value = false;
    }
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
    notifications.clear();
  }

  Future<void> markAsRead(String id) async {
    try {
      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1 && !notifications[index].isRead) {
        final notif = notifications[index];
        notifications[index] = NotificationModel(
          id: notif.id,
          title: notif.title,
          message: notif.message,
          type: notif.type,
          orderId: notif.orderId,
          isRead: true,
          createdAt: notif.createdAt,
          updatedAt: notif.updatedAt,
        );
      }
      await _repository.markAsRead(id);
    } catch (e) {
      AppUtils.showSnackbar('Error', 'Could not mark as read.', isError: true);
    }
  }

  Future<void> markAllAsRead() async {
    if (unreadCount == 0) return;
    try {
      for (int i = 0; i < notifications.length; i++) {
        if (!notifications[i].isRead) {
          final notif = notifications[i];
          notifications[i] = NotificationModel(
            id: notif.id,
            title: notif.title,
            message: notif.message,
            type: notif.type,
            orderId: notif.orderId,
            isRead: true,
            createdAt: notif.createdAt,
            updatedAt: notif.updatedAt,
          );
        }
      }
      await _repository.markAllAsRead();
    } catch (e) {
      AppUtils.showSnackbar(
        'Error',
        'Could not mark all as read.',
        isError: true,
      );
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _repository.deleteNotification(id);
    } catch (e) {
      AppUtils.showSnackbar(
        'Error',
        'Could not delete notification.',
        isError: true,
      );
    }
  }

  @override
  void onClose() {
    _unsubscribe();
    super.onClose();
  }
}
