import 'package:flutter/material.dart';
import 'dart:ui';
import '../utils/app_colors.dart';
import '../utils/app_fonts.dart';

class MindfulnessHighlights extends StatelessWidget {
  const MindfulnessHighlights({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: kGlassBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kGlassBorder, width: 0.5),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _HighlightItem(Icons.headphones, 'KHOẢNH KHẮC CHÁNH NIỆM'),
                  _HighlightItem(Icons.spa, 'KHOẢNH KHẮC CHÁNH NIỆM'),
                  _HighlightItem(
                    Icons.self_improvement,
                    'KHOẢNH KHẮC CHÁNH NIỆM',
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

class _HighlightItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _HighlightItem(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: kPrimaryTextColor, size: 30),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppFonts.caption1.copyWith(
              color: kPrimaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
