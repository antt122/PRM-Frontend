import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isRecommended ? kRecommendedPlanColor : kBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: isRecommended ? null : Border.all(color: kAccentColor),
      ),
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
                fontWeight: FontWeight.bold),
          ),
          if (plan.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                plan.description,
                style: const TextStyle(color: kPrimaryTextColor, fontSize: 16),
              ),
            ),
          const Divider(height: 30, color: kAccentColor),
          ...plan.features.map((feature) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(feature, style: const TextStyle(color: kPrimaryTextColor)),
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
              backgroundColor: isRecommended ? kPrimaryTextColor : kAccentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(plan.amount > 0 ? 'Nhận ưu đãi' : 'Bắt đầu miễn phí'),
          ),
        ],
      ),
    );
  }
}
