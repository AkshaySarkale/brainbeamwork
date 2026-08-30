import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopora/core/widgets/app_button.dart';
import 'package:shopora/core/widgets/app_text_field.dart';
import 'package:shopora/features/auth/auth_controller.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final AuthController _authController = AuthController.instance;
  final TextEditingController _emailController = TextEditingController();

  void _sendResetEmail() {
    final email = _emailController.text.trim();
    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        'Error',
        'Please enter a valid email address.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    _authController.forgotPassword(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password?')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter your email address to receive a password reset link.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              AppTextField(hintText: 'Email', controller: _emailController),
              const SizedBox(height: 32),
              Obx(
                () => AppButton(
                  text: 'Send Reset Email',
                  isLoading: _authController.isLoading.value,
                  onPressed: _sendResetEmail,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
