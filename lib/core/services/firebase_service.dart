import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

class FirebaseService extends GetxService {
  // Instances of Firebase services
  FirebaseAuth get auth => FirebaseAuth.instance;
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  FirebaseStorage get storage => FirebaseStorage.instance;
  
  @override
  void onInit() {
    super.onInit();
    _verifyConnection();
  }

  Future<void> _verifyConnection() async {
    try {
      // Lightweight check to verify Firebase core is responsive
      final app = auth.app;
      Get.log('FirebaseService: Connected to Firebase App [${app.name}]');
    } catch (e) {
      Get.log('FirebaseService: Error verifying connection - $e', isError: true);
    }
  }
}
