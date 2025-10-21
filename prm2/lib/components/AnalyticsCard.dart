import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class AnalyticsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color iconColor;

  const AnalyticsCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.iconColor = kAdminAccentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 32, color: iconColor),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: kAdminSecondaryTextColor, fontSize: 14)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: kAdminPrimaryTextColor, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
