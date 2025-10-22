// File: components/register_form.dart (PHIÊN BẢN LIQUID GLASS)

import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/api_service.dart';
import '../screens/OtpVerificationScreen.dart';
import '../utils/app_colors.dart';
import '../utils/app_fonts.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  // Các controller và biến state giữ nguyên
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  Future<void> _register() async {
    // 1. Giữ nguyên phần kiểm tra dữ liệu đầu vào
    if (_fullNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneNumberController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      setState(() {
        _error = "Vui lòng nhập đầy đủ thông tin.";
      });
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _error = "Mật khẩu xác nhận không khớp.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    // 2. Gọi ApiService (giữ nguyên)
    final result = await ApiService.register(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneNumberController.text.trim(),
      password: _passwordController.text.trim(),
      confirmPassword: _confirmPasswordController.text.trim(),
    );

    // 3. Xử lý kết quả
    if (result.isSuccess) {
      if (mounted) {
        final email = _emailController.text.trim();
        _fullNameController.clear();
        _emailController.clear();
        _phoneNumberController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();

        // Điều hướng sang màn hình xác thực OTP
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(
              email: email,
              onVerificationSuccess: () {
                // Quay về trang Login sau khi OTP thành công.
                Navigator.of(context).pop();
                Navigator.of(context).pop();

                // Hiển thị một thông báo trên màn hình Login để người dùng biết
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Đăng ký và xác thực thành công! Vui lòng đăng nhập.',
                      style: AppFonts.body.copyWith(color: kPrimaryTextColor),
                    ),
                    backgroundColor: kSuccessColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }
    } else {
      setState(() {
        _error =
            result.errors?.join('\n') ??
            result.message ??
            'Đã xảy ra lỗi không xác định.';
      });
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // TIÊU ĐỀ
          Text(
            'ĐĂNG KÝ',
            textAlign: TextAlign.center,
            style: AppFonts.title1.copyWith(
              color: kPrimaryTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tạo tài khoản mới',
            textAlign: TextAlign.center,
            style: AppFonts.body.copyWith(color: kSecondaryTextColor),
          ),
          const SizedBox(height: 40),

          // INPUT FIELDS
          _buildInputField(
            controller: _fullNameController,
            hintText: 'Họ và tên',
            keyboardType: TextInputType.name,
            prefixIcon: const Icon(Icons.person_outline),
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _emailController,
            hintText: 'Email của bạn',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined),
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _phoneNumberController,
            hintText: 'Số điện thoại',
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(Icons.phone_outlined),
          ),
          const SizedBox(height: 20),
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
              onPressed: () =>
                  setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _confirmPasswordController,
            hintText: 'Xác nhận mật khẩu',
            obscureText: !_isConfirmPasswordVisible,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: kSecondaryTextColor,
                size: 20,
              ),
              onPressed: () => setState(
                () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
              ),
            ),
          ),
          const SizedBox(height: 30),

          // NÚT ĐĂNG KÝ VÀ LOADING
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                color: kAccentColor,
                strokeWidth: 2,
              ),
            )
          else
            _buildRegisterButton(),

          const SizedBox(height: 30),

          // LINK ĐĂNG NHẬP
          _buildLoginLink(),
          const SizedBox(height: 20),

          // HIỂN THỊ LỖI
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

  Widget _buildRegisterButton() {
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
            onPressed: _register,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'ĐĂNG KÝ',
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

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Đã có tài khoản? ',
          style: AppFonts.body.copyWith(color: kSecondaryTextColor),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Text(
            'Đăng nhập',
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
