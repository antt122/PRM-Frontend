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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 40, color: kAdminAccentColor),
              // Spacer sẽ chiếm hết không gian còn lại, đẩy phần text xuống dưới
              const Spacer(),
              // Bọc phần text trong Flexible để nó có thể tự động xuống dòng
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Chỉ chiếm không gian cần thiết
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: kAdminPrimaryTextColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2, // Cho phép title xuống 2 dòng
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: kAdminSecondaryTextColor,
                        fontSize: 14,
                      ),
                      maxLines: 2, // Cho phép subtitle xuống 2 dòng
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

