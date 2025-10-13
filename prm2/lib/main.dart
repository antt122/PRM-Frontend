// File: main.dart (PHIÊN BẢN MỚI, ĐƠN GIẢN HÓA)

import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Chỉ cần import LoginScreen

void main() {
  runApp(const MyApp());
}

// Chuyển lại thành StatelessWidget vì không cần quản lý trạng thái nữa
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Social Network Demo',
      // Thiết lập Theme chung với tông màu nâu/beige
      theme: ThemeData(
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8B6B3E)),
        useMaterial3: true,
      ),
      // Chỉ cần trỏ thẳng đến LoginScreen là xong
      home: const LoginScreen(),
    );
  }
}