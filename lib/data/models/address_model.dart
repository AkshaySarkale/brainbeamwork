import 'package:cloud_firestore/cloud_firestore.dart';

class AddressModel {
  final String id;
  final String fullName;
  final String phone;
  final String addressLine;
  final String city;
  final String state;
  final String postalCode;
  final String? landmark;
  final bool isDefault;
  final DateTime? createdAt;

  AddressModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.addressLine,
    required this.city,
    required this.state,
    required this.postalCode,
    this.landmark,
    this.isDefault = false,
    this.createdAt,
  });

  factory AddressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AddressModel.fromMap(doc.id, data);
  }

  factory AddressModel.fromMap(String id, Map<String, dynamic> data) {
    return AddressModel(
      id: id,
      fullName: data['fullName'] ?? '',
      phone: data['phone'] ?? '',
      addressLine: data['addressLine'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      postalCode: data['postalCode'] ?? '',
      landmark: data['landmark'],
      isDefault: data['isDefault'] ?? false,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'phone': phone,
      'addressLine': addressLine,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      if (landmark != null) 'landmark': landmark,
      'isDefault': isDefault,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  AddressModel copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? addressLine,
    String? city,
    String? state,
    String? postalCode,
    String? landmark,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      addressLine: addressLine ?? this.addressLine,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      landmark: landmark ?? this.landmark,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
