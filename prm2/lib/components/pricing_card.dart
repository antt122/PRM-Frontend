import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import '../models/subscription_plan.dart';
import '../screens/checkout_screen.dart'; // <<< THÊM MỚI
import '../utils/app_colors.dart';

class PricingCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isRecommended;

  const PricingCard({
    super.key,
    required this.plan,
    this.isRecommended = false,
  });

  String _formatPrice(double amount, String currency) {
    if (amount == 0) return 'Miễn phí';
    final formatCurrency = NumberFormat.decimalPattern('vi_VN');
    return '${formatCurrency.format(amount)} $currency';
  }

  List<Map<String, dynamic>> _getPlanFeatures(SubscriptionPlan plan) {
    // Hardcoded features based on plan name/type
    final allFeatures = [
      {'name': 'Nghe podcast', 'enabled': true},
      {'name': 'Không quảng cáo', 'enabled': false},
      {'name': 'Flashcard', 'enabled': false},
      {'name': 'Viết nhật ký', 'enabled': false},
      {'name': 'Tải offline', 'enabled': false},
      {'name': 'Chất lượng HD', 'enabled': false},
      {'name': 'Nội dung độc quyền', 'enabled': false},
      {'name': 'Podcast cá nhân', 'enabled': false},
    ];

    // Enable features based on plan type
    if (plan.name.toLowerCase().contains('free')) {
      // Free plan - only basic features
      return allFeatures.map((feature) {
        return {
          'name': feature['name'],
          'enabled': feature['name'] == 'Nghe podcast',
        };
      }).toList();
    } else if (plan.name.toLowerCase().contains('premium')) {
      // Premium plan - most features enabled
      return allFeatures.map((feature) {
        return {
          'name': feature['name'],
          'enabled': feature['name'] != 'Podcast cá nhân',
        };
      }).toList();
    } else if (plan.name.toLowerCase().contains('yearly')) {
      // Yearly Premium - all features enabled
      return allFeatures.map((feature) {
        return {'name': feature['name'], 'enabled': true};
      }).toList();
    }

    // Default - basic features only
    return allFeatures.map((feature) {
      return {
        'name': feature['name'],
        'enabled': feature['name'] == 'Nghe podcast',
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: isRecommended
                  ? kAccentColor.withOpacity(0.2)
                  : kGlassBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isRecommended ? kAccentColor : kGlassBorder,
                width: isRecommended ? 2 : 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isRecommended
                      ? kAccentColor.withOpacity(0.3)
                      : kGlassShadow,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    plan.displayName.toUpperCase(),
                    style: const TextStyle(
                      color: kPrimaryTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatPrice(plan.amount, plan.currency),
                    style: const TextStyle(
                      color: kPrimaryTextColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (plan.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        plan.description,
                        style: const TextStyle(
                          color: kPrimaryTextColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  const Divider(height: 30, color: kAccentColor),
                  // Hardcoded features based on plan type
                  ..._getPlanFeatures(plan).map((feature) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          Icon(
                            feature['enabled']
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: feature['enabled']
                                ? Colors.green
                                : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature['name'],
                              style: TextStyle(
                                color: feature['enabled']
                                    ? kPrimaryTextColor
                                    : kPrimaryTextColor.withValues(alpha: 0.5),
                                decoration: feature['enabled']
                                    ? TextDecoration.none
                                    : TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    // <<< CẬP NHẬT ONPRESSED
                    onPressed: () {
                      // Điều hướng đến màn hình Checkout và truyền gói đã chọn
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutScreen(plan: plan),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRecommended
                          ? kPrimaryTextColor
                          : kAccentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      plan.amount > 0 ? 'Nhận ưu đãi' : 'Bắt đầu miễn phí',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
