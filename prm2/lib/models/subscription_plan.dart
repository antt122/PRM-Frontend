
import 'dart:convert';

class SubscriptionPlan {
  final String id;
  final String name;
  final String displayName;
  final String description;
  final List<String> features;
  final String currency;
  final int billingPeriodCount;
  final int billingPeriodUnit;
  final double amount;
  final int trialDays;
  final String status;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.displayName,
    required this.description,
    required this.features,
    required this.currency,
    required this.billingPeriodCount,
    required this.billingPeriodUnit,
    required this.amount,
    required this.trialDays,
    required this.status,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    final featureConfigString = json['featureConfig'] as String? ?? '';
    final featuresList = featureConfigString.split(';').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    return SubscriptionPlan(
      id: json['id'] as String, // Thêm ID
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      description: json['description'] as String,
      features: featuresList,
      currency: json['currency'] as String,
      billingPeriodCount: json['billingPeriodCount'] as int,
      billingPeriodUnit: json['billingPeriodUnit'] as int,
      amount: (json['amount'] as num).toDouble(),
      trialDays: json['trialDays'] as int,
      status: json['status'] as String,
    );
  }
}
