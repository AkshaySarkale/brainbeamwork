import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopora/data/models/notification_model.dart';
import 'package:shopora/features/auth/auth_controller.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get _uid => AuthController.instance.firebaseUser.value?.uid;

  CollectionReference _notificationsRef() {
    if (_uid == null) throw Exception('User not logged in');
    return _firestore.collection('users').doc(_uid).collection('notifications');
  }

  Stream<List<NotificationModel>> getNotifications() {
    try {
      if (_uid == null) return Stream.value([]);
      return _notificationsRef()
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => NotificationModel.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      return Stream.value([]);
    }
  }

  Future<void> createNotification(NotificationModel notification) async {
    try {
      await _notificationsRef().add(notification.toFirestore());
    } catch (e) {
      throw Exception('Failed to create notification');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationsRef().doc(notificationId).update({
        'isRead': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark notification as read');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final unreadDocs = await _notificationsRef()
          .where('isRead', isEqualTo: false)
          .get();
      final batch = _firestore.batch();

      for (var doc in unreadDocs.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark all as read');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationsRef().doc(notificationId).delete();
    } catch (e) {
      throw Exception('Failed to delete notification');
    }
  }
}
