import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../core/constants/firebase_constants.dart';
import '../../core/services/firebase_service.dart';

class AuthRepository {
  final FirebaseAuth _auth = Get.find<FirebaseService>().auth;
  final FirebaseFirestore _firestore = Get.find<FirebaseService>().firestore;

  Future<UserCredential> login(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> register(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> createUserDocument(String uid, String name, String email) async {
    final now = FieldValue.serverTimestamp();
    await _firestore.collection(FirebaseConstants.usersCollection).doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'createdAt': now,
      'updatedAt': now,
    });
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
