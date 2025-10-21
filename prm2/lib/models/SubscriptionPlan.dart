// lib/models/SubscriptionPlan.dart
import 'package:intl/intl.dart';

class SubscriptionPlan {
  final String id;
  final String name;
  final String displayName;
  final String? description;
  final bool isActive;

  // --- THÊM TRƯỜNG NÀY VÀO ---
  final String? featureConfig;

  final String currency;
  final int billingPeriodCount;
  final int billingPeriodUnit;
  final String billingPeriodUnitName;
  final double amount;
  final int? trialDays;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.displayName,
    this.description,
    required this.isActive,

    // --- THÊM VÀO CONSTRUCTOR ---
    this.featureConfig,

    required this.currency,
    required this.billingPeriodCount,
    required this.billingPeriodUnit,
    required this.billingPeriodUnitName,
    required this.amount,
    this.trialDays,
    required this.createdAt,
    this.updatedAt,
  });

  String get formattedCreatedAt => DateFormat('dd/MM/yyyy').format(createdAt);

  String get formattedAmount {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return format.format(amount);
  }

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      displayName: json['displayName'] ?? 'N/A',
      description: json['description'],
      isActive: json['isActive'] ?? false,

      // --- THÊM PARSING TỪ JSON ---
      featureConfig: json['featureConfig'],

      currency: json['currency'] ?? 'VND',
      billingPeriodCount: json['billingPeriodCount'] ?? 1,
      billingPeriodUnit: json['billingPeriodUnit'] ?? 1,
      billingPeriodUnitName: json['billingPeriodUnitName'] ?? 'Month',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      trialDays: json['trialDays'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}