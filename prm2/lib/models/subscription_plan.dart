import 'dart:convert';

class SubscriptionPlan {
  final String name;
  final String displayName;
  final String description;
  // --- THAY ĐỔI: Chuyển từ String sang List<String> ---
  final List<String> features;
  final String currency;
  final int billingPeriodCount;
  final int billingPeriodUnit;
  final double amount;
  final int trialDays;
  final String status;

  SubscriptionPlan({
    required this.name,
    required this.displayName,
    required this.description,
    // --- THAY ĐỔI: Cập nhật constructor ---
    required this.features,
    required this.currency,
    required this.billingPeriodCount,
    required this.billingPeriodUnit,
    required this.amount,
    required this.trialDays,
    required this.status,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    // Giả định rằng 'featureConfig' là một chuỗi các tính năng,
    // phân cách nhau bằng dấu chấm phẩy ';'.
    // Ví dụ: "Nghe podcast;Không quảng cáo;Playlist và My podcast"
    final featureConfigString = json['featureConfig'] as String? ?? '';
    final featuresList = featureConfigString.split(';').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    return SubscriptionPlan(
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      description: json['description'] as String,
      // --- THAY ĐỔI: Parse chuỗi thành một danh sách ---
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

