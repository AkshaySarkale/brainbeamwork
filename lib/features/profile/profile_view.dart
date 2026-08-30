import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopora/features/profile/profile_controller.dart';
import 'package:shopora/features/auth/auth_controller.dart';
import 'package:shopora/app/routes/app_routes.dart';
import 'package:shopora/app/theme/app_colors.dart';
import 'package:shopora/core/widgets/shimmer_loading.dart';
import 'package:shopora/features/notification/notification_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2EAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            'My Profile',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none, color: Colors.black87, size: 26),
                Obx(() {
                  if (!Get.isRegistered<NotificationController>()) return const SizedBox.shrink();
                  final notifCtrl = Get.find<NotificationController>();
                  if (notifCtrl.unreadCount == 0) return const SizedBox.shrink();

                  return Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
            onPressed: () => Get.toNamed(AppRoutes.notifications),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black87, size: 26),
            onPressed: () => Get.toNamed(AppRoutes.wishlist),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black87, size: 26),
            onPressed: () => Get.toNamed(AppRoutes.profile),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.userModel.value == null) {
            return const ProfileShimmer();
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
                // Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              fontSize: 32,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => Get.toNamed(AppRoutes.editProfile),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit Profile'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Shopping Section
                _buildSectionHeader('SHOPPING'),
                _buildMenuGroup([
                  _buildMenuItem(
                    Icons.inventory_2_outlined,
                    'My Orders',
                    () => Get.toNamed(AppRoutes.orders),
                  ),
                  _buildMenuItem(
                    Icons.location_on_outlined,
                    'My Addresses',
                    () => Get.toNamed(AppRoutes.addresses),
                  ),
                  _buildMenuItem(
                    Icons.favorite_outline,
                    'Wishlist',
                    () => Get.toNamed(AppRoutes.wishlist),
                    showDivider: false,
                  ),
                ]),

                const SizedBox(height: 24),

                // Security Section
                _buildSectionHeader('SECURITY'),
                _buildMenuGroup([
                  _buildMenuItem(
                    Icons.lock_outline,
                    'Change Password',
                    () => Get.toNamed(AppRoutes.changePassword),
                    showDivider: false,
                  ),
                ]),

                const SizedBox(height: 24),

                // Logout Section
                _buildSectionHeader('ACCOUNT'),
                _buildMenuGroup([
                  _buildMenuItem(
                    Icons.logout,
                    'Logout',
                    () => controller.logout(),
                    isDestructive: true,
                    showDivider: false,
                  ),
                ]),

                const SizedBox(height: 40),
              ],
            ),
          );
        }),
      ),
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

  Widget _buildMenuGroup(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Column(children: items),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDestructive
                  ? Colors.red.withOpacity(0.1)
                  : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isDestructive ? Colors.red : Colors.black87,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isDestructive ? Colors.red : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: Colors.grey,
            size: 20,
          ),
          onTap: onTap,
        ),
        if (showDivider)
          const Divider(
            height: 1,
            indent: 56,
            endIndent: 16,
            color: Color(0xFFF0F0F0),
          ),
      ],
    );
  }
}
