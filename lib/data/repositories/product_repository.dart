import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shopora/core/constants/api_constants.dart';
import 'package:shopora/data/models/product_model.dart';
import 'package:shopora/data/models/product_response_model.dart';

class ProductRepository {
  Future<ProductResponseModel> getProducts({
    int limit = 10,
    int skip = 0,
  }) async {
    try {
      final url = '${ApiConstants.products}?limit=$limit&skip=$skip';
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return ProductResponseModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<ProductResponseModel> getProductsByCategory({
    required String category,
    int limit = 10,
    int skip = 0,
  }) async {
    try {
      final url =
          '${ApiConstants.productsByCategory(category)}?limit=$limit&skip=$skip';
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return ProductResponseModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load category products');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<ProductResponseModel> searchProducts({
    required String query,
    int limit = 10,
    int skip = 0,
  }) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url =
          '${ApiConstants.productSearch}?q=$encodedQuery&limit=$limit&skip=$skip';
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return ProductResponseModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to search products');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<ProductModel?> getProductById(int productId) async {
    try {
      final url = '${ApiConstants.products}/$productId';
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return ProductModel.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load product details');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
