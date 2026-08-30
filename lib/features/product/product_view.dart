import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'product_controller.dart';
import '../category/category_controller.dart';
import '../../core/widgets/product_card.dart';

class ProductView extends StatefulWidget {
  const ProductView({super.key});

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  final ProductController controller = Get.find<ProductController>();
  final CategoryController catController = Get.isRegistered<CategoryController>() ? Get.find<CategoryController>() : Get.put(CategoryController());
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      controller.loadMoreProducts();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    controller.clearFilters();
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: controller.searchProducts,
            ),
          ),
          Obx(() {
            if (catController.categories.isEmpty) return const SizedBox.shrink();
            return SizedBox(
              height: 50,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: catController.categories.length + 1,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final isSelected = controller.selectedCategorySlug.value.isEmpty;
                    return ChoiceChip(
                      label: const Text('All'),
                      selected: isSelected,
                      onSelected: (_) => controller.clearFilters(),
                    );
                  }
                  final category = catController.categories[index - 1];
                  final isSelected = controller.selectedCategorySlug.value == category.slug;
                  return ChoiceChip(
                    label: Text(category.name),
                    selected: isSelected,
                    onSelected: (_) => controller.filterByCategory(category.slug),
                  );
                },
              ),
            );
          }),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(controller.errorMessage.value),
                      TextButton(
                        onPressed: controller.fetchInitialProducts,
                        child: const Text('Retry'),
                      )
                    ],
                  ),
                );
              }
              if (controller.products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No products found.'),
                      TextButton(
                        onPressed: () {
                          _searchController.clear();
                          controller.clearFilters();
                        },
                        child: const Text('Clear Filters'),
                      )
                    ],
                  ),
                );
              }
              return GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                itemCount: controller.products.length + (controller.isLoadingMore.value ? 2 : 0),
                itemBuilder: (context, index) {
                  if (index < controller.products.length) {
                    return ProductCard(product: controller.products[index]);
                  }
                  // Render loading indicator in the grid space
                  return const Center(child: CircularProgressIndicator());
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
