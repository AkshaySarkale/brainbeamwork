import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopora/features/product/product_controller.dart';
import 'package:shopora/features/category/category_controller.dart';
import 'package:shopora/core/widgets/product_card.dart';
import 'package:shopora/app/theme/app_colors.dart';

class ProductView extends StatefulWidget {
  const ProductView({super.key});

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  final ProductController controller = Get.find<ProductController>();
  final CategoryController catController =
      Get.isRegistered<CategoryController>()
      ? Get.find<CategoryController>()
      : Get.put(CategoryController());
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Sync with route parameters to ensure fresh state if controller persists
    final categoryId = Get.parameters['categoryId'];
    if (categoryId != null && categoryId.isNotEmpty) {
      controller.selectedCategorySlug.value = categoryId;
    } else if (Get.parameters.containsKey('categoryId') || Get.parameters.containsKey('search')) {
      // If we routed here with parameters, ensure we clear the old ones if not present
      if (categoryId == null || categoryId.isEmpty) controller.selectedCategorySlug.value = '';
    }

    final searchParam = Get.parameters['search'];
    if (searchParam != null && searchParam.isNotEmpty) {
      controller.searchQuery.value = searchParam;
    } else if (Get.parameters.containsKey('categoryId') || Get.parameters.containsKey('search')) {
      if (searchParam == null || searchParam.isEmpty) controller.searchQuery.value = '';
    }

    _searchController.text = controller.searchQuery.value;
    
    // Apply filters immediately in case products are already loaded from previous visits
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.allProducts.isNotEmpty) {
        controller.applyFilters();
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      controller.loadMoreProducts();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Sort By',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              _buildSortTile('Relevance', SortOption.relevance),
              _buildSortTile('Price: Low to High', SortOption.priceLowToHigh),
              _buildSortTile('Price: High to Low', SortOption.priceHighToLow),
              _buildSortTile('Rating', SortOption.ratingHighToLow),
              _buildSortTile('Name: A → Z', SortOption.nameAToZ),
              _buildSortTile('Name: Z → A', SortOption.nameZToA),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortTile(String title, SortOption option) {
    return ListTile(
      title: Text(title),
      trailing: Obx(
        () => controller.selectedSort.value == option
            ? const Icon(Icons.check, color: AppColors.primary)
            : const SizedBox.shrink(),
      ),
      onTap: () {
        controller.sortProducts(option);
        Get.back();
      },
    );
  }

  void _showFilterSheet(BuildContext context) {
    // Temporary State
    String tempCategory = controller.selectedCategorySlug.value;
    double tempMinPrice = controller.selectedMinPrice.value;
    double tempMaxPrice = controller.selectedMaxPrice.value;
    double tempRating = controller.selectedMinRating.value;
    bool tempInStock = controller.inStockOnly.value;

    double sliderMin = controller.minPrice.value;
    double sliderMax = controller.maxPrice.value;
    if (sliderMin >= sliderMax)
      sliderMax = sliderMin + 1; // Prevent crash if min == max

    if (tempMinPrice < sliderMin) tempMinPrice = sliderMin;
    if (tempMaxPrice > sliderMax) tempMaxPrice = sliderMax;
    if (tempMinPrice > tempMaxPrice) tempMinPrice = tempMaxPrice;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return FractionallySizedBox(
              heightFactor: 0.85,
              child: SafeArea(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          // Category
                          const Text(
                            'Category',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<String>(
                              value: tempCategory.isEmpty ? null : tempCategory,
                              hint: const Text('All Categories'),
                              isExpanded: true,
                              underline: const SizedBox(),
                              items: [
                                const DropdownMenuItem(
                                  value: '',
                                  child: Text('All'),
                                ),
                                ...catController.categories.map((cat) {
                                  return DropdownMenuItem(
                                    value: cat.slug,
                                    child: Text(cat.name),
                                  );
                                }),
                              ],
                              onChanged: (val) =>
                                  setState(() => tempCategory = val ?? ''),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Price
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Price Range',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '₹${tempMinPrice.toInt()} - ₹${tempMaxPrice.toInt()}',
                              ),
                            ],
                          ),
                          RangeSlider(
                            values: RangeValues(tempMinPrice, tempMaxPrice),
                            min: sliderMin,
                            max: sliderMax,
                            activeColor: AppColors.primary,
                            onChanged: (RangeValues values) {
                              setState(() {
                                tempMinPrice = values.start;
                                tempMaxPrice = values.end;
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          // Rating
                          const Text(
                            'Minimum Rating',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [0.0, 4.0, 3.0, 2.0, 1.0].map((rating) {
                              return ChoiceChip(
                                label: Text(
                                  rating == 0.0 ? 'All' : '⭐ $rating+',
                                ),
                                selected: tempRating == rating,
                                onSelected: (selected) {
                                  if (selected)
                                    setState(() => tempRating = rating);
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),

                          // Availability
                          const Text(
                            'Availability',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('In Stock Only'),
                            value: tempInStock,
                            activeThumbColor: AppColors.primary,
                            onChanged: (val) =>
                                setState(() => tempInStock = val),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  tempCategory = '';
                                  tempMinPrice = sliderMin;
                                  tempMaxPrice = sliderMax;
                                  tempRating = 0.0;
                                  tempInStock = false;
                                });
                              },
                              child: const Text('Reset'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                controller.selectedCategorySlug.value =
                                    tempCategory;
                                controller.selectedMinPrice.value =
                                    tempMinPrice;
                                controller.selectedMaxPrice.value =
                                    tempMaxPrice;
                                controller.selectedMinRating.value = tempRating;
                                controller.inStockOnly.value = tempInStock;
                                controller.applyFilters();
                                Get.back();
                              },
                              child: const Text('Apply Filters'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2EAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Products',
          style: TextStyle(fontFamily: 'serif', fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Obx(() {
              // Ensure text syncs if cleared from outside
              if (controller.searchQuery.value != _searchController.text) {
                // Ignore cursor movement sync issues by only updating if entirely different via clear
                if (controller.searchQuery.value.isEmpty) {
                  _searchController.clear();
                }
              }
              return TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            controller.searchProducts('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: controller.searchProducts,
              );
            }),
          ),

          // Filter & Sort Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.filter_list, size: 18),
                    label: Obx(
                      () => Text(
                        controller.activeFilterCount > 0
                            ? 'Filter (${controller.activeFilterCount})'
                            : 'Filter',
                      ),
                    ),
                    onPressed: () => _showFilterSheet(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.sort, size: 18),
                    label: const Text('Sort ↕'),
                    onPressed: () => _showSortSheet(context),
                  ),
                ),
              ],
            ),
          ),

          // Active Filters Chips
          Obx(() {
            final activeChips = <Widget>[];

            if (controller.selectedCategorySlug.value.isNotEmpty) {
              final cat = catController.categories.firstWhereOrNull(
                (c) => c.slug == controller.selectedCategorySlug.value,
              );
              if (cat != null) {
                activeChips.add(
                  InputChip(
                    label: Text(cat.name),
                    onDeleted: () {
                      controller.selectedCategorySlug.value = '';
                      controller.applyFilters();
                    },
                  ),
                );
              }
            }

            if (controller.selectedMinPrice.value > controller.minPrice.value ||
                controller.selectedMaxPrice.value < controller.maxPrice.value) {
              activeChips.add(
                InputChip(
                  label: Text(
                    '₹${controller.selectedMinPrice.value.toInt()} - ₹${controller.selectedMaxPrice.value.toInt()}',
                  ),
                  onDeleted: () {
                    controller.selectedMinPrice.value =
                        controller.minPrice.value;
                    controller.selectedMaxPrice.value =
                        controller.maxPrice.value;
                    controller.applyFilters();
                  },
                ),
              );
            }

            if (controller.selectedMinRating.value > 0) {
              activeChips.add(
                InputChip(
                  label: Text('${controller.selectedMinRating.value}+ ⭐'),
                  onDeleted: () {
                    controller.selectedMinRating.value = 0.0;
                    controller.applyFilters();
                  },
                ),
              );
            }

            if (controller.inStockOnly.value) {
              activeChips.add(
                InputChip(
                  label: const Text('In Stock'),
                  onDeleted: () {
                    controller.inStockOnly.value = false;
                    controller.applyFilters();
                  },
                ),
              );
            }

            if (activeChips.isEmpty) return const SizedBox.shrink();

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const Text(
                      'Active: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ...activeChips.map(
                      (chip) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: chip,
                      ),
                    ),
                    TextButton(
                      onPressed: controller.clearFilters,
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              ),
            );
          }),

          // Results Count
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Obx(() {
                if (controller.isLoading.value) return const SizedBox.shrink();
                return Text(
                  '${controller.filteredProducts.length} products',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                );
              }),
            ),
          ),

          // Product Grid
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
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: controller.fetchInitialProducts,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              if (controller.products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      if (controller.searchQuery.value.isNotEmpty)
                        Text(
                          'No products found for "${controller.searchQuery.value}".',
                        )
                      else
                        const Text('No products found.'),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: controller.clearFilters,
                        child: const Text('Clear Filters'),
                      ),
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
                itemCount:
                    controller.products.length +
                    (controller.isLoadingMore.value ? 2 : 0),
                itemBuilder: (context, index) {
                  if (index < controller.products.length) {
                    return ProductCard(product: controller.products[index]);
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              );
            }),
          ),
        ],
      ),
      ),
    );
  }
}
