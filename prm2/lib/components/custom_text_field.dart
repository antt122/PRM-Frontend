import 'package:flutter/material.dart';
import 'dart:ui';
import '../utils/app_colors.dart';
import '../utils/app_fonts.dart';

// Component tái sử dụng cho các trường nhập liệu.
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isRequired;
  final int maxLines;
  final bool obscureText;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.isRequired = true,
    this.maxLines = 1,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFonts.headline.copyWith(color: kPrimaryTextColor),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: TextFormField(
              controller: controller,
              maxLines: maxLines,
              obscureText: obscureText,
              style: AppFonts.body.copyWith(color: kPrimaryTextColor),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppFonts.body.copyWith(color: kSecondaryTextColor),
                filled: true,
                fillColor: kGlassBackground,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: kGlassBorder, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: kGlassBorder, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: kAccentColor, width: 2),
                ),
              ),
              validator: (value) {
                if (isRequired && (value == null || value.isEmpty)) {
                  return 'Vui lòng không bỏ trống trường này.';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }
}
