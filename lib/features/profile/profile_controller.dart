import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import '../auth/auth_controller.dart';
import '../../core/utils/app_utils.dart';
import '../../core/utils/firebase_errors.dart';

class ProfileController extends GetxController {
  final UserRepository _userRepo = Get.find<UserRepository>();

  final Rx<UserModel?> userModel = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    ever(Get.find<AuthController>().firebaseUser, (user) {
      if (user != null) {
        fetchProfile();
      } else {
        userModel.value = null;
      }
    });

    if (Get.find<AuthController>().firebaseUser.value != null) {
      fetchProfile();
    }
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      userModel.value = await _userRepo.getCurrentUser();
    } catch (e) {
      errorMessage.value = 'Failed to load profile data.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile({required String name, String? phone}) async {
    try {
      isUpdating.value = true;
      await _userRepo.updateProfile(name: name, phone: phone);

      // Also update Auth Display Name
      try {
        await FirebaseAuth.instance.currentUser?.updateDisplayName(name);
      } catch (_) {}

      await fetchProfile(); // Reload
      AppUtils.showSnackbar('Success', 'Profile updated successfully.');
      Get.back();
    } catch (e) {
      AppUtils.showSnackbar(
        'Error',
        'Failed to update profile.',
        isError: true,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;

    try {
      isUpdating.value = true;

      // Re-authenticate
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);

      // Update password
      await user.updatePassword(newPassword);

      AppUtils.showSnackbar('Success', 'Password changed successfully.');
      Get.back();
    } catch (e) {
      AppUtils.showSnackbar(
        'Error',
        FirebaseErrors.getMessage(e),
        isError: true,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> logout() async {
    Get.defaultDialog(
      title: 'Logout?',
      middleText: 'Are you sure you want to logout?',
      textCancel: 'Cancel',
      textConfirm: 'Logout',
      confirmTextColor: Get.theme.colorScheme.onPrimary,
      onConfirm: () async {
        Get.back();
        await Get.find<AuthController>().logout();
      },
    );
  }
}
