import 'package:intl/intl.dart';

class PaymentMethodDetail {
  final String id;
  final String name;
  final String description;
  final String typeName;
  final String providerName;
  final String configuration;
  final String status;
  final DateTime createdAt;
  final String? createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;

  PaymentMethodDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.typeName,
    required this.providerName,
    required this.configuration,
    required this.status,
    required this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
  });

  String get formattedCreatedAt => DateFormat('dd MMM yyyy, HH:mm').format(createdAt);
  String get formattedUpdatedAt => updatedAt != null ? DateFormat('dd MMM yyyy, HH:mm').format(updatedAt!) : 'Chưa có cập nhật';

  factory PaymentMethodDetail.fromJson(Map<String, dynamic> json) {
    return PaymentMethodDetail(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'N/A',
      description: json['description'] as String? ?? '',
      typeName: json['typeName'] as String? ?? 'N/A',
      providerName: json['providerName'] as String? ?? 'N/A',
      configuration: json['configuration'] as String? ?? '{}',
      status: json['status'] as String? ?? 'Inactive',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      createdBy: json['createdBy'] as String?,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
      updatedBy: json['updatedBy'] as String?,
    );
  }
}
