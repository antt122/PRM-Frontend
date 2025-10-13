// Trong file services/api_service.dart

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/api_result.dart';
import '../models/login_data.dart';

class ApiService {

  static const String _baseUrl = 'http://localhost:5010/api/user/auth'; // Dùng baseUrl để dễ quản lý
  static const String _registerUrl = '$_baseUrl/register';
  static const String _verifyOtpUrl = '$_baseUrl/verify-otp';
  static const String _loginUrl = '$_baseUrl/login';

  // === HÀM REGISTER GIỮ NGUYÊN ===
  static Future<ApiResult<dynamic>> register({
    // ... (code của bạn không đổi)
    required String email,
    required String password,
    required String confirmPassword,
    required String fullName,
    required String phoneNumber,
  }) async {
    // ... (code của bạn không đổi)
    final url = Uri.parse(_registerUrl);
    final body = {
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'otpSentChannel': 1
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      final jsonResponse = jsonDecode(response.body);
      return ApiResult.fromJson(jsonResponse, (data) => null);
    } on TimeoutException {
      return ApiResult(isSuccess: false, errors: ['Request timed out. Please try again.']);
    } on http.ClientException catch (e) {
      return ApiResult(isSuccess: false, errors: ['Connection error: ${e.message}']);
    } catch (e) {
      return ApiResult(isSuccess: false, errors: ['An unexpected error occurred: ${e.toString()}']);
    }
  }

  // === THÊM HÀM MỚI ĐỂ VERIFY OTP ===
  static Future<ApiResult<dynamic>> verifyOtp({
    required String contact, // email hoặc số điện thoại
    required String otpCode,
  }) async {
    final url = Uri.parse(_verifyOtpUrl);
    final body = {
      'contact': contact,
      'otpCode': otpCode,
      'otpSentChannel': 1, // 1=Email
      'otpType': 1,      // 1=Registration
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      final jsonResponse = jsonDecode(response.body);
      // Giống như register, API này không trả về 'data' nên ta truyền vào hàm trả về null
      return ApiResult.fromJson(jsonResponse, (data) => null);
    } on TimeoutException {
      return ApiResult(isSuccess: false, message: 'Request timed out.');
    } on http.ClientException catch (e) {
      return ApiResult(isSuccess: false, message: 'Connection error: ${e.message}');
    } catch (e) {
      return ApiResult(isSuccess: false, message: 'An unexpected error occurred: ${e.toString()}');
    }
  }
  static Future<ApiResult<LoginData>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(_loginUrl);
    final body = {
      'email': email,
      'password': password,
      'grantType': 0,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      final jsonResponse = jsonDecode(response.body);

      // Bây giờ chúng ta sẽ parse cả trường 'data' bằng LoginData.fromJson
      return ApiResult.fromJson(
        jsonResponse,
            (dataJson) => LoginData.fromJson(dataJson as Map<String, dynamic>),
      );
    } on TimeoutException {
      return ApiResult(isSuccess: false, message: 'Request timed out.');
    } on http.ClientException catch (e) {
      return ApiResult(isSuccess: false, message: 'Connection error: ${e.message}');
    } catch (e) {
      return ApiResult(isSuccess: false, message: 'An unexpected error occurred: ${e.toString()}');
    }
  }
}
