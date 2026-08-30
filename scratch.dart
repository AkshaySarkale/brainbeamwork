import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final res = await http.get(Uri.parse('https://dummyjson.com/products?limit=200'));
  final data = jsonDecode(res.body);
  final products = data['products'] as List;
  final categories = products.map((p) => p['category']).toSet();
  print('Categories from products:');
  print(categories);
}
