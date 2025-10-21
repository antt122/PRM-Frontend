// File: components/login_form.dart (PHIÊN BẢN LIQUID GLASS)

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/main_navigation_screen.dart';
import '../services/api_service.dart';
import '../screens/register_screen.dart';
import '../utils/app_colors.dart';
import '../utils/app_fonts.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  // --- CÁC BIẾN STATE ---
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _isPasswordVisible = false;

  // --- LOGIC ĐĂNG NHẬP ---
  Future<void> _login() async {
    // 1. Kiểm tra đầu vào
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _error = "Vui lòng nhập email và mật khẩu.");
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    // 2. Gọi API để đăng nhập
    final result = await ApiService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    // 3. Xử lý kết quả
    if (mounted) {
      if (result.isSuccess && result.data != null) {
        // Đăng nhập thành công, lưu token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', result.data!.accessToken);

        // Điều hướng đến MainNavigationScreen và xóa tất cả các trang trước đó
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
          (route) => false,
        );
      } else {
        // Đăng nhập thất bại, hiển thị lỗi
        setState(() {
          _error =
              result.errors?.join('\n') ??
              result.message ??
              'Đăng nhập thất bại.';
        });
      }
    }

    // 4. Dừng trạng thái loading
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // --- GIAO DIỆN ---
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. TIÊU ĐỀ
          Text(
            'ĐĂNG NHẬP',
            textAlign: TextAlign.center,
            style: AppFonts.title1.copyWith(
              color: kPrimaryTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Chào mừng bạn trở lại',
            textAlign: TextAlign.center,
            style: AppFonts.body.copyWith(color: kSecondaryTextColor),
          ),
          const SizedBox(height: 40),

          // 2. INPUT EMAIL
          _buildInputField(
            controller: _emailController,
            hintText: 'Email của bạn',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined),
          ),
          const SizedBox(height: 20),

          // 3. INPUT MẬT KHẨU
          _buildInputField(
            controller: _passwordController,
            hintText: 'Mật khẩu',
            obscureText: !_isPasswordVisible,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: kSecondaryTextColor,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
          const SizedBox(height: 30),

          // 4. NÚT ĐĂNG NHẬP VÀ LOADING
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                color: kAccentColor,
                strokeWidth: 2,
              ),
            )
          else
            _buildLoginButton(),

          const SizedBox(height: 20),

          // 5. QUÊN MẬT KHẨU
          Center(
            child: TextButton(
              onPressed: () {
                // TODO: Xử lý quên mật khẩu
              },
              child: Text(
                'Quên mật khẩu?',
                style: AppFonts.caption1.copyWith(
                  color: kAccentColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),

          // 6. CHUYỂN ĐẾN ĐĂNG KÝ
          _buildRegisterLink(),
          const SizedBox(height: 20),

          // 7. HIỂN THỊ LỖI
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kErrorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kErrorColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: AppFonts.caption1.copyWith(
                  color: kErrorColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- CÁC WIDGET HELPER ---

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: kSurfaceColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kGlassBorder, width: 0.5),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            style: AppFonts.body.copyWith(color: kPrimaryTextColor),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppFonts.body.copyWith(color: kSecondaryTextColor),
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kAccentColor, kAccentColor.withValues(alpha: 0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: kAccentColor.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'ĐĂNG NHẬP',
              style: AppFonts.headline.copyWith(
                color: kPrimaryTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Bạn chưa có tài khoản? ',
          style: AppFonts.body.copyWith(color: kSecondaryTextColor),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            );
          },
          child: Text(
            'Đăng ký',
            style: AppFonts.body.copyWith(
              color: kAccentColor,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              decorationColor: kAccentColor,
            ),
          ),
        ),
      ],
    );
  }
}
