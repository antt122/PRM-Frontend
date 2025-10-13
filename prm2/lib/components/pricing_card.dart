import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class PricingCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? price;
  final List<String> features;
  final List<bool> isEnabled;
  final bool isRecommended;

  const PricingCard({
    super.key,
    required this.title,
    this.subtitle,
    this.price,
    required this.features,
    this.isEnabled = const [],
    this.isRecommended = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isRecommended ? kRecommendedPlanColor : kBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: isRecommended ? null : Border.all(color: kAccentColor),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: kPrimaryTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          if (subtitle != null)
            Text(
              subtitle!,
              style: const TextStyle(color: kPrimaryTextColor, fontSize: 18),
            ),
          if (price != null)
            Text(
              price!,
              style: const TextStyle(
                  color: kPrimaryTextColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
          Divider(height: 30, color: kAccentColor.withOpacity(0.5)),
          ...List.generate(features.length, (index) {
            bool enabled = isEnabled.isNotEmpty ? isEnabled[index] : true;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Icon(
                    enabled ? Icons.check_circle : Icons.cancel,
                    color: enabled ? Colors.green : Colors.grey.shade400,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      features[index],
                      style: TextStyle(
                        color:
                        enabled ? kPrimaryTextColor : Colors.grey.shade600,
                        decoration:
                        enabled ? null : TextDecoration.lineThrough,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: isRecommended ? kPrimaryTextColor : kAccentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(price == null ? 'Trải nghiệm' : 'Nhận ưu đãi'),
          ),
        ],
      ),
    );
  }
}
