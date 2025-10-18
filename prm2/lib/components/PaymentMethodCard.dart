import 'package:flutter/material.dart';
import '../models/PaymentMethod.dart';
import '../utils/app_colors.dart';

class PaymentMethodCard extends StatelessWidget {
  final PaymentMethod method;
  const PaymentMethodCard({super.key, required this.method});

  @override
  Widget build(BuildContext context) {
    final bool isActive = method.status == 'Active';
    final statusColor = isActive ? Colors.green : kAdminSecondaryTextColor;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(label: Text(method.providerName)),
                Chip(
                  avatar: Icon(Icons.circle, size: 10, color: statusColor),
                  label: Text(method.status),
                  backgroundColor: statusColor.withOpacity(0.1),
                  side: BorderSide.none,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(method.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              method.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: kAdminSecondaryTextColor),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(method.typeName, style: const TextStyle(color: kAdminSecondaryTextColor, fontSize: 12)),
                Text(method.formattedCreatedAt, style: const TextStyle(color: kAdminSecondaryTextColor, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
