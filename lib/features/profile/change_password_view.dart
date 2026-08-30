import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profile_controller.dart';
import '../../core/widgets/app_text_field.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final ProfileController controller = Get.find<ProfileController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _changePassword() {
    if (_formKey.currentState?.validate() ?? false) {
      controller.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Current Password',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              AppTextField(
                hintText: 'Enter current password',
                controller: _currentPasswordController,
                obscureText: true,
                validator: (val) {
                  if (val == null || val.isEmpty)
                    return 'Current password is required';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'New Password',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              AppTextField(
                hintText: 'Enter new password',
                controller: _newPasswordController,
                obscureText: true,
                validator: (val) {
                  if (val == null || val.length < 6)
                    return 'Password must be at least 6 characters.';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Confirm New Password',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              AppTextField(
                hintText: 'Re-enter new password',
                controller: _confirmPasswordController,
                obscureText: true,
                validator: (val) {
                  if (val != _newPasswordController.text)
                    return 'New passwords do not match.';
                  return null;
                },
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: Obx(() {
                  if (controller.isUpdating.value) {
                    return const ElevatedButton(
                      onPressed: null,
                      child: CircularProgressIndicator(),
                    );
                  }
                  return ElevatedButton(
                    onPressed: _changePassword,
                    child: const Text('Change Password'),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
