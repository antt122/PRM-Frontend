import 'package:intl/intl.dart';

/// Model đại diện cho một Gói Đăng Ký (Subscription Plan)
/// Dựa trên cấu trúc 'items' trong JSON response.
class SubscriptionPlan {
  final String id;
  final String name;
  final String displayName;
  final String? description;
  // *** Dùng String status theo API doc ***
  final String status;
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
    required this.status, // *** Dùng String
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

  /// Factory để parse JSON
  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      displayName: json['displayName'] ?? 'N/A',
      description: json['description'],
      // *** Parse 'status' (String)
      status: json['status'] ?? 'unknown',
      featureConfig: json['featureConfig'],
      currency: json['currency'] ?? 'VND',
      billingPeriodCount: json['billingPeriodCount'] ?? 1,
      billingPeriodUnit: json['billingPeriodUnit'] ?? 1,
      billingPeriodUnitName: json['billingPeriodUnitName'] ?? 'Month',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      trialDays: json['trialDays'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  // --- Helpers cho UI ---

  String get formattedCreatedAt => DateFormat('dd/MM/yyyy').format(createdAt);

  String get formattedAmount {
    // Định dạng tiền tệ dựa trên mã 'currency'
    final format = (currency == 'VND')
        ? NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
        : NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return format.format(amount);
  }

  String get billingCycle {
    // Tạo chuỗi đẹp như "/ Month"
    if (billingPeriodCount == 1) {
      return '/ ${billingPeriodUnitName}'; // VD: / Month
    }
    // VD: / 3 Months
    return '/ ${billingPeriodCount} ${billingPeriodUnitName}${billingPeriodCount > 1 ? 's' : ''}';
  }
}