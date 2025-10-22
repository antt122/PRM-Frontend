import 'package:flutter/material.dart';
import 'dart:ui';
import '../utils/app_colors.dart';
import '../utils/app_fonts.dart';

class CommunitySection extends StatelessWidget {
  const CommunitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Column(
        children: [
          Text(
            'Tham gia cộng đồng Healink và kết nối với những người đồng hành',
            textAlign: TextAlign.center,
            style: AppFonts.title2.copyWith(color: kPrimaryTextColor),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              4,
              (index) => Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      kPrimaryColor.withOpacity(0.3),
                      kAccentColor.withOpacity(0.3),
                    ],
                  ),
                  border: Border.all(color: kGlassBorder, width: 0.5),
                ),
                child: const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.transparent,
                  child: Icon(Icons.person, size: 40, color: kPrimaryTextColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
