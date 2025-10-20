import 'package:intl/intl.dart';

class PaymentMethod {
  final String id;
  final String name;
  final String description;
  final String typeName;
  final String providerName;
  final String status;
  final DateTime createdAt;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.typeName,
    required this.providerName,
    required this.status,
    required this.createdAt,
  });

  String get formattedCreatedAt => DateFormat('dd/MM/yyyy').format(createdAt);

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'N/A',
      description: json['description'] as String? ?? '',
      typeName: json['typeName'] as String? ?? 'N/A',
      providerName: json['providerName'] as String? ?? 'N/A',
      status: json['status'] as String? ?? 'Inactive',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
