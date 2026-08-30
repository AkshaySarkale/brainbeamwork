import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../auth/auth_controller.dart';
import '../category/category_controller.dart';
import '../cart/cart_controller.dart';
import '../wishlist/wishlist_controller.dart';
import '../profile/profile_controller.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/models/product_model.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../app/routes/app_routes.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final CategoryController catController = Get.isRegistered<CategoryController>() ? Get.find<CategoryController>() : Get.put(CategoryController());
  final AuthController auth = AuthController.instance;
  
  bool isLoadingFeatured = true;
  List<ProductModel> featuredProducts = [];

  @override
  void initState() {
    super.initState();
    _loadFeaturedProducts();
  }

  Future<void> _loadFeaturedProducts() async {
    try {
      final repo = Get.isRegistered<ProductRepository>() ? Get.find<ProductRepository>() : ProductRepository();
      final response = await repo.getProducts(limit: 6, skip: 0);
      if (mounted) {
        setState(() {
          featuredProducts = response.products;
          isLoadingFeatured = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoadingFeatured = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.favorite_border),
                Obx(() {
                  final wishlistCtrl = Get.find<WishlistController>();
                  if (wishlistCtrl.wishlistItems.isEmpty) return const SizedBox.shrink();
                  return Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        '${wishlistCtrl.wishlistItems.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }),
              ],
            ),
            onPressed: () => Get.toNamed(AppRoutes.wishlist),
          ),
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart),
                Obx(() {
                  final cartController = Get.find<CartController>();
                  if (cartController.totalItemCount == 0) return const SizedBox.shrink();
                  return Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        '${cartController.totalItemCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }),
              ],
            ),
            onPressed: () => Get.toNamed(AppRoutes.cart),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Get.toNamed(AppRoutes.profile),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                final profileCtrl = Get.find<ProfileController>();
                final name = profileCtrl.userModel.value?.name ?? auth.firebaseUser.value?.displayName;
                final display = (name != null && name.isNotEmpty) ? name : 'Guest';
                return Text(
                  'Good morning, $display 👋',
                  style: AppTextStyles.heading1,
                );
              }),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.products),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('Search products...', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Categories', style: AppTextStyles.heading2),
                  TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.categories),
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: Obx(() {
                  if (catController.isLoading.value) {
                    return const CategoryShimmerList();
                  }
                  if (catController.categories.isEmpty) {
                    return const Center(child: Text('No categories available.'));
                  }
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: catController.categories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final category = catController.categories[index];
                      return GestureDetector(
                        onTap: () => Get.toNamed('${AppRoutes.products}?categoryId=${category.slug}'),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: Colors.grey.shade200,
                              child: Text(category.name[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.grey)),
                            ),
                            const SizedBox(height: 8),
                            Text(category.name.length > 10 ? '${category.name.substring(0,8)}...' : category.name, style: AppTextStyles.bodyMedium),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Popular Products', style: AppTextStyles.heading2),
                  TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.products),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (isLoadingFeatured)
                const ProductShimmerGrid()
              else if (featuredProducts.isEmpty)
                const Center(child: Text('No products available.'))
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: featuredProducts.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: featuredProducts[index]);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
