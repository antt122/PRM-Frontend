import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

// COMPONENT: Nút đăng bài
class SubmitPostButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const SubmitPostButton({super.key, required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryTextColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: isLoading
          ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ))
          : const Text('ĐĂNG BÀI', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
