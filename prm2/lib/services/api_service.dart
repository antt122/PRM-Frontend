// Trong file services/api_service.dart

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_result.dart';
import '../models/login_data.dart';
import '../models/subscription_plan.dart';
import '../models/user_profile.dart';

class ApiService {

  static const String _baseUrl = 'http://localhost:5010/api/user/auth'; // Dùng baseUrl để dễ quản lý
  static const String _baseUrlSub = 'http://localhost:5002/api/user';

  static const String _registerUrl = '$_baseUrl/register';
  static const String _verifyOtpUrl = '$_baseUrl/verify-otp';
  static const String _loginUrl = '$_baseUrl/login';
  static const String _plansUrl = 'http://localhost:5005/api/cms/subscription-plans';
  static const String _checkoutUrl = '$_baseUrlSub/profile';

// --- HÀM HELPER MỚI ĐỂ LẤY HEADER CÓ TOKEN ---
  static Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken'); // Lấy token đã lưu

    if (token != null) {
      // Nếu có token, trả về header Authorization theo chuẩn Bearer
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    }
    // Nếu không có token, trả về header mặc định
    return {'Content-Type': 'application/json'};
  }


  static Future<ApiResult<dynamic>> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String fullName,
    required String phoneNumber,
  }) async {
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

  static Future<ApiResult<List<SubscriptionPlan>>> getSubscriptionPlans({
    int page = 1,
    int pageSize = 10,
  }) async {
    // Thêm các tham số page và pageSize vào URL
    final url = Uri.parse('$_plansUrl?page=$page&pageSize=$pageSize');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 15));

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 401) {
        return ApiResult(isSuccess: false, message: 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
      }

      final isSuccess = jsonResponse['isSuccess'] as bool? ?? false;

      if (!isSuccess) {
        return ApiResult(
          isSuccess: false,
          message: jsonResponse['message'] as String? ?? 'API đã trả về lỗi.',
          errors: (jsonResponse['errors'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
        );
      }

      // Trích xuất danh sách từ trường "items"
      final itemsList = jsonResponse['items'] as List<dynamic>?;
      if (itemsList == null) {
        return ApiResult(isSuccess: false, message: 'Dữ liệu trả về không đúng định dạng.');
      }

      final plans = itemsList
          .map((planJson) =>
          SubscriptionPlan.fromJson(planJson as Map<String, dynamic>))
          .toList();

      return ApiResult(
        isSuccess: true,
        data: plans,
        message: jsonResponse['message'] as String?,
      );

    } on TimeoutException {
      return ApiResult(
          isSuccess: false, message: 'Hết thời gian yêu cầu. Vui lòng thử lại.');
    } on http.ClientException catch (e) {
      return ApiResult(
          isSuccess: false, message: 'Lỗi kết nối: ${e.message}');
    } catch (e) {
      return ApiResult(isSuccess: false,
          message: 'Đã có lỗi không mong muốn xảy ra: ${e.toString()}');
    }
  }
  static Future<ApiResult<UserProfile>> getUserProfile() async {
    final url = Uri.parse(_checkoutUrl);
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 15));
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 401) {
        return ApiResult(isSuccess: false, message: 'Phiên đăng nhập đã hết hạn.');
      }

      // Dùng ApiResult để parse, và UserProfile.fromJson sẽ tự xử lý trường 'data'
      return ApiResult.fromJson(
        jsonResponse,
            (dataJson) => UserProfile.fromJson(jsonResponse), // Truyền cả jsonResponse vào
      );
    } catch (e) {
      return ApiResult(isSuccess: false, message: 'Lỗi lấy thông tin người dùng: ${e.toString()}');
    }
  }
}
