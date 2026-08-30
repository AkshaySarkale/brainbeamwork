import 'package:get/get.dart';
import '../../data/repositories/user_repository.dart';
import 'profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<UserRepository>()) {
      Get.lazyPut<UserRepository>(() => UserRepository(), fenix: true);
    }
    if (!Get.isRegistered<ProfileController>()) {
      Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    }
  }
}
