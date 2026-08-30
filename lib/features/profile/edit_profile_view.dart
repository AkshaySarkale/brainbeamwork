import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profile_controller.dart';
import '../../core/widgets/app_text_field.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final ProfileController controller = Get.find<ProfileController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = controller.userModel.value;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone ?? '';
      _emailController.text = user.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      controller.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Full Name', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              AppTextField(
                hintText: 'Enter your full name',
                controller: _nameController,
                validator: (val) {
                  if (val == null || val.trim().length < 2) return 'Minimum 2 characters required';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text('Phone Number', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              AppTextField(
                hintText: 'Enter your phone number (optional)',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              AppTextField(
                hintText: 'Email',
                controller: _emailController,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8.0, left: 4),
                child: Text(
                  'Email cannot be changed here.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
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
                    onPressed: _saveChanges,
                    child: const Text('Save Changes'),
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
