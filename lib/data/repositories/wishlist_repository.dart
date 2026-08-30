import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/wishlist_item_model.dart';
import 'auth_repository.dart';

class WishlistRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthRepository _authRepo = Get.find<AuthRepository>();

  String? get _userId => _authRepo.getCurrentUser()?.uid;

  CollectionReference<Map<String, dynamic>>? get _wishlistCollection {
    final uid = _userId;
    if (uid == null) return null;
    return _firestore.collection('wishlists').doc(uid).collection('items');
  }

  Future<List<WishlistItemModel>> getWishlistItems() async {
    final collection = _wishlistCollection;
    if (collection == null) return [];

    final querySnapshot = await collection.orderBy('addedAt', descending: true).get();
    return querySnapshot.docs.map((doc) => WishlistItemModel.fromFirestore(doc)).toList();
  }

  Future<void> addToWishlist(WishlistItemModel item) async {
    final collection = _wishlistCollection;
    if (collection == null) throw Exception('User not authenticated');

    await collection.doc(item.productId.toString()).set(
      item.toFirestore(),
      SetOptions(merge: true),
    );
  }

  Future<void> removeFromWishlist(int productId) async {
    final collection = _wishlistCollection;
    if (collection == null) throw Exception('User not authenticated');

    await collection.doc(productId.toString()).delete();
  }

  Future<void> clearWishlist() async {
    final collection = _wishlistCollection;
    if (collection == null) throw Exception('User not authenticated');

    final batch = _firestore.batch();
    final snapshots = await collection.get();

    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<bool> isInWishlist(int productId) async {
    final collection = _wishlistCollection;
    if (collection == null) return false;

    final doc = await collection.doc(productId.toString()).get();
    return doc.exists;
  }
}
