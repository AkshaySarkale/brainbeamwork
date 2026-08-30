import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../core/utils/app_utils.dart';
import '../../core/utils/firebase_errors.dart';
import '../../data/repositories/auth_repository.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();
  final AuthRepository _authRepo = Get.find<AuthRepository>();

  final RxBool isLoading = false.obs;
  final Rx<User?> firebaseUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    firebaseUser.value = _authRepo.getCurrentUser();
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      await _authRepo.login(email, password);
      firebaseUser.value = _authRepo.getCurrentUser();
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      AppUtils.showSnackbar(
        'Login Failed',
        FirebaseErrors.getMessage(e),
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      isLoading.value = true;
      UserCredential cred = await _authRepo.register(email, password);
      if (cred.user != null) {
        try {
          await _authRepo.createUserDocument(cred.user!.uid, name, email);
        } catch (_) {
          // Proceed even if Firestore fails due to permissions
        }
        await _authRepo.logout();
        firebaseUser.value = null;
        AppUtils.showSnackbar(
          'Success',
          'Account created successfully. Please login.',
        );
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      AppUtils.showSnackbar(
        'Registration Failed',
        FirebaseErrors.getMessage(e),
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      isLoading.value = true;
      await _authRepo.sendPasswordResetEmail(email);
      AppUtils.showSnackbar('Success', 'Password reset email sent.');
      Get.back();
    } catch (e) {
      AppUtils.showSnackbar(
        'Error',
        FirebaseErrors.getMessage(e),
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await _authRepo.logout();
      firebaseUser.value = null;
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      AppUtils.showSnackbar(
        'Logout Failed',
        FirebaseErrors.getMessage(e),
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
