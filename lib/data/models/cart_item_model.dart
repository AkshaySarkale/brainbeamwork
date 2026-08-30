import 'package:cloud_firestore/cloud_firestore.dart';

class CartItemModel {
  final int productId;
  final String title;
  final double price;
  final String thumbnail;
  final int quantity;
  final DateTime? addedAt;

  CartItemModel({
    required this.productId,
    required this.title,
    required this.price,
    required this.thumbnail,
    required this.quantity,
    this.addedAt,
  });

  factory CartItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return CartItemModel(
      productId: _parseInt(data['productId']) ?? int.tryParse(doc.id) ?? 0,
      title: data['title'] ?? '',
      price: _parseDouble(data['price']),
      thumbnail: data['thumbnail'] ?? '',
      quantity: _parseInt(data['quantity']) ?? 1,
      addedAt: data['addedAt'] is Timestamp
          ? (data['addedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'title': title,
      'price': price,
      'thumbnail': thumbnail,
      'quantity': quantity,
      'addedAt': addedAt != null ? Timestamp.fromDate(addedAt!) : FieldValue.serverTimestamp(),
    };
  }

  CartItemModel copyWith({
    int? productId,
    String? title,
    double? price,
    String? thumbnail,
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      title: title ?? this.title,
      price: price ?? this.price,
      thumbnail: thumbnail ?? this.thumbnail,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value?.toString() ?? '0.0') ?? 0.0;
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
