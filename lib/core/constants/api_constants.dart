class ApiConstants {
  static const String baseUrl = 'https://dummyjson.com';

  static const String products = '$baseUrl/products';
  static const String productSearch = '$baseUrl/products/search';
  static const String categories = '$baseUrl/products/categories';
  static String productsByCategory(String category) =>
      '$baseUrl/products/category/$category';
}
