// lib/models/CreatePlanRequest.dart

class CreatePlanRequest {
  final String name;
  final String displayName;
  final String description;
  final String? featureConfig;
  final String currency;
  final int billingPeriodCount;
  final int billingPeriodUnit;
  final double amount;
  final int trialDays;
  final int status;

  CreatePlanRequest({
    required this.name,
    required this.displayName,
    required this.description,
    this.featureConfig,
    required this.currency,
    required this.billingPeriodCount,
    required this.billingPeriodUnit,
    required this.amount,
    required this.trialDays,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'displayName': displayName,
      'description': description,
      if (featureConfig != null) 'featureConfig': featureConfig,
      'currency': currency,
      'billingPeriodCount': billingPeriodCount,
      'billingPeriodUnit': billingPeriodUnit,
      'amount': amount,
      'trialDays': trialDays,
      'status': status,
    };
  }
}