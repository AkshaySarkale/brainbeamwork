import 'dart:async';
import 'package:get/get.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

enum SortOption {
  relevance,
  priceLowToHigh,
  priceHighToLow,
  ratingHighToLow,
  nameAToZ,
  nameZToA,
}

class ProductController extends GetxController {
  final ProductRepository _repository = Get.find<ProductRepository>();

  List<ProductModel> allProducts = [];
  List<ProductModel> filteredProducts = [];

  final RxList<ProductModel> products = <ProductModel>[].obs;

  // Filters
  final RxString selectedCategorySlug = ''.obs;
  final RxString searchQuery = ''.obs;

  final RxDouble minPrice = 0.0.obs;
  final RxDouble maxPrice = 0.0.obs;
  final RxDouble selectedMinPrice = 0.0.obs;
  final RxDouble selectedMaxPrice = 0.0.obs;

  final RxDouble selectedMinRating = 0.0.obs;
  final RxBool inStockOnly = false.obs;
  final Rx<SortOption> selectedSort = SortOption.relevance.obs;

  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;

  int _skip = 0;
  final int _limit = 10;
  Timer? _debounce;

  bool get hasMore => _skip < filteredProducts.length;

  int get activeFilterCount {
    int count = 0;
    if (selectedCategorySlug.value.isNotEmpty) count++;
    if (selectedMinPrice.value > minPrice.value ||
        selectedMaxPrice.value < maxPrice.value)
      count++;
    if (selectedMinRating.value > 0.0) count++;
    if (inStockOnly.value) count++;
    return count;
  }

  @override
  void onInit() {
    super.onInit();
    final initialCategory = Get.parameters['categoryId'];
    if (initialCategory != null && initialCategory.isNotEmpty) {
      selectedCategorySlug.value = initialCategory;
    }
    fetchInitialProducts();
  }

  Future<void> fetchInitialProducts() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _repository.getProducts(limit: 200, skip: 0);
      allProducts = response.products;

      if (allProducts.isNotEmpty) {
        minPrice.value = allProducts
            .map((p) => p.displayDiscountPrice)
            .reduce((a, b) => a < b ? a : b);
        maxPrice.value = allProducts
            .map((p) => p.displayDiscountPrice)
            .reduce((a, b) => a > b ? a : b);

        selectedMinPrice.value = minPrice.value;
        selectedMaxPrice.value = maxPrice.value;
      }

      applyFilters();
    } catch (e) {
      errorMessage.value = 'Unable to load products. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    _skip = 0;
    List<ProductModel> temp = List.from(allProducts);

    // 1. Category
    if (selectedCategorySlug.value.isNotEmpty) {
      temp = temp
          .where(
            (p) =>
                p.category.toLowerCase() ==
                selectedCategorySlug.value.toLowerCase(),
          )
          .toList();
    }

    // 2. Search
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      temp = temp
          .where(
            (p) =>
                p.title.toLowerCase().contains(query) ||
                p.description.toLowerCase().contains(query) ||
                p.category.toLowerCase().contains(query) ||
                p.brand.toLowerCase().contains(query),
          )
          .toList();
    }

    // 3. Price
    temp = temp
        .where(
          (p) =>
              p.displayDiscountPrice >= selectedMinPrice.value &&
              p.displayDiscountPrice <= selectedMaxPrice.value,
        )
        .toList();

    // 4. Rating
    if (selectedMinRating.value > 0) {
      temp = temp.where((p) => p.rating >= selectedMinRating.value).toList();
    }

    // 5. Stock
    if (inStockOnly.value) {
      temp = temp.where((p) => p.stock > 0).toList();
    }

    // 6. Sort
    switch (selectedSort.value) {
      case SortOption.priceLowToHigh:
        temp.sort(
          (a, b) => a.displayDiscountPrice.compareTo(b.displayDiscountPrice),
        );
        break;
      case SortOption.priceHighToLow:
        temp.sort(
          (a, b) => b.displayDiscountPrice.compareTo(a.displayDiscountPrice),
        );
        break;
      case SortOption.ratingHighToLow:
        temp.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.nameAToZ:
        temp.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOption.nameZToA:
        temp.sort((a, b) => b.title.compareTo(a.title));
        break;
      case SortOption.relevance:
        // Original order
        break;
    }

    filteredProducts = temp;
    products.assignAll(filteredProducts.take(_limit));
    _skip = _limit;
  }

  void loadMoreProducts() {
    if (isLoadingMore.value || !hasMore || isLoading.value) return;

    isLoadingMore.value = true;
    final nextChunk = filteredProducts.skip(_skip).take(_limit);
    products.addAll(nextChunk);
    _skip += _limit;
    isLoadingMore.value = false;
  }

  void filterByCategory(String categorySlug) {
    if (selectedCategorySlug.value == categorySlug) {
      selectedCategorySlug.value = '';
    } else {
      selectedCategorySlug.value = categorySlug;
    }
    applyFilters();
  }

  void searchProducts(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      searchQuery.value = query;
      applyFilters();
    });
  }

  void setPriceRange(double min, double max) {
    selectedMinPrice.value = min;
    selectedMaxPrice.value = max;
    applyFilters();
  }

  void setMinimumRating(double rating) {
    selectedMinRating.value = rating;
    applyFilters();
  }

  void setInStockOnly(bool value) {
    inStockOnly.value = value;
    applyFilters();
  }

  void sortProducts(SortOption option) {
    selectedSort.value = option;
    applyFilters();
  }

  void clearFilters() {
    selectedCategorySlug.value = '';
    searchQuery.value = '';
    selectedMinPrice.value = minPrice.value;
    selectedMaxPrice.value = maxPrice.value;
    selectedMinRating.value = 0.0;
    inStockOnly.value = false;
    selectedSort.value = SortOption.relevance;
    applyFilters();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}
