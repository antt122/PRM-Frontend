import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

// COMPONENT: Ô nhập liệu
class PostFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;

  const PostFormField({
    super.key,
    required this.controller,
    required this.label,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: kPrimaryTextColor),
        filled: true,
        fillColor: kHighlightColor,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: kInputBorderColor)),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'Trường này là bắt buộc.' : null,
    );
  }
}
