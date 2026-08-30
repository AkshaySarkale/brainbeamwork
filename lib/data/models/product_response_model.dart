import 'product_model.dart';

class ProductResponseModel {
  final List<ProductModel> products;
  final int total;
  final int skip;
  final int limit;

  ProductResponseModel({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory ProductResponseModel.fromJson(Map<String, dynamic> json) {
    return ProductResponseModel(
      products: (json['products'] as List<dynamic>?)
              ?.map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] is int ? json['total'] : int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      skip: json['skip'] is int ? json['skip'] : int.tryParse(json['skip']?.toString() ?? '0') ?? 0,
      limit: json['limit'] is int ? json['limit'] : int.tryParse(json['limit']?.toString() ?? '0') ?? 0,
    );
  }
}
