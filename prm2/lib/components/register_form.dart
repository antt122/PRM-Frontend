// File: components/register_form.dart (PHIÊN BẢN HOÀN CHỈNH)

import 'package:flutter/material.dart';
import '../models/api_result.dart';
import '../services/api_service.dart';
import '../screens/OtpVerificationScreen.dart';

// === Các hằng số màu sắc ===
const Color kPrimaryBrown = Color(0xFF8B6B3E);
const Color kSecondaryBeige = Color(0xFFD6C8A6);
const Color kInputBorderColor = Color(0xFFC4B89A);

class RegisterForm extends StatefulWidget {
  // THAY ĐỔI 1: Xóa callback khỏi constructor
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
              // THAY ĐỔI 2: Cập nhật logic sau khi xác thực OTP thành công
              onVerificationSuccess: () {
                // Quay về trang Login sau khi OTP thành công.
                // Chúng ta cần pop 2 lần:
                // Lần 1: Đóng màn hình OTP
                // Lần 2: Đóng màn hình Register để lộ ra màn hình Login bên dưới
                Navigator.of(context).pop();
                Navigator.of(context).pop();

                // Hiển thị một thông báo trên màn hình Login để người dùng biết
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đăng ký và xác thực thành công! Vui lòng đăng nhập.'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ),
        );
      }
    } else {
      setState(() {
        _error = result.errors?.join('\n') ?? result.message ?? 'Đã xảy ra lỗi không xác định.';
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
    // Phần UI hoàn toàn không thay đổi
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'ĐĂNG KÝ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: kPrimaryBrown,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 40),

          _buildInputField(
            controller: _fullNameController,
            hintText: 'Họ và tên',
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _emailController,
            hintText: 'Email của bạn',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _phoneNumberController,
            hintText: 'Số điện thoại',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _passwordController,
            hintText: 'Mật khẩu',
            obscureText: !_isPasswordVisible,
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: kPrimaryBrown, size: 20,
              ),
              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _confirmPasswordController,
            hintText: 'Xác nhận mật khẩu',
            obscureText: !_isConfirmPasswordVisible,
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: kPrimaryBrown, size: 20,
              ),
              onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
            ),
          ),
          const SizedBox(height: 30),

          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: kPrimaryBrown))
          else
            _buildRegisterButton(),

          const SizedBox(height: 40),

          _buildLoginLink(),
          const SizedBox(height: 10),

          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ),
    );
  }

  // Widget _buildInputField không thay đổi
  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: kInputBorderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(color: kPrimaryBrown),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: kPrimaryBrown.withOpacity(0.6), fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          border: InputBorder.none,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  // Widget _buildRegisterButton không thay đổi
  Widget _buildRegisterButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: kSecondaryBeige,
          foregroundColor: kPrimaryBrown,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 5,
        ),
        child: const Text(
          'ĐĂNG KÝ',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.0),
        ),
      ),
    );
  }

  // Widget _buildLoginLink đã được sửa logic onTap
  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Đã có tài khoản ? ',
          style: TextStyle(color: Colors.black54, fontSize: 16),
        ),
        GestureDetector(
          // THAY ĐỔI 3: Sửa lại hàm onTap để tự quay về
          onTap: () {
            // Quay lại màn hình trước đó (chính là LoginScreen)
            Navigator.pop(context);
          },
          child: const Text(
            'Đăng nhập',
            style: TextStyle(
              color: kPrimaryBrown,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              decorationColor: kPrimaryBrown,
            ),
          ),
        ),
      ],
    );
  }
}