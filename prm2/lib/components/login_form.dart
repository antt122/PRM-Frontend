// File: components/login_form.dart (PHIÊN BẢN HOÀN CHỈNH)

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/home_screen.dart';
import '../services/api_service.dart';
import '../screens/register_screen.dart';

// === CÁC MÀU SẮC DỰA TRÊN THIẾT KẾ ===
const Color kPrimaryBrown = Color(0xFF8B6B3E);
const Color kSecondaryBeige = Color(0xFFD6C8A6);
const Color kLightBeige = Color(0xFFF9F7F0);
const Color kInputBorderColor = Color(0xFFC4B89A);

class LoginForm extends StatefulWidget {
  // Constructor đã được sửa, không cần callback
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
  bool _rememberMe = false;
  bool _isPasswordVisible = false;
  int _selectedTab = 1;

  // --- LOGIC ĐĂNG NHẬP ---
  Future<void> _login() async {
    // 1. Kiểm tra đầu vào
    if (_selectedTab == 1 && (_emailController.text.isEmpty || _passwordController.text.isEmpty)) {
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

        // Điều hướng đến HomeScreen và xóa tất cả các trang trước đó
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
        );
      } else {
        // Đăng nhập thất bại, hiển thị lỗi
        setState(() {
          _error = result.errors?.join('\n') ?? result.message ?? 'Đăng nhập thất bại.';
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
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. TIÊU ĐỀ
          const Text(
            'ĐĂNG NHẬP',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: kPrimaryBrown,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 40),

          // 2. TAB SĐT/EMAIL
          _buildAuthToggle(),
          const SizedBox(height: 30),

          // 3. INPUT EMAIL/SĐT
          _buildInputField(
            controller: _emailController,
            hintText: _selectedTab == 1 ? 'Email của bạn' : 'Số điện thoại của bạn',
            keyboardType: _selectedTab == 1 ? TextInputType.emailAddress : TextInputType.phone,
          ),
          const SizedBox(height: 20),

          // 4. INPUT MẬT KHẨU
          _buildInputField(
            controller: _passwordController,
            hintText: 'Mật khẩu',
            obscureText: !_isPasswordVisible,
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: kPrimaryBrown,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
          const SizedBox(height: 20),

          // 5. NÚT ĐĂNG NHẬP VÀ LOADING
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: kPrimaryBrown),
            )
          else
            _buildLoginButton(),

          const SizedBox(height: 15),

          // 6. GHI NHỚ MẬT KHẨU & QUÊN MẬT KHẨU
          _buildFooterLinks(),
          const SizedBox(height: 25),

          // 7. DÒNG PHÂN CÁCH "HOẶC"
          _buildDividerWithText('HOẶC'),
          const SizedBox(height: 25),

          // 8. ĐĂNG NHẬP BẰNG GOOGLE
          _buildGoogleButton(),
          const SizedBox(height: 40),

          // 9. CHUYỂN ĐẾN ĐĂNG KÝ
          _buildRegisterLink(),
          const SizedBox(height: 10),

          // 10. HIỂN THỊ LỖI
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

  // --- CÁC WIDGET HELPER ---

  Widget _buildAuthToggle() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedTab = 0),
            child: Column(
              children: [
                Text(
                  'Số điện thoại',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _selectedTab == 0 ? kPrimaryBrown : Colors.black45,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 3,
                  color: _selectedTab == 0 ? kPrimaryBrown : Colors.transparent,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedTab = 1),
            child: Column(
              children: [
                Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _selectedTab == 1 ? kPrimaryBrown : Colors.black45,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 3,
                  color: _selectedTab == 1 ? kPrimaryBrown : Colors.transparent,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

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

  Widget _buildLoginButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: kSecondaryBeige,
          foregroundColor: kPrimaryBrown,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 5,
        ),
        child: const Text(
          'ĐĂNG NHẬP',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildFooterLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (bool? value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                activeColor: kPrimaryBrown,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const Text(
              ' Ghi nhớ mật khẩu',
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            // TODO: Xử lý quên mật khẩu
          },
          child: const Text(
            'Quên mật khẩu ?',
            style: TextStyle(
              color: kPrimaryBrown,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDividerWithText(String text) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.black26)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(
            text,
            style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
          ),
        ),
        const Expanded(child: Divider(color: Colors.black26)),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: kInputBorderColor, width: 1.5),
        ),
        child: const Text(
          'G', // Biểu tượng Google đơn giản
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: kPrimaryBrown,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Bạn chưa có tài khoản ? ',
          style: TextStyle(color: Colors.black54, fontSize: 16),
        ),
        GestureDetector(
          onTap: () {
            // Tự điều hướng đến RegisterScreen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            );
          },
          child: const Text(
            'Đăng ký',
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