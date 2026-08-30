import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/category_model.dart';

class CategoryRepository {
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConstants.categories))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => CategoryModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
