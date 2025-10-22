// File: screens/otp_verification_screen.dart (PHIÊN BẢN LIQUID GLASS)

import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:pinput/pinput.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_fonts.dart';

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
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
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
    });
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
          SnackBar(
            content: Text(
              'Xác thực thành công! Vui lòng đăng nhập.',
              style: AppFonts.body.copyWith(color: kPrimaryTextColor),
            ),
            backgroundColor: kSuccessColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        widget.onVerificationSuccess();
      } else {
        setState(() {
          _error =
              result.errors?.join('\n') ??
              result.message ??
              'Mã OTP không hợp lệ hoặc đã hết hạn.';
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
      SnackBar(
        content: Text(
          'Đã gửi lại mã OTP thành công!',
          style: AppFonts.body.copyWith(color: kPrimaryTextColor),
        ),
        backgroundColor: kSuccessColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    // Bắt đầu lại bộ đếm ngược
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kGlassBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kGlassBorder, width: 0.5),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: kPrimaryTextColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kBackgroundColor, kSurfaceColor],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                vertical: 40.0,
                horizontal: 20.0,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: Container(
                    decoration: BoxDecoration(
                      color: kGlassBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kGlassBorder, width: 0.5),
                      boxShadow: [
                        BoxShadow(
                          color: kGlassShadow,
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'XÁC THỰC EMAIL',
                            textAlign: TextAlign.center,
                            style: AppFonts.title1.copyWith(
                              color: kPrimaryTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Vui lòng nhập mã OTP gồm 6 chữ số\nđã được gửi đến email:\n${widget.email}',
                            textAlign: TextAlign.center,
                            style: AppFonts.body.copyWith(
                              color: kSecondaryTextColor,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // OTP Input với Liquid Glass
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: kSurfaceColor.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: kGlassBorder,
                                    width: 0.5,
                                  ),
                                ),
                                child: Pinput(
                                  controller: _otpController,
                                  focusNode: _focusNode,
                                  length: 6,
                                  onCompleted: (pin) => _verifyOtp(),
                                  defaultPinTheme: PinTheme(
                                    width: 50,
                                    height: 55,
                                    textStyle: AppFonts.title2.copyWith(
                                      color: kPrimaryTextColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: BoxDecoration(
                                      color: kGlassBackground,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: kGlassBorder),
                                    ),
                                  ),
                                  focusedPinTheme: PinTheme(
                                    width: 50,
                                    height: 55,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: kAccentColor,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  errorPinTheme: PinTheme(
                                    width: 50,
                                    height: 55,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: kErrorColor,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Error message
                          if (_error != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: kErrorColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: kErrorColor.withValues(alpha: 0.3),
                                ),
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
                          const SizedBox(height: 30),

                          // Verify Button với Liquid Glass
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      kAccentColor,
                                      kAccentColor.withValues(alpha: 0.8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: kAccentColor.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _verifyOtp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 3,
                                          ),
                                        )
                                      : Text(
                                          'XÁC NHẬN',
                                          style: AppFonts.headline.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Resend section
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Không nhận được mã?",
                                style: AppFonts.body.copyWith(
                                  color: kSecondaryTextColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              _isResendButtonActive
                                  ? TextButton(
                                      onPressed: _resendOtp,
                                      child: Text(
                                        'Gửi lại',
                                        style: AppFonts.body.copyWith(
                                          color: kAccentColor,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                          decorationColor: kAccentColor,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      'Gửi lại sau (${_countdownSeconds.toString().padLeft(2, '0')}s)',
                                      style: AppFonts.caption1.copyWith(
                                        color: kSecondaryTextColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
