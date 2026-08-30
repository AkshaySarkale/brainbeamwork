import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/cart_item_model.dart';
import 'auth_repository.dart';

class CartRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthRepository _authRepo = Get.find<AuthRepository>();

  String? get _userId => _authRepo.getCurrentUser()?.uid;

  CollectionReference<Map<String, dynamic>>? get _cartCollection {
    final uid = _userId;
    if (uid == null) return null;
    return _firestore.collection('carts').doc(uid).collection('items');
  }

  Future<List<CartItemModel>> getCartItems() async {
    final collection = _cartCollection;
    if (collection == null) return [];

    final querySnapshot = await collection
        .orderBy('addedAt', descending: true)
        .get();
    return querySnapshot.docs
        .map((doc) => CartItemModel.fromFirestore(doc))
        .toList();
  }

  Future<void> addCartItem(CartItemModel item) async {
    final collection = _cartCollection;
    if (collection == null) throw Exception('User not authenticated');

    await collection
        .doc(item.productId.toString())
        .set(item.toFirestore(), SetOptions(merge: true));
  }

  Future<void> updateCartItemQuantity(int productId, int quantity) async {
    final collection = _cartCollection;
    if (collection == null) throw Exception('User not authenticated');

    await collection.doc(productId.toString()).update({'quantity': quantity});
  }

  Future<void> removeCartItem(int productId) async {
    final collection = _cartCollection;
    if (collection == null) throw Exception('User not authenticated');

    await collection.doc(productId.toString()).delete();
  }

  Future<void> clearCart() async {
    final collection = _cartCollection;
    if (collection == null) throw Exception('User not authenticated');

    final batch = _firestore.batch();
    final snapshots = await collection.get();

    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
