import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/address_model.dart';
import 'auth_repository.dart';

class AddressRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthRepository _authRepo = Get.find<AuthRepository>();

  String? get _userId => _authRepo.getCurrentUser()?.uid;

  CollectionReference<Map<String, dynamic>>? get _addressCollection {
    final uid = _userId;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('addresses');
  }

  Future<List<AddressModel>> getAddresses() async {
    final collection = _addressCollection;
    if (collection == null) return [];

    final snapshot = await collection
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => AddressModel.fromFirestore(doc)).toList();
  }

  Future<void> addAddress(AddressModel address) async {
    final collection = _addressCollection;
    if (collection == null) throw Exception('User not authenticated');

    await collection.add(address.toFirestore());
  }

  Future<void> updateAddress(AddressModel address) async {
    final collection = _addressCollection;
    if (collection == null) throw Exception('User not authenticated');

    await collection.doc(address.id).update(address.toFirestore());
  }

  Future<void> deleteAddress(String addressId) async {
    final collection = _addressCollection;
    if (collection == null) throw Exception('User not authenticated');

    await collection.doc(addressId).delete();
  }

  Future<void> setDefaultAddress(String addressId) async {
    final collection = _addressCollection;
    if (collection == null) throw Exception('User not authenticated');

    final batch = _firestore.batch();

    // Unset current default
    final currentDefaults = await collection
        .where('isDefault', isEqualTo: true)
        .get();
    for (var doc in currentDefaults.docs) {
      batch.update(doc.reference, {'isDefault': false});
    }

    // Set new default
    batch.update(collection.doc(addressId), {'isDefault': true});

    await batch.commit();
  }
}
