// File: screens/login_screen.dart
import 'package:flutter/material.dart';
import '../components/login_form.dart';

const Color kLightBeigeBackground = Color(0xFFFBF8F5);

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightBeigeBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: LoginForm(), // Gọi không cần tham số
          ),
        ),
      ),
    );
  }
}