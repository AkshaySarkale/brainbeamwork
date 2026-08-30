import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopora/features/category/category_controller.dart';
import 'package:shopora/app/routes/app_routes.dart';
import 'package:shopora/app/theme/app_text_styles.dart';
import 'package:shopora/app/theme/app_colors.dart';
import 'package:shopora/core/widgets/shimmer_loading.dart';
import 'package:shopora/features/notification/notification_controller.dart';

class CategoryView extends GetView<CategoryController> {
  const CategoryView({super.key});

  IconData _getCategoryIcon(String categoryName) {
    final lower = categoryName.toLowerCase();
    if (lower.contains('electronics') || lower.contains('phone')) return Icons.devices_other;
    if (lower.contains('jewel') || lower.contains('ring')) return Icons.diamond_outlined;
    if (lower.contains('men') || lower.contains('boy')) return Icons.face;
    if (lower.contains('women') || lower.contains('girl')) return Icons.face_3;
    if (lower.contains('beauty') || lower.contains('makeup')) return Icons.auto_awesome;
    if (lower.contains('fragrance') || lower.contains('perfume')) return Icons.air;
    if (lower.contains('furniture') || lower.contains('home')) return Icons.chair_outlined;
    if (lower.contains('grocer') || lower.contains('food')) return Icons.local_grocery_store_outlined;
    if (lower.contains('shoe') || lower.contains('foot')) return Icons.do_not_step;
    if (lower.contains('watch')) return Icons.watch_outlined;
    if (lower.contains('bag') || lower.contains('luggage')) return Icons.shopping_bag_outlined;
    if (lower.contains('cloth') || lower.contains('shirt')) return Icons.checkroom;
    return Icons.category_outlined;
  }

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
            'Categories',
            style: TextStyle(fontFamily: 'serif', fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
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
          if (controller.isLoading.value) {
            return const CategoryGridShimmer();
          }
          if (controller.errorMessage.value.isNotEmpty) {
            return Center(child: Text(controller.errorMessage.value));
          }
          if (controller.categories.isEmpty) {
            return const Center(child: Text('No categories found.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
            ),
            itemCount: controller.categories.length,
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              return GestureDetector(
                onTap: () => Get.toNamed(
                  '${AppRoutes.products}?categoryId=${category.slug}',
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getCategoryIcon(category.name),
                          size: 36,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          category.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
