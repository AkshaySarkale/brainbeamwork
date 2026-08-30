import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopora/app/theme/app_text_styles.dart';
import 'package:shopora/app/theme/app_colors.dart';
import 'package:shopora/features/auth/auth_controller.dart';
import 'package:shopora/features/category/category_controller.dart';
import 'package:shopora/features/cart/cart_controller.dart';
import 'package:shopora/features/wishlist/wishlist_controller.dart';
import 'package:shopora/features/profile/profile_controller.dart';
import 'package:shopora/features/notification/notification_controller.dart';
import 'package:shopora/data/repositories/product_repository.dart';
import 'package:shopora/data/models/product_model.dart';
import 'package:shopora/core/widgets/product_card.dart';
import 'package:shopora/core/widgets/shimmer_loading.dart';
import 'package:shopora/core/widgets/app_empty_state.dart';
import 'package:shopora/app/routes/app_routes.dart';
import 'package:shopora/features/category/category_view.dart';
import 'package:shopora/features/cart/cart_view.dart';
import 'package:shopora/features/profile/profile_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final CategoryController catController =
      Get.isRegistered<CategoryController>()
          ? Get.find<CategoryController>()
          : Get.put(CategoryController());
  final AuthController auth = AuthController.instance;

  bool isLoadingFeatured = true;
  List<ProductModel> featuredProducts = [];
  
  String? selectedCategorySlug;
  bool isLoadingCategoryProducts = false;
  List<ProductModel> categoryProducts = [];
  
  final TextEditingController _searchController = TextEditingController();
  bool isSearching = false;
  bool isLoadingSearch = false;
  List<ProductModel> searchResults = [];
  Timer? _debounce;
  
  int _selectedIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadFeaturedProducts();
  }

  Future<void> _loadFeaturedProducts() async {
    try {
      final repo = Get.isRegistered<ProductRepository>()
          ? Get.find<ProductRepository>()
          : ProductRepository();
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

  void _onCategoryTapped(String slug) async {
    if (selectedCategorySlug == slug) {
      setState(() {
        selectedCategorySlug = null;
      });
      return;
    }

    setState(() {
      selectedCategorySlug = slug;
      isLoadingCategoryProducts = true;
    });

    try {
      final repo = Get.isRegistered<ProductRepository>()
          ? Get.find<ProductRepository>()
          : ProductRepository();
      final response = await repo.getProductsByCategory(category: slug, limit: 6);
      if (mounted) {
        setState(() {
          categoryProducts = response.products;
          isLoadingCategoryProducts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoadingCategoryProducts = false);
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (query.trim().isEmpty) {
      setState(() {
        isSearching = false;
        searchResults = [];
      });
      return;
    }

    setState(() {
      isSearching = true;
      isLoadingSearch = true;
    });

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final repo = Get.isRegistered<ProductRepository>()
            ? Get.find<ProductRepository>()
            : ProductRepository();
        final response = await repo.searchProducts(query: query.trim(), limit: 10);
        if (mounted) {
          setState(() {
            searchResults = response.products;
            isLoadingSearch = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => isLoadingSearch = false);
        }
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  IconData _getCategoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('beauty') || lower.contains('makeup')) return Icons.face;
    if (lower.contains('fragrance') || lower.contains('perfume')) return Icons.air;
    if (lower.contains('furniture')) return Icons.chair;
    if (lower.contains('grocer')) return Icons.local_grocery_store;
    if (lower.contains('home')) return Icons.home;
    if (lower.contains('shoe') || lower.contains('sneaker')) return Icons.do_not_step; // fallback
    if (lower.contains('cloth') || lower.contains('shirt')) return Icons.checkroom;
    return Icons.category_outlined;
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  Widget _buildHomeContent() {
    return Scaffold(
      backgroundColor: const Color(0xFFF2EAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            'Shopora',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              fontFamily: 'serif',
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
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                final profileCtrl = Get.find<ProfileController>();
                final name =
                    profileCtrl.userModel.value?.name ??
                    auth.firebaseUser.value?.displayName;
                final display = (name != null && name.isNotEmpty)
                    ? name
                    : 'Guest';
                return Text(
                  '${_getGreeting()}, $display 👋',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A24),
                    letterSpacing: -0.5,
                  ),
                );
              }),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                    icon: Icon(Icons.search, color: Colors.grey.shade400, size: 22),
                    border: InputBorder.none,
                    suffixIcon: isSearching ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                        FocusScope.of(context).unfocus();
                      },
                    ) : null,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              if (isSearching) ...[
                const Text('Search Results', 
                  style: TextStyle(
                    fontSize: 22, 
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A24),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                if (isLoadingSearch)
                  const ProductShimmerGrid()
                else if (searchResults.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: AppEmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No results found',
                      message: 'We couldn\'t find any products matching your search. Try different keywords.',
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      return ProductCard(product: searchResults[index]);
                    },
                  ),
              ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Categories', 
                    style: TextStyle(
                      fontSize: 22, 
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A24),
                      letterSpacing: -0.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _onItemTapped(1),
                    child: Text(
                      'See All',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 110,
                child: Obx(() {
                  if (catController.isLoading.value) {
                    return const CategoryShimmerList();
                  }
                  if (catController.categories.isEmpty) {
                    return const Center(
                      child: Text('No categories available.'),
                    );
                  }
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: catController.categories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 20),
                    itemBuilder: (context, index) {
                      final category = catController.categories[index];
                      final isSelected = selectedCategorySlug == category.slug;
                      return GestureDetector(
                        onTap: () => _onCategoryTapped(category.slug),
                        child: Column(
                          children: [
                            Container(
                              height: 64,
                              width: 64,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : const Color(0xFFEFEAF6),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.5),
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                _getCategoryIcon(category.name),
                                size: 28,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              category.name,
                              style: TextStyle(
                                fontSize: 13,
                                color: isSelected ? AppColors.primary : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedCategorySlug != null ? 'Category Products' : 'Popular Products', 
                    style: const TextStyle(
                      fontSize: 22, 
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A24),
                      letterSpacing: -0.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (selectedCategorySlug != null) {
                        Get.toNamed('${AppRoutes.products}?categoryId=$selectedCategorySlug');
                      } else {
                        Get.toNamed(AppRoutes.products);
                      }
                    },
                    child: Text(
                      'See All',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Builder(builder: (context) {
                final isLoading = selectedCategorySlug != null ? isLoadingCategoryProducts : isLoadingFeatured;
                final items = selectedCategorySlug != null ? categoryProducts : featuredProducts;

                if (isLoading) {
                  return const ProductShimmerGrid();
                } else if (items.isEmpty) {
                  return const Center(child: Text('No products available.'));
                } else {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return ProductCard(product: items[index]);
                    },
                  );
                }
              }),
              ],
            ],
          ),
        ),
      ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeContent(),
          const CategoryView(),
          const CartView(),
          const ProfileView(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey.shade500,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.home),
              ),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.grid_view_outlined),
              ),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_bag_outlined),
                    Obx(() {
                      if (!Get.isRegistered<CartController>()) return const SizedBox.shrink();
                      final cartController = Get.find<CartController>();
                      if (cartController.totalItemCount == 0) return const SizedBox.shrink();
                      
                      return Positioned(
                        right: -6,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${cartController.totalItemCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              label: 'Cart',
            ),
            const BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.person_outline),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
