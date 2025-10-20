import 'package:flutter/material.dart';
import '../utils/app_colors.dart'; // Import file màu sắc của bạn

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData? icon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;
  final Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      onChanged: onChanged,
      style: const TextStyle(color: kAdminPrimaryTextColor), // Màu chữ trong input
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: kAdminSecondaryTextColor), // Màu label
        prefixIcon: icon != null ? Icon(icon, color: kAdminSecondaryTextColor) : null,
        // --- SỬA LỖI Ở ĐÂY ---
        // Sử dụng các màu đã được định nghĩa trong app_colors.dart
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // Bo góc
          borderSide: const BorderSide(color: kAdminInputBorderColor), // Màu border
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kAdminInputBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kAdminAccentColor, width: 2), // Màu border khi focus
        ),
        fillColor: kAdminCardColor, // Màu nền của TextField
        filled: true,
      ),
    );
  }
}

