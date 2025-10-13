import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CommunitySection extends StatelessWidget {
  const CommunitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Column(
        children: [
          const Text(
            'Tham gia cộng đồng Healink và kết nối với những người đồng hành',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kPrimaryTextColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              4,
                  (index) => const CircleAvatar(
                radius: 40,
                backgroundColor: kHighlightColor,
                child: Icon(Icons.person, size: 40, color: kAccentColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
