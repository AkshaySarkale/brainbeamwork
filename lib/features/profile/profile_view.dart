import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profile_controller.dart';
import '../auth/auth_controller.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/theme/app_colors.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Obx(() {
        if (controller.isLoading.value && controller.userModel.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = controller.userModel.value;
        final fbUser = Get.find<AuthController>().firebaseUser.value;

        final name = user?.name ?? fbUser?.displayName ?? 'User';
        final email = user?.email ?? fbUser?.email ?? 'No email available';
        final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary,
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(name, style: AppTextStyles.heading2),
              const SizedBox(height: 4),
              Text(email, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),

              // Account Section
              _buildSectionHeader('ACCOUNT'),
              _buildListTile(
                Icons.person_outline,
                'Edit Profile',
                () => Get.toNamed(AppRoutes.editProfile),
              ),
              _buildListTile(
                Icons.inventory_2_outlined,
                'My Orders',
                () => Get.toNamed(AppRoutes.orders),
              ),
              _buildListTile(
                Icons.location_on_outlined,
                'My Addresses',
                () => Get.toNamed(AppRoutes.addresses),
              ),
              _buildListTile(
                Icons.favorite_outline,
                'Wishlist',
                () => Get.toNamed(AppRoutes.wishlist),
              ),

              const SizedBox(height: 24),

              // Security Section
              _buildSectionHeader('SECURITY'),
              _buildListTile(
                Icons.lock_outline,
                'Change Password',
                () => Get.toNamed(AppRoutes.changePassword),
              ),

              const SizedBox(height: 24),

              // Logout Section
              _buildSectionHeader('ACCOUNT'),
              _buildListTile(
                Icons.logout,
                'Logout',
                () => controller.logout(),
                isDestructive: true,
              ),

              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0, left: 4),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.red : Colors.black87),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
