// File: screens/otp_verification_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../services/api_service.dart';

// ... (Các hằng số màu sắc giữ nguyên)
const Color kPrimaryBrown = Color(0xFF8B6B3E);
const Color kSecondaryBeige = Color(0xFFD6C8A6);
const Color kLightBeigeBackground = Color(0xFFFBF8F5);


class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final VoidCallback onVerificationSuccess;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.onVerificationSuccess,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;
  String? _error;

  // THAY ĐỔI 2: Thêm các biến để quản lý bộ đếm ngược
  late Timer _timer;
  int _countdownSeconds = 60;
  bool _isResendButtonActive = false;

  // THAY ĐỔI 3: Bắt đầu bộ đếm ngược khi màn hình được khởi tạo
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _isResendButtonActive = false; // Vô hiệu hóa nút khi timer bắt đầu
    _countdownSeconds = 60; // Reset lại thời gian đếm
    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (Timer timer) {
        if (_countdownSeconds == 0) {
          setState(() {
            timer.cancel();
            _isResendButtonActive = true; // Kích hoạt lại nút khi đếm xong
          });
        } else {
          setState(() {
            _countdownSeconds--;
          });
        }
      },
    );
  }

  // THAY ĐỔI 4: Hủy timer khi widget bị hủy để tránh memory leak
  @override
  void dispose() {
    _timer.cancel(); // Rất quan trọng!
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    // ... (logic hàm này không đổi)
    if (_otpController.text.length != 6) {
      setState(() {
        _error = 'Vui lòng nhập đủ 6 chữ số OTP.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await ApiService.verifyOtp(
      contact: widget.email,
      otpCode: _otpController.text,
    );

    if (mounted) {
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xác thực thành công! Vui lòng đăng nhập.'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onVerificationSuccess();
      } else {
        setState(() {
          _error = result.errors?.join('\n') ?? result.message ?? 'Mã OTP không hợp lệ hoặc đã hết hạn.';
        });
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  // THAY ĐỔI 5: Cập nhật logic khi gửi lại OTP
  Future<void> _resendOtp() async {
    // TODO: Gọi API để gửi lại OTP ở đây
    // Ví dụ: final result = await ApiService.resendOtp(email: widget.email);
    // if (result.isSuccess) { ... }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã gửi lại mã OTP thành công!'),
        backgroundColor: Colors.green,
      ),
    );
    // Bắt đầu lại bộ đếm ngược
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightBeigeBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPrimaryBrown),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ... (Phần UI tiêu đề, Pinput, nút Xác nhận không đổi)
                const Text(
                  'XÁC THỰC EMAIL',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: kPrimaryBrown,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Vui lòng nhập mã OTP gồm 6 chữ số\nđã được gửi đến email:\n${widget.email}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                Pinput(
                    controller: _otpController,
                    focusNode: _focusNode,
                    length: 6,
                    onCompleted: (pin) => _verifyOtp(),
                    // ... (Theme của Pinput giữ nguyên)
                    defaultPinTheme: PinTheme(
                      width: 50,
                      height: 55,
                      textStyle: const TextStyle(fontSize: 22, color: kPrimaryBrown, fontWeight: FontWeight.bold),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: kPrimaryBrown.withOpacity(0.5)),
                      ),
                    ),
                    focusedPinTheme: PinTheme(
                      width: 50,
                      height: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: kPrimaryBrown, width: 2),
                      ),
                    ),
                    errorPinTheme: PinTheme(
                      width: 50,
                      height: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.redAccent, width: 2),
                      ),
                    )
                ),
                const SizedBox(height: 30),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                    ),
                  ),
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: kPrimaryBrown))
                    : SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kSecondaryBeige,
                      foregroundColor: kPrimaryBrown,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text('XÁC NHẬN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),

                // THAY ĐỔI 6: Cập nhật UI cho phần gửi lại mã
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Không nhận được mã? ",
                      style: TextStyle(color: Colors.black54),
                    ),
                    // Hiển thị nút hoặc đồng hồ đếm ngược
                    _isResendButtonActive
                        ? TextButton(
                      onPressed: _resendOtp,
                      child: const Text(
                        'Gửi lại',
                        style: TextStyle(
                          color: kPrimaryBrown,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    )
                        : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        // Hiển thị số giây còn lại, định dạng 2 chữ số (ví dụ: 09)
                        'Gửi lại sau (${_countdownSeconds.toString().padLeft(2, '0')}s)',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}