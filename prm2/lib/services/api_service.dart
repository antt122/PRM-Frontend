
import 'dart:convert';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:prm2/models/my_subscription.dart';
import 'package:prm2/models/payment_method.dart';
import 'package:prm2/models/subscription_registration_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_result.dart';
import '../models/creator_application.dart';
import '../models/creator_application_status.dart';
import '../models/login_data.dart';
import '../models/my_post.dart';
import '../models/subscription_plan.dart';
import '../models/user_profile.dart';
import 'package:image_picker/image_picker.dart';

class ApiService {
  // --- CÁC URL ĐƯỢC CHUYỂN THÀNH GETTER ĐỂ TRÁNH RACE CONDITION ---
  static String get _baseUrl => dotenv.env['BASE_URL'] ?? '';

  static String get _authUrl => '$_baseUrl/user/auth';
  static String get _userUrl => '$_baseUrl/user';
  static String get _creatorApiUrl => '$_baseUrl';
  static String get _cmsUrl => '$_baseUrl/cms';

  static String get _registerUrl => '$_authUrl/register';
  static String get _verifyOtpUrl => '$_authUrl/verify-otp';
  static String get _loginUrl => '$_authUrl/login';
  static String get _plansUrl => '$_userUrl/subscription-plans';
  static String get _paymentMethodsUrl => '$_userUrl/payment-methods';
  static String get _registerSubscriptionUrl => '$_userUrl/subscriptions/register';
  static String get _mySubscriptionUrl => '$_userUrl/subscriptions/me'; // <-- THÊM MỚI
  static String get _checkoutUrl => '$_userUrl/profile';
  static String get _creatorApplicationUrl => '$_creatorApiUrl/CreatorApplications';
  static String get _creatorStatusUrl => '$_creatorApiUrl/CreatorApplications/my-status';
  static String get _creatorPodcastsUrl => '$_creatorApiUrl/creator/podcasts';
  static String get _createPodcastUrl => '$_creatorApiUrl/creator/podcasts';

// --- HÀM HELPER MỚI ĐỂ LẤY HEADER CÓ TOKEN ---
  static Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token != null) {
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    }
    return {'Content-Type': 'application/json'};
  }

  // ========================================================================
  // === CÁC HÀM MỚI =======================================================
  // ========================================================================

  static Future<ApiResult<MySubscription>> getMySubscription() async {
    final url = Uri.parse(_mySubscriptionUrl);
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 15));

      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode != 200 || !(jsonResponse['isSuccess'] ?? false)) {
        return ApiResult(isSuccess: false, message: jsonResponse['message'] ?? 'Lỗi tải thông tin gói cước');
      }

      // API này trả về object trực tiếp trong `data`
      return ApiResult.fromJson(
        jsonResponse,
        (dataJson) => MySubscription.fromJson(dataJson as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResult(isSuccess: false, message: 'Đã có lỗi không mong muốn xảy ra: ${e.toString()}');
    }
  }


  static Future<ApiResult<List<PaymentMethod>>> getPaymentMethods() async {
    final url = Uri.parse('$_paymentMethodsUrl?status=1');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200 || !(jsonDecode(response.body)['isSuccess'] ?? false)) {
        return ApiResult(isSuccess: false, message: jsonDecode(response.body)['message'] ?? 'Lỗi tải phương thức thanh toán');
      }

      final jsonResponse = jsonDecode(response.body);
      final itemsList = jsonResponse['items'] as List<dynamic>?;
      if (itemsList == null) {
        return ApiResult(isSuccess: false, message: 'Dữ liệu trả về không đúng định dạng (key items is null).');
      }

      final methods = itemsList.map((item) => PaymentMethod.fromJson(item as Map<String, dynamic>)).toList();
      return ApiResult(isSuccess: true, data: methods);

    } catch (e) {
      return ApiResult(isSuccess: false, message: 'Đã có lỗi không mong muốn xảy ra: ${e.toString()}');
    }
  }

  static Future<ApiResult<SubscriptionRegistrationResponse>> registerSubscription({
    required String planId,
    required String paymentMethodId,
  }) async {
    final url = Uri.parse(_registerSubscriptionUrl);
    final body = {
      'subscriptionPlanId': planId,
      'paymentMethodId': paymentMethodId,
    };

    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 20));

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode != 200 || !(jsonResponse['isSuccess'] ?? false)) {
          return ApiResult(
            isSuccess: false,
            message: jsonResponse['message'] as String?,
            errors: (jsonResponse['errors'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
            errorCode: jsonResponse['errorCode'] as String?,
          );
      }

      return ApiResult.fromJson(
        jsonResponse,
        (dataJson) => SubscriptionRegistrationResponse.fromJson(dataJson as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResult(isSuccess: false, message: 'Lỗi đăng ký gói: ${e.toString()}');
    }
  }

  static Future<ApiResult<List<SubscriptionPlan>>> getSubscriptionPlans({
    int page = 1,
    int pageSize = 10,
  }) async {
    final url = Uri.parse('$_plansUrl?page=$page&pageSize=$pageSize');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers).timeout(
          const Duration(seconds: 15));

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode != 200 || !(jsonResponse['isSuccess'] ?? false)) {
         return ApiResult(isSuccess: false, message: jsonResponse['message'] ?? 'Lỗi tải các gói subscription');
      }

      final itemsList = jsonResponse['items'] as List<dynamic>?;
      if (itemsList == null) {
        return ApiResult(
            isSuccess: false, message: 'Dữ liệu trả về không đúng định dạng (key items is null).');
      }

      final plans = itemsList.map((planJson) =>
          SubscriptionPlan.fromJson(planJson as Map<String, dynamic>)).toList();

      return ApiResult(
        isSuccess: true,
        data: plans,
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


  // ... (các hàm còn lại giữ nguyên) ...
  Future<dynamic> createPodcast({
    required String authToken,
    required String title,
    required String description,
    required XFile thumbnailFile,
    required String audioFilePath,
    required String audioFileName,
    required String seriesName,
    required String guestName,
    required int episodeNumber,
    required int topicCategories,
    required String hostName,
    required int duration,
    required int emotionCategories,
    required String tags,
    required String transcriptUrl,
  }) async {
    final url = Uri.parse(_createPodcastUrl);
    final request = http.MultipartRequest('POST', url);

    request.headers['Authorization'] = 'Bearer $authToken';

    request.fields['Title'] = title;
    request.fields['Description'] = description;
    request.fields['SeriesName'] = seriesName;
    request.fields['GuestName'] = guestName;
    request.fields['EpisodeNumber'] = episodeNumber.toString();
    request.fields['TopicCategories'] = topicCategories.toString();
    request.fields['HostName'] = hostName;
    request.fields['Duration'] = duration.toString();
    request.fields['EmotionCategories'] = emotionCategories.toString();
    request.fields['Tags'] = tags;
    request.fields['TranscriptUrl'] = transcriptUrl;

    request.files.add(await http.MultipartFile.fromPath(
      'Thumbnail',
      thumbnailFile.path,
      contentType: MediaType('image', 'jpeg'),
    ));

    request.files.add(await http.MultipartFile.fromPath(
      'AudioFile',
      audioFilePath,
      filename: audioFileName,
      contentType: MediaType('audio', 'mpeg'),
    ));

    final response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseBody = await response.stream.bytesToString();
      return jsonDecode(responseBody);
    } else {
      throw Exception('Failed to create podcast: ${response.statusCode}');
    }
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

  static Future<ApiResult<dynamic>> verifyOtp({
    required String contact,
    required String otpCode,
  }) async {
    final url = Uri.parse(_verifyOtpUrl);
    final body = {
      'contact': contact,
      'otpCode': otpCode,
      'otpSentChannel': 1,
      'otpType': 1,
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

      return ApiResult.fromJson(
        jsonResponse,
            (dataJson) =>
            UserProfile.fromJson(jsonResponse),
      );
    } catch (e) {
      return ApiResult(isSuccess: false,
          message: 'Lỗi lấy thông tin người dùng: ${e.toString()}');
    }
  }

  static Future<ApiResult<dynamic>> submitCreatorApplication(
      CreatorApplication application) async {
    final body = application.toJson();
    final url = Uri.parse(_creatorApplicationUrl);
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseBody = jsonDecode(response.body);
        return ApiResult(
          isSuccess: responseBody['success'] ?? true,
          message: responseBody['message'] ?? 'Gửi đơn thành công!',
          data: responseBody,
        );
      } else {
        final errorBody = jsonDecode(response.body);
        String errorMessage = 'Lỗi ${response.statusCode}. Server không phản hồi.';
        if (errorBody['errors'] != null && errorBody['errors'] is Map) {
          final validationErrors = (errorBody['errors'] as Map).values
              .expand((list) => list as Iterable)
              .join('; ');
          errorMessage = 'Lỗi xác thực: $validationErrors';
        }
        return ApiResult(isSuccess: false, message: errorMessage);
      }
    } catch (e) {
      return ApiResult(isSuccess: false, message: 'Đã xảy ra lỗi kết nối: ${e.toString()}');
    }
  }

  static Future<ApiResult<CreatorApplicationStatus>>
      getMyCreatorApplicationStatus() async {
    final url = Uri.parse(_creatorStatusUrl);
    try {
      final headers = await _getAuthHeaders();
      final response =
          await http.get(url, headers: headers).timeout(const Duration(seconds: 15));

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
            isSuccess: false, message: 'Lỗi ${response.statusCode}: ${jsonResponse['message']}');
      }

      final itemsList = jsonResponse['podcasts'] as List<dynamic>?;
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
