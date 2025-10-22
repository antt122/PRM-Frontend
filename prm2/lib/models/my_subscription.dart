class MySubscription {
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
  final double amount;
  final String currency;
  final String billingPeriodUnit;
  final DateTime createdAt;
  final DateTime updatedAt;

  MySubscription({
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
    required this.amount,
    required this.currency,
    required this.billingPeriodUnit,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MySubscription.fromJson(Map<String, dynamic> json) {
    return MySubscription(
      id: json['id'] as String,
      userProfileId: json['userProfileId'] as String,
      subscriptionPlanId: json['subscriptionPlanId'] as String,
      planName: json['planName'] as String,
      planDisplayName: json['planDisplayName'] as String,
      subscriptionStatus: json['subscriptionStatus'] as int,
      subscriptionStatusName: json['subscriptionStatusName'] as String,
      currentPeriodStart: DateTime.parse(json['currentPeriodStart'] as String),
      currentPeriodEnd: DateTime.parse(json['currentPeriodEnd'] as String),
      cancelAt: json['cancelAt'] != null
          ? DateTime.tryParse(json['cancelAt'])
          : null,
      canceledAt: json['canceledAt'] != null
          ? DateTime.tryParse(json['canceledAt'])
          : null,
      cancelAtPeriodEnd: json['cancelAtPeriodEnd'] as bool? ?? false,
      renewalBehavior: json['renewalBehavior'] as int? ?? 0,
      renewalBehaviorName: json['renewalBehaviorName'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'VND',
      billingPeriodUnit: json['billingPeriodUnit'] as String? ?? 'Month',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
