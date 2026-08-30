import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shopora/data/models/user_model.dart';
import 'package:shopora/data/repositories/auth_repository.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthRepository _authRepo = Get.find<AuthRepository>();

  String? get _userId => _authRepo.getCurrentUser()?.uid;

  Future<UserModel?> getCurrentUser() async {
    final uid = _userId;
    if (uid == null) return null;

    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  Future<void> updateProfile({required String name, String? phone}) async {
    final uid = _userId;
    if (uid == null) throw Exception('User not authenticated');

    final updateData = <String, dynamic>{
      'name': name,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (phone != null) {
      updateData['phone'] = phone;
    } else {
      updateData['phone'] = FieldValue.delete();
    }

    await _firestore.collection('users').doc(uid).update(updateData);
  }
}
