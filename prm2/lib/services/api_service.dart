
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_result.dart';
import '../models/creator_application.dart';
import '../models/creator_application_status.dart';
import '../models/login_data.dart';
import '../models/my_post.dart';
import '../models/subscription_plan.dart';
import '../models/user_profile.dart';

class ApiService {

  static const String _baseUrl = 'https://a572fec15611.ngrok-free.app/api/user/auth'; // Dùng baseUrl để dễ quản lý
  static const String _baseUrlSub = 'https://a572fec15611.ngrok-free.app/api/user';
  static const String _creatorApiBaseUrl = 'https://a572fec15611.ngrok-free.app/api';
  static const String _creatorBaseUrl = 'https://a572fec15611.ngrok-free.app/api';


  static const String _registerUrl = '$_baseUrl/register';
  static const String _verifyOtpUrl = '$_baseUrl/verify-otp';
  static const String _loginUrl = '$_baseUrl/login';
  static const String _plansUrl = 'https://a572fec15611.ngrok-free.app/api/cms/subscription-plans';
  static const String _checkoutUrl = '$_baseUrlSub/profile';
  static const String _creatorApplicationUrl = '$_creatorApiBaseUrl/CreatorApplications';
  static const String _creatorStatusUrl = '$_creatorApiBaseUrl/CreatorApplications/my-status';
  static const String _creatorPodcastsUrl = '$_creatorBaseUrl/creator/podcasts';

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
      return ApiResult(
          isSuccess: false, errors: ['Request timed out. Please try again.']);
    } on http.ClientException catch (e) {
      return ApiResult(
          isSuccess: false, errors: ['Connection error: ${e.message}']);
    } catch (e) {
      return ApiResult(isSuccess: false,
          errors: ['An unexpected error occurred: ${e.toString()}']);
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
      'otpType': 1, // 1=Registration
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
      return ApiResult(
          isSuccess: false, message: 'Connection error: ${e.message}');
    } catch (e) {
      return ApiResult(isSuccess: false,
          message: 'An unexpected error occurred: ${e.toString()}');
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
      return ApiResult(
          isSuccess: false, message: 'Connection error: ${e.message}');
    } catch (e) {
      return ApiResult(isSuccess: false,
          message: 'An unexpected error occurred: ${e.toString()}');
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
      final response = await http.get(url, headers: headers).timeout(
          const Duration(seconds: 15));

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 401) {
        return ApiResult(isSuccess: false,
            message: 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
      }

      final isSuccess = jsonResponse['isSuccess'] as bool? ?? false;

      if (!isSuccess) {
        return ApiResult(
          isSuccess: false,
          message: jsonResponse['message'] as String? ?? 'API đã trả về lỗi.',
          errors: (jsonResponse['errors'] as List<dynamic>?)?.map((e) =>
              e.toString()).toList(),
        );
      }

      // Trích xuất danh sách từ trường "items"
      final itemsList = jsonResponse['items'] as List<dynamic>?;
      if (itemsList == null) {
        return ApiResult(
            isSuccess: false, message: 'Dữ liệu trả về không đúng định dạng.');
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
          isSuccess: false,
          message: 'Hết thời gian yêu cầu. Vui lòng thử lại.');
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
      final response = await http.get(url, headers: headers).timeout(
          const Duration(seconds: 15));
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 401) {
        return ApiResult(
            isSuccess: false, message: 'Phiên đăng nhập đã hết hạn.');
      }

      // Dùng ApiResult để parse, và UserProfile.fromJson sẽ tự xử lý trường 'data'
      return ApiResult.fromJson(
        jsonResponse,
            (dataJson) =>
            UserProfile.fromJson(jsonResponse), // Truyền cả jsonResponse vào
      );
    } catch (e) {
      return ApiResult(isSuccess: false,
          message: 'Lỗi lấy thông tin người dùng: ${e.toString()}');
    }
  }

  // --- SUBMIT CREATOR APPLICATION (Đã cập nhật xử lý lỗi) ---
  static Future<ApiResult<dynamic>> submitCreatorApplication(
      CreatorApplication application) async {
    final body = application.toJson();

    final url = Uri.parse(_creatorApplicationUrl);
    try {
      final headers = await _getAuthHeaders(); // Sử dụng hàm lấy token mới
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      // Xử lý thành công (200 OK)
      if (response.statusCode == 200) {
        // API trả về 200 OK, thường là JSON, nhưng cũng có thể là text/plain
        final responseBody = jsonDecode(response.body);
        return ApiResult(
          isSuccess: responseBody['success'] ?? true,
          // Dựa vào trường 'success'
          message: responseBody['message'] ?? 'Gửi đơn thành công!',
          data: responseBody,
        );
      }

      // Xử lý lỗi (4xx, 5xx)

      // Attempt to decode JSON for detailed messages
      final errorBody = jsonDecode(response.body);
      String errorMessage = 'Lỗi ${response
          .statusCode}. Server không phản hồi.';

      if (response.statusCode == 400) {
        // Xử lý lỗi 400 Bad Request (Validation Errors)
        if (errorBody['errors'] != null && errorBody['errors'] is Map) {
          // Trích xuất tất cả lỗi xác thực thành một chuỗi
          final validationErrors = (errorBody['errors'] as Map).values
              .expand((list) => list as Iterable)
              .join('; ');
          errorMessage = 'Lỗi xác thực: $validationErrors';
        } else if (errorBody['detail'] != null) {
          errorMessage = 'Lỗi 400: ${errorBody['detail']}';
        }
      } else if (response.statusCode == 401) {
        // Xử lý lỗi 401 Unauthorized
        errorMessage = 'Lỗi 401: Không được phép. Vui lòng đăng nhập lại.';
      } else if (response.statusCode >= 500) {
        // Xử lý lỗi 5xx Internal Server Error
        errorMessage =
        'Lỗi Server (${response.statusCode}): Vui lòng thử lại sau.';
      }

      return ApiResult(isSuccess: false, message: errorMessage);
    } catch (e) {
      // Lỗi kết nối, timeout, hoặc lỗi parse JSON
      return ApiResult(isSuccess: false,
          message: 'Đã xảy ra lỗi kết nối hoặc parse dữ liệu: ${e.toString()}');
    }
  }

  /// HÀM MỚI: Lấy trạng thái đơn đăng ký của user
  static Future<ApiResult<CreatorApplicationStatus>>
  getMyCreatorApplicationStatus() async {
    final url = Uri.parse(_creatorStatusUrl);
    try {
      final headers = await _getAuthHeaders();
      final response =
      await http.get(url, headers: headers).timeout(
          const Duration(seconds: 15));

      // 404 Not Found nghĩa là user chưa nộp đơn
      if (response.statusCode == 404) {
        return ApiResult(
            isSuccess: false,
            message: 'Bạn chưa nộp đơn đăng ký.',
            errorCode: '404');
      }
      if (response.statusCode == 401) {
        return ApiResult(
            isSuccess: false, message: 'Phiên đăng nhập đã hết hạn.');
      }

      final jsonResponse = jsonDecode(response.body);

      // 200 OK: User đã nộp đơn, trả về chi tiết
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResult(
          isSuccess: true,
          data: CreatorApplicationStatus.fromJson(jsonResponse),
        );
      }

      return ApiResult(
          isSuccess: false, message: 'Lỗi không xác định khi lấy trạng thái.');
    } catch (e) {
      return ApiResult(isSuccess: false, message: 'Lỗi: ${e.toString()}');
    }
  }

  /// HÀM MỚI: Lấy danh sách bài đăng của creator
  static Future<ApiResult<List<MyPost>>> getMyPosts(
      {int page = 1, int pageSize = 20}) async {
    final url =
    Uri.parse('$_creatorPodcastsUrl/my-podcasts?page=$page&pageSize=$pageSize');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers);
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode != 200) {
        return ApiResult(
            isSuccess: false, message: 'Lỗi ${response.statusCode}');
      }

      // Giả định API trả về có phân trang giống API plans
      final itemsList = jsonResponse['podcasts'] as List<
          dynamic>?; // Key có thể là 'items' hoặc 'podcasts'
      if (itemsList == null) {
        return ApiResult(
            isSuccess: false, message: 'Dữ liệu trả về không đúng định dạng.');
      }

      final posts = itemsList.map((p) => MyPost.fromJson(p)).toList();
      return ApiResult(isSuccess: true, data: posts);
    } catch (e) {
      return ApiResult(isSuccess: false, message: e.toString());
    }
  }


}
