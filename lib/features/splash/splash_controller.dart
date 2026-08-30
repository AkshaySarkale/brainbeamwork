import 'package:get/get.dart';
import 'package:shopora/app/routes/app_routes.dart';
import 'package:shopora/core/constants/app_constants.dart';
import 'package:shopora/features/auth/auth_controller.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToHome();
  }

  void _navigateToHome() async {
    await Future.delayed(
      const Duration(seconds: AppConstants.splashDelaySeconds),
    );
    final authController = AuthController.instance;
    if (authController.firebaseUser.value != null) {
      Get.offNamed(AppRoutes.home);
    } else {
      Get.offNamed(AppRoutes.login);
    }
  }
}
