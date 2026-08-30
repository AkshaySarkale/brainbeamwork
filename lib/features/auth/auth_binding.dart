import 'package:get/get.dart';
import 'package:shopora/data/repositories/auth_repository.dart';
import 'package:shopora/features/auth/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(() => AuthRepository(), fenix: true);
    Get.put(AuthController(), permanent: true);
  }
}
