import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_navigation_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Đợi một chút để người dùng thấy splash screen (tùy chọn)
    await Future.delayed(const Duration(seconds: 1));

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (!mounted) return; // Đảm bảo widget vẫn còn trên cây widget

    if (token != null && token.isNotEmpty) {
      // Nếu có token, chuyển đến MainNavigationScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
    } else {
      // Nếu không có token, chuyển đến LoginScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Giao diện đơn giản của Splash Screen
    return const Scaffold(
      backgroundColor: Color(0xFFFBF8F5), // Màu nền giống LoginScreen
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF8B6B3E), // Màu nâu giống theme
        ),
      ),
    );
  }
}
