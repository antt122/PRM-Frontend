// File: screens/register_screen.dart (PHIÊN BẢN ĐÃ SỬA LỖI)

import 'package:flutter/material.dart';
import '../components/register_form.dart';

// Mô phỏng màu nền nhạt từ hình ảnh (phải giống LoginScreen)
const Color kLightBeigeBackground = Color(0xFFFBF8F5);

class RegisterScreen extends StatelessWidget {
  // THAY ĐỔI 1: Xóa callback khỏi constructor
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightBeigeBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            // Đảm bảo nội dung có thể cuộn khi bàn phím xuất hiện
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            // THAY ĐỔI 2: Gọi RegisterForm mà không cần tham số
            child: RegisterForm(),
          ),
        ),
      ),
    );
  }
}