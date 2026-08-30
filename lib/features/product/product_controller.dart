import 'dart:async';
import 'package:get/get.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

class ProductController extends GetxController {
  final ProductRepository _repository = Get.find<ProductRepository>();

  final RxList<ProductModel> products = <ProductModel>[].obs;
  
  final RxString selectedCategorySlug = ''.obs;
  final RxString searchQuery = ''.obs;
  
  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;

  int _skip = 0;
  final int _limit = 10;
  int _total = 0;
  
  Timer? _debounce;

  bool get hasMore => products.length < _total;

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
      _skip = 0;
      
      final response = await _fetchFromRepository();
      
      products.assignAll(response.products);
      _total = response.total;
      _skip += _limit;
    } catch (e) {
      errorMessage.value = 'Unable to load products. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreProducts() async {
    if (isLoadingMore.value || !hasMore || isLoading.value) return;

    try {
      isLoadingMore.value = true;
      
      final response = await _fetchFromRepository();
      
      products.addAll(response.products);
      _total = response.total;
      _skip += _limit;
    } catch (e) {
      // Don't show full screen error for pagination failure, maybe just a toast in a real app
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<dynamic> _fetchFromRepository() {
    if (searchQuery.value.trim().isNotEmpty) {
      return _repository.searchProducts(query: searchQuery.value.trim(), limit: _limit, skip: _skip);
    } else if (selectedCategorySlug.value.isNotEmpty) {
      return _repository.getProductsByCategory(category: selectedCategorySlug.value, limit: _limit, skip: _skip);
    } else {
      return _repository.getProducts(limit: _limit, skip: _skip);
    }
  }

  void filterByCategory(String categorySlug) {
    if (selectedCategorySlug.value == categorySlug) {
      selectedCategorySlug.value = ''; // Toggle off
    } else {
      selectedCategorySlug.value = categorySlug;
    }
    searchQuery.value = ''; // Clear search when changing category
    fetchInitialProducts();
  }

  void searchProducts(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      searchQuery.value = query;
      selectedCategorySlug.value = ''; // Clear category when searching
      fetchInitialProducts();
    });
  }

  void clearFilters() {
    selectedCategorySlug.value = '';
    searchQuery.value = '';
    fetchInitialProducts();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}
