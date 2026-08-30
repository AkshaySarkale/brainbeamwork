import 'package:cloud_firestore/cloud_firestore.dart';
import 'address_model.dart';

class OrderItemModel {
  final int productId;
  final String title;
  final String thumbnail;
  final double price;
  final int quantity;

  OrderItemModel({
    required this.productId,
    required this.title,
    required this.thumbnail,
    required this.price,
    required this.quantity,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      productId: map['productId'] ?? 0,
      title: map['title'] ?? '',
      thumbnail: map['thumbnail'] ?? '',
      price: _parseDouble(map['price']),
      quantity: map['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'title': title,
      'thumbnail': thumbnail,
      'price': price,
      'quantity': quantity,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return double.tryParse(value?.toString() ?? '0.0') ?? 0.0;
  }
}

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItemModel> items;
  final AddressModel shippingAddress;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final DateTime? createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.shippingAddress,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    this.createdAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    return OrderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      items: (data['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItemModel.fromMap(item as Map<String, dynamic>))
          .toList(),
      shippingAddress: AddressModel.fromMap(
        '',
        data['shippingAddress'] as Map<String, dynamic>? ?? {},
      ),
      subtotal: OrderItemModel._parseDouble(data['subtotal']),
      deliveryFee: OrderItemModel._parseDouble(data['deliveryFee']),
      total: OrderItemModel._parseDouble(data['total']),
      paymentMethod: data['paymentMethod'] ?? '',
      paymentStatus: data['paymentStatus'] ?? '',
      orderStatus: data['orderStatus'] ?? '',
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'shippingAddress': shippingAddress.toFirestore(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'orderStatus': orderStatus,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}


