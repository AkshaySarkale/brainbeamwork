import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistItemModel {
  final int productId;
  final String title;
  final double price;
  final String thumbnail;
  final DateTime? addedAt;

  WishlistItemModel({
    required this.productId,
    required this.title,
    required this.price,
    required this.thumbnail,
    this.addedAt,
  });

  factory WishlistItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return WishlistItemModel(
      productId: _parseInt(data['productId']) ?? int.tryParse(doc.id) ?? 0,
      title: data['title'] ?? '',
      price: _parseDouble(data['price']),
      thumbnail: data['thumbnail'] ?? '',
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
      'addedAt': addedAt != null
          ? Timestamp.fromDate(addedAt!)
          : FieldValue.serverTimestamp(),
    };
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
