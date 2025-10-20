import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: kAdminCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: kAdminInputBorderColor.withOpacity(0.5)),
      ),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Giảm padding một chút cho cân đối
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // Canh lề các phần tử bên trong thẻ
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, size: 36, color: kAdminAccentColor), // Giảm size icon một chút

              // THAY ĐỔI QUAN TRỌNG NHẤT: Bỏ Spacer, dùng SizedBox
              const SizedBox(height: 16),

              // Bỏ Flexible đi
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: kAdminPrimaryTextColor,
                      fontSize: 17, // Chỉnh size chữ cho phù hợp hơn
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: kAdminSecondaryTextColor,
                      fontSize: 13, // Chỉnh size chữ cho phù hợp hơn
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}