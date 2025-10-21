// lib/models/UpdatePlanRequest.dart

class UpdatePlanRequest {
  final String? name;
  final String? displayName;
  final String? description;
  final String? featureConfig;
  final String? currency;
  final int? billingPeriodCount;
  final int? billingPeriodUnit;
  final double? amount;
  final int? trialDays;
  final int? status;

  UpdatePlanRequest({
    this.name,
    this.displayName,
    this.description,
    this.featureConfig,
    this.currency,
    this.billingPeriodCount,
    this.billingPeriodUnit,
    this.amount,
    this.trialDays,
    this.status,
  });

  // Chỉ chuyển thành JSON những trường có giá trị (không null)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (displayName != null) data['displayName'] = displayName;
    if (description != null) data['description'] = description;
    if (featureConfig != null) data['featureConfig'] = featureConfig;
    if (currency != null) data['currency'] = currency;
    if (billingPeriodCount != null) data['billingPeriodCount'] = billingPeriodCount;
    if (billingPeriodUnit != null) data['billingPeriodUnit'] = billingPeriodUnit;
    if (amount != null) data['amount'] = amount;
    if (trialDays != null) data['trialDays'] = trialDays;
    if (status != null) data['status'] = status;
    return data;
  }
}