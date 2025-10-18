// File: main.dart (PHIÊN BẢN MỚI, ĐƠN GIẢN HÓA)

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:prm2/screens/LoginScreen.dart';
import 'screens/splash_screen.dart'; // Import màn hình Splash mới

Future<void> main() async {
  // Load the .env file
  await dotenv.load(fileName: ".env");
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
      // Màn hình bắt đầu bây giờ là SplashScreen
      home: const LoginScreen(),
    );
  }
}
