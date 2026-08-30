import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/order_model.dart';
import 'auth_repository.dart';

class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthRepository _authRepo = Get.find<AuthRepository>();

  String? get _userId => _authRepo.getCurrentUser()?.uid;

  CollectionReference<Map<String, dynamic>>? get _ordersCollection {
    final uid = _userId;
    if (uid == null) return null;
    return _firestore.collection('orders').doc(uid).collection('orders');
  }

  Future<String> createOrder(OrderModel order) async {
    final collection = _ordersCollection;
    if (collection == null) throw Exception('User not authenticated');

    final docRef = await collection.add(order.toFirestore());
    return docRef.id;
  }

  Future<List<OrderModel>> getOrders() async {
    final collection = _ordersCollection;
    if (collection == null) return [];

    final snapshot = await collection.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    final collection = _ordersCollection;
    if (collection == null) return null;

    final doc = await collection.doc(orderId).get();
    if (doc.exists) {
      return OrderModel.fromFirestore(doc);
    }
    return null;
  }
}
