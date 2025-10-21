import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_colors.dart';
import 'HomeScreen.dart';
import 'LoginScreen.dart';

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
    // Chờ 2 giây để hiển thị logo
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token != null && token.isNotEmpty) {
        // Nếu có token, chuyển đến HomeScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // Nếu không có token, chuyển đến LoginScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: kAdminBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shield_outlined,
              size: 80,
              color: kAdminAccentColor,
            ),
            SizedBox(height: 24),
            Text(
              'Admin Dashboard',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: kAdminPrimaryTextColor,
              ),
            ),
            SizedBox(height: 48),
            CircularProgressIndicator(color: kAdminAccentColor),
          ],
        ),
      ),
    );
  }
}
