import 'package:get/get.dart';
import '../../core/services/firebase_service.dart';
import '../../features/auth/auth_binding.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(FirebaseService(), permanent: true);
    AuthBinding().dependencies();
  }
}
