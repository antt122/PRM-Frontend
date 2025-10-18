// lib/models/Subscription.dart

class Subscription {
  final String id;
  final String userProfileId;
  final String subscriptionPlanId;
  final String planName;
  final String planDisplayName;
  final int subscriptionStatus;
  final String subscriptionStatusName;
  final DateTime currentPeriodStart;
  final DateTime currentPeriodEnd;
  final DateTime? cancelAt;
  final DateTime? canceledAt;
  final bool cancelAtPeriodEnd;
  final int renewalBehavior;
  final String renewalBehaviorName;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // --- CÁC TRƯỜNG MỚI ĐƯỢC THÊM VÀO ---
  final double amount;
  final String currency;
  final String billingPeriodUnit;

  Subscription({
    required this.id,
    required this.userProfileId,
    required this.subscriptionPlanId,
    required this.planName,
    required this.planDisplayName,
    required this.subscriptionStatus,
    required this.subscriptionStatusName,
    required this.currentPeriodStart,
    required this.currentPeriodEnd,
    this.cancelAt,
    this.canceledAt,
    required this.cancelAtPeriodEnd,
    required this.renewalBehavior,
    required this.renewalBehaviorName,
    required this.createdAt,
    this.updatedAt,

    // --- THÊM VÀO CONSTRUCTOR ---
    required this.amount,
    required this.currency,
    required this.billingPeriodUnit,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] ?? '',
      userProfileId: json['userProfileId'] ?? '',
      subscriptionPlanId: json['subscriptionPlanId'] ?? '',
      planName: json['planName'] ?? 'N/A',
      planDisplayName: json['planDisplayName'] ?? 'N/A',
      subscriptionStatus: json['subscriptionStatus'] ?? 0,
      subscriptionStatusName: json['subscriptionStatusName'] ?? 'Unknown',
      currentPeriodStart: json['currentPeriodStart'] != null
          ? DateTime.parse(json['currentPeriodStart'])
          : DateTime.now(),
      currentPeriodEnd: json['currentPeriodEnd'] != null
          ? DateTime.parse(json['currentPeriodEnd'])
          : DateTime.now(),
      cancelAt: json['cancelAt'] != null ? DateTime.parse(json['cancelAt']) : null,
      canceledAt: json['canceledAt'] != null ? DateTime.parse(json['canceledAt']) : null,
      cancelAtPeriodEnd: json['cancelAtPeriodEnd'] ?? false,
      renewalBehavior: json['renewalBehavior'] ?? 0,
      renewalBehaviorName: json['renewalBehaviorName'] ?? 'Unknown',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,

      // --- THÊM PARSING CHO CÁC TRƯỜNG MỚI ---
      // Xử lý an toàn cho kiểu số (có thể là int hoặc double từ JSON)
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'N/A',
      billingPeriodUnit: json['billingPeriodUnit'] ?? 'N/A',
    );
  }
}