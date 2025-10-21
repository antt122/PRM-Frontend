
import 'dart:convert';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/CmsUser.dart';
import '../models/CmsUserProfile.dart';
import '../models/CreatePlanRequest.dart';
import '../models/CreateUserResponse.dart';
import '../models/CreatorApplicationDetail.dart';
import '../models/CreatorApplicationListItem.dart';
import '../models/LoginData.dart';
import '../models/PaginatedResult.dart';
import '../models/SubscriptionFilters.dart';
import '../models/UpdatePlanRequest.dart';
import '../models/UpdateUserResponse.dart';
import '../models/UserDetail.dart';
import '../models/ApiResult.dart';




import '../models/Subscription.dart';
import '../models/SubscriptionPlan.dart';
import '../models/SubscriptionPlanFilters.dart';
import '../models/UpdateSubscriptionRequest.dart';
class ApiService {
  // --- CÁC URL ĐƯỢC CHUYỂN THÀNH GETTER ĐỂ TRÁNH RACE CONDITION ---
  static String get _baseUrl => dotenv.env['BASE_URL'] ?? '';

  static String get _authUrl => '$_baseUrl/user/auth';
  static String get _userUrl => '$_baseUrl/user';
  static String get _creatorApiUrl => '$_baseUrl';
  static String get _cmsUrl => '$_baseUrl/cms';

  static String get _creatorApplicationsUrl => '$_baseUrl/CreatorApplications';

  static String get _loginUrl => '$_cmsUrl/auth/login';

  static String get _createCmsUserUrl => '$_cmsUrl/users';

  static String get _logoutUrl => '$_cmsUrl/logout';

  static String get _getCmsUsersUrl => '$_cmsUrl/users';

  static String get _getCmsUserProfileUrl => '$_cmsUrl/users/profile';

  static String get _cmsUsersUrlProfileDetail => '$_cmsUrl/users';
  static String get _getUserSubscriptionsCms=> '$_cmsUrl/subscriptions';
  static String get _getSubscriptionPlansCms => '$_cmsUrl/subscription-plans';
  static String get _refreshTokenCms => '$_cmsUrl/auth/refresh-token';




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


  Future<ApiResult<CreateUserResponse>> createUser({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String address,
    required int role, // 0: User, 1: Creator, etc.
  }) async {
    final url = Uri.parse(_createCmsUserUrl);
    final body = {
      'email': email,
      'password': password,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'address': address,
      'role': role,
    };

    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      final jsonResponse = jsonDecode(response.body);

      return ApiResult.fromJson(
        jsonResponse,
            (data) => CreateUserResponse.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResult(
          isSuccess: false, message: 'Đã xảy ra lỗi: ${e.toString()}');
    }
  }


  Future<ApiResult<dynamic>> logout() async {
    final url = Uri.parse(_logoutUrl);
    try {
      final headers = await _getAuthHeaders();
      // API logout chỉ cần gọi POST mà không cần body
      final response = await http.post(
        url,
        headers: headers,
      );

      final jsonResponse = jsonDecode(response.body);
      // API này không trả về 'data' nên ta truyền vào hàm parse là null
      return ApiResult.fromJson(jsonResponse, (data) => null);
    } catch (e) {
      // Ngay cả khi API lỗi, chúng ta vẫn nên coi như đăng xuất thành công ở phía client
      return ApiResult(isSuccess: true,
          message: 'Đã xảy ra lỗi phía server, nhưng client sẽ đăng xuất.');
    }
  }


  Future<ApiResult<PaginatedResult<CmsUser>>> getUsers({
    int page = 1,
    int pageSize = 10,
    String? search,
    String sortBy = 'createdAt',
    bool isAscending = false,
    int? status, // Thêm tham số status
  }) async {
    final queryParams = {
      'page': page.toString(),
      'pageSize': pageSize.toString(),
      'sortBy': sortBy,
      'isAscending': isAscending.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
      if (status != null) 'status': status.toString(), // Thêm status vào query
    };
    final uri = Uri.parse(_getCmsUsersUrl).replace(
        queryParameters: queryParams);

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers);
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['isSuccess'] == true) {
        // Trường hợp thành công
        final paginatedData = PaginatedResult.fromJson(
            jsonResponse, (userJson) => CmsUser.fromJson(userJson));
        return ApiResult(isSuccess: true, data: paginatedData);
      } else {
        // SỬA LỖI: Trường hợp thất bại, tạo đối tượng ApiResult trực tiếp
        return ApiResult(
          isSuccess: jsonResponse['isSuccess'] ?? false,
          message: jsonResponse['message'],
          errors: (jsonResponse['errors'] as List<dynamic>?)?.cast<String>(),
          errorCode: jsonResponse['errorCode'],
        );
      }
    } catch (e) {
      return ApiResult(
          isSuccess: false, message: 'Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  Future<ApiResult<CmsUserProfile>> getCmsUserProfile() async {
    final uri = Uri.parse(_getCmsUserProfileUrl);
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers);
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['isSuccess'] == true) {
        return ApiResult.fromJson(jsonResponse, (data) =>
            CmsUserProfile.fromJson(data as Map<String, dynamic>));
      } else {
        return ApiResult(
          isSuccess: jsonResponse['isSuccess'] ?? false,
          message: jsonResponse['message'],
        );
      }
    } catch (e) {
      return ApiResult(
          isSuccess: false, message: 'Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  Future<ApiResult<UserDetail>> getUserDetails(String userId) async {
    final uri = Uri.parse('$_cmsUsersUrlProfileDetail/$userId');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers);
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['isSuccess'] == true) {
        return ApiResult.fromJson(
            jsonResponse, (data) =>
            UserDetail.fromJson(data as Map<String, dynamic>));
      } else {
        return ApiResult(
          isSuccess: jsonResponse['isSuccess'] ?? false,
          message: jsonResponse['message'],
        );
      }
    } catch (e) {
      return ApiResult(
          isSuccess: false, message: 'Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  Future<ApiResult<UpdateUserResponse>> updateUserInfo({
    required String userId,
    required String fullName,
    required String email,
    required String? phoneNumber,
    required String? address,
  }) async {
    final uri = Uri.parse('$_createCmsUserUrl/$userId');
    final body = jsonEncode({
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
    });
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(uri, headers: headers, body: body);
      final jsonResponse = jsonDecode(response.body);
      return ApiResult.fromJson(jsonResponse, (data) =>
          UpdateUserResponse.fromJson(data as Map<String, dynamic>));
    } catch (e) {
      return ApiResult(
          isSuccess: false, message: 'Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  // --- HÀM 2: CẬP NHẬT VAI TRÒ (ĐÃ SỬA LỖI) ---
  Future<ApiResult<dynamic>> updateUserRoles({
    required String userId,
    required List<int> rolesToAdd,
    required List<int> rolesToRemove,
  }) async {
    final uri = Uri.parse('$_createCmsUserUrl/$userId/roles');
    final body = jsonEncode({
      'rolesToAdd': rolesToAdd,
      'rolesToRemove': rolesToRemove,
    });
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(uri, headers: headers, body: body);
      final jsonResponse = jsonDecode(response.body);
      // SỬA LỖI: Tạo đối tượng ApiResult trực tiếp để tránh lỗi type generic
      return ApiResult(
        isSuccess: jsonResponse['isSuccess'] ?? false,
        message: jsonResponse['message'],
        errors: (jsonResponse['errors'] as List<dynamic>?)?.cast<String>(),
      );
    } catch (e) {
      return ApiResult(
          isSuccess: false, message: 'Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  // --- HÀM 3: CẬP NHẬT TRẠNG THÁI (ĐÃ SỬA LỖI) ---
  Future<ApiResult<dynamic>> updateUserStatus({
    required String userId,
    required int status,
    required String? reason,
  }) async {
    final uri = Uri.parse('$_createCmsUserUrl/$userId/status');
    final body = jsonEncode({
      'status': status,
      'reason': reason,
    });
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(uri, headers: headers, body: body);
      final jsonResponse = jsonDecode(response.body);
      // SỬA LỖI: Tạo đối tượng ApiResult trực tiếp
      return ApiResult(
        isSuccess: jsonResponse['isSuccess'] ?? false,
        message: jsonResponse['message'],
        errors: (jsonResponse['errors'] as List<dynamic>?)?.cast<String>(),
      );
    } catch (e) {
      return ApiResult(
          isSuccess: false, message: 'Đã xảy ra lỗi: ${e.toString()}');
    }
  }
  // --- HÀM 1: LẤY DANH SÁCH ĐƠN (ĐÃ CẬP NHẬT) ---
  Future<ApiResult<List<CreatorApplicationListItem>>> getPendingApplications({int pageNumber = 1, int pageSize = 10}) async {
    final uri = Uri.parse('$_creatorApplicationsUrl/pending').replace(queryParameters: {
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
    });
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers);

      // API này trả về một mảng JSON trực tiếp
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final applications = jsonList.map((item) => CreatorApplicationListItem.fromJson(item)).toList();
        return ApiResult(isSuccess: true, data: applications);
      } else {
        final jsonResponse = jsonDecode(response.body);
        return ApiResult(
          isSuccess: jsonResponse['isSuccess'] ?? false,
          message: jsonResponse['message'],
        );
      }
    } catch (e) {
      return ApiResult(isSuccess: false, message: e.toString());
    }
  }

  Future<ApiResult<CreatorApplicationDetail>> getApplicationDetails(String applicationId) async {
    final uri = Uri.parse('$_creatorApplicationsUrl/$applicationId');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers);
      final jsonResponse = jsonDecode(response.body);

      // API này trả về dữ liệu trực tiếp, không có cấu trúc isSuccess/data
      if (response.statusCode == 200) {
        final detail = CreatorApplicationDetail.fromJson(jsonResponse);
        return ApiResult(isSuccess: true, data: detail);
      } else {
        // Xử lý các mã lỗi khác từ server
        return ApiResult(
          isSuccess: false,
          message: jsonResponse['message'] as String? ?? 'Lỗi ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResult(isSuccess: false, message: e.toString());
    }
  }

  Future<ApiResult<dynamic>> approveApplication({required String applicationId, String? notes}) async {
    final uri = Uri.parse('$_creatorApplicationsUrl/$applicationId/approve');
    final body = jsonEncode({'applicationId': applicationId, 'notes': notes});
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(uri, headers: headers, body: body);
      final jsonResponse = jsonDecode(response.body);
      return ApiResult(
        isSuccess: jsonResponse['success'] ?? false,
        message: jsonResponse['message'],
      );
    } catch (e) {
      return ApiResult(isSuccess: false, message: e.toString());
    }
  }

  Future<ApiResult<dynamic>> rejectApplication({required String applicationId, required String reason, String? notes}) async {
    final uri = Uri.parse('$_creatorApplicationsUrl/$applicationId/reject');
    final body = jsonEncode({'applicationId': applicationId, 'rejectionReason': reason, 'notes': notes});
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(uri, headers: headers, body: body);
      final jsonResponse = jsonDecode(response.body);
      return ApiResult(
        isSuccess: jsonResponse['success'] ?? false,
        message: jsonResponse['message'],
      );
    } catch (e) {
      return ApiResult(isSuccess: false, message: e.toString());
    }
  }

  Future<ApiResult<PaginatedResult<Subscription>>> getSubscriptions(
      SubscriptionFilters filters,
      ) async {
    final queryParams = filters.toQueryParameters();
    final uri = Uri.parse(_getUserSubscriptionsCms).replace(queryParameters: queryParams);

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 20));
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['isSuccess'] == true) {
        final paginatedData = PaginatedResult.fromJson(
          jsonResponse,
              (itemJson) => Subscription.fromJson(itemJson as Map<String, dynamic>),
        );
        return ApiResult(isSuccess: true, data: paginatedData);
      } else {
        return ApiResult(
          isSuccess: jsonResponse['isSuccess'] ?? false,
          message: jsonResponse['message'],
          errorCode: jsonResponse['errorCode'],
        );
      }
    } catch (e) {
      return ApiResult(isSuccess: false, message: "Đã xảy ra lỗi: ${e.toString()}");
    }
  }

  Future<ApiResult<Subscription>> getSubscriptionById(String subscriptionId) async {
    // URL sẽ có dạng /api/cms/subscriptions/your-id-here
    final uri = Uri.parse('$_getUserSubscriptionsCms/$subscriptionId');

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers);
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['isSuccess'] == true) {
        // API trả về một object 'data', không phải 'items' như trong danh sách
        final subscription = Subscription.fromJson(jsonResponse['data']);
        return ApiResult(isSuccess: true, data: subscription);
      } else {
        // Xử lý các lỗi như 404 Not Found
        return ApiResult(
          isSuccess: false,
          message: jsonResponse['message'] ?? 'Lỗi không xác định',
          errorCode: jsonResponse['errorCode'],
        );
      }
    } catch (e) {
      return ApiResult(isSuccess: false, message: "Lỗi kết nối: ${e.toString()}");
    }
  }

  Future<ApiResult<PaginatedResult<SubscriptionPlan>>> getSubscriptionPlans(
      SubscriptionPlanFilters filters,
      ) async {
    final queryParams = filters.toQueryParameters();
    final uri = Uri.parse(_getSubscriptionPlansCms).replace(queryParameters: queryParams);

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers);
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['isSuccess'] == true) {
        final paginatedData = PaginatedResult.fromJson(
          jsonResponse,
              (itemJson) => SubscriptionPlan.fromJson(itemJson as Map<String, dynamic>),
        );
        return ApiResult(isSuccess: true, data: paginatedData);
      } else {
        return ApiResult(
          isSuccess: false,
          message: jsonResponse['message'] ?? 'Lỗi không xác định',
          errorCode: jsonResponse['errorCode'],
        );      }
    } catch (e) {
      return ApiResult(isSuccess: false, message: "Đã xảy ra lỗi: ${e.toString()}");
    }
  }

  Future<ApiResult<Subscription>> updateSubscription(
      String subscriptionId,
      UpdateSubscriptionRequest requestData,
      ) async {
    // Sử dụng _getSubscriptionsUrl cho nhất quán
    final uri = Uri.parse('$_getUserSubscriptionsCms/$subscriptionId');
    try {
      // --- SỬA LỖI 3: Lấy header có token xác thực ---
      final headers = await _getAuthHeaders();
      final response = await http.put(
        uri,
        headers: headers, // Sử dụng header đã lấy
        body: json.encode(requestData.toJson()),
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200 && jsonResponse['isSuccess'] == true) {
        return ApiResult.fromJson(
          jsonResponse,
          // --- SỬA LỖI 1: Thêm ép kiểu (cast) ---
              (data) => Subscription.fromJson(data as Map<String, dynamic>),
        );
      } else {
        // --- SỬA LỖI 2: Tạo đối tượng ApiResult trực tiếp để đúng kiểu trả về ---
        return ApiResult<Subscription>(
          isSuccess: jsonResponse['isSuccess'] ?? false,
          message: jsonResponse['message'] ?? 'Đã xảy ra lỗi không xác định',
          errorCode: jsonResponse['errorCode']?.toString(),
          data: null, // Dữ liệu là null khi thất bại
        );
      }
    } catch (e) {
      return ApiResult<Subscription>(
        isSuccess: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: null,
      );
    }
  }

  Future<ApiResult<Subscription>> cancelSubscription({
    required String subscriptionId,
    required bool cancelAtPeriodEnd,
    String? reason,
  }) async {
    // URL sẽ có dạng /api/cms/subscriptions/{id}/cancel
    final uri = Uri.parse('$_getUserSubscriptionsCms/$subscriptionId/cancel').replace(
      queryParameters: {
        'cancelAtPeriodEnd': cancelAtPeriodEnd.toString(),
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      },
    );

    try {
      final headers = await _getAuthHeaders();
      // API này dùng phương thức POST và không có body
      final response = await http.post(uri, headers: headers);
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['isSuccess'] == true) {
        return ApiResult.fromJson(
          jsonResponse,
              (data) => Subscription.fromJson(data as Map<String, dynamic>),
        );
      } else {
        return ApiResult<Subscription>(
          isSuccess: false,
          message: jsonResponse['message'] ?? 'Lỗi không xác định',
          errorCode: jsonResponse['errorCode']?.toString(),
        );
      }
    } catch (e) {
      return ApiResult(isSuccess: false, message: "Lỗi kết nối: ${e.toString()}");
    }
  }

  // --- HÀM MỚI ĐỂ TẠO SUBSCRIPTION PLAN ---
  Future<ApiResult<SubscriptionPlan>> createSubscriptionPlan(
      CreatePlanRequest requestData,
      ) async {
    final uri = Uri.parse(_getSubscriptionPlansCms);
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(requestData.toJson()),
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200 && jsonResponse['isSuccess'] == true) {
        return ApiResult.fromJson(
          jsonResponse,
              (data) => SubscriptionPlan.fromJson(data as Map<String, dynamic>),
        );
      } else {
        // Xử lý lỗi validation hoặc conflict
        return ApiResult<SubscriptionPlan>(
          isSuccess: false,
          message: jsonResponse['message'] ?? 'Đã xảy ra lỗi',
          // API của bạn trả về 'errors' là một object, không phải list string
          // Bạn có thể xử lý nó chi tiết hơn nếu cần
          errors: jsonResponse['errors'] != null ? [jsonEncode(jsonResponse['errors'])] : null,
          errorCode: jsonResponse['statusCode']?.toString(),
        );
      }
    } catch (e) {
      return ApiResult(isSuccess: false, message: "Lỗi kết nối: ${e.toString()}");
    }
  }

  Future<ApiResult<SubscriptionPlan>> getSubscriptionPlanById(String planId) async {
    final uri = Uri.parse('$_getSubscriptionPlansCms/$planId');

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers);
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['isSuccess'] == true) {
        // API trả về một object 'data'
        final plan = SubscriptionPlan.fromJson(jsonResponse['data'] as Map<String, dynamic>);
        return ApiResult(isSuccess: true, data: plan);
      } else {
        return ApiResult<SubscriptionPlan>(
          isSuccess: false,
          message: jsonResponse['message'] ?? 'Lỗi không xác định',
          errorCode: jsonResponse['statusCode']?.toString(),
        );
      }
    } catch (e) {
      return ApiResult(isSuccess: false, message: "Lỗi kết nối: ${e.toString()}");
    }

  }
  Future<ApiResult<SubscriptionPlan>> updateSubscriptionPlan(
      String planId,
      UpdatePlanRequest requestData,
      ) async {
    final uri = Uri.parse('$_getSubscriptionPlansCms/$planId');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        uri,
        headers: headers,
        body: json.encode(requestData.toJson()),
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200 && jsonResponse['isSuccess'] == true) {
        return ApiResult.fromJson(
          jsonResponse,
              (data) => SubscriptionPlan.fromJson(data as Map<String, dynamic>),
        );
      } else {
        return ApiResult<SubscriptionPlan>(
          isSuccess: false,
          message: jsonResponse['message'] ?? 'Đã xảy ra lỗi',
          errors: jsonResponse['errors'] != null ? [jsonEncode(jsonResponse['errors'])] : null,
          errorCode: jsonResponse['statusCode']?.toString(),
        );
      }
    } catch (e) {
      return ApiResult(isSuccess: false, message: "Lỗi kết nối: ${e.toString()}");
    }
  }
  Future<ApiResult<dynamic>> deleteSubscriptionPlan(String planId) async {
    final uri = Uri.parse('$_getSubscriptionPlansCms/$planId');

    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(uri, headers: headers);
      final jsonResponse = jsonDecode(response.body);

      // API xóa thành công thường trả về data là null
      if (response.statusCode == 200 && jsonResponse['isSuccess'] == true) {
        return ApiResult.fromJson(jsonResponse, (data) => null);
      } else {
        // Xử lý các lỗi như 400, 404
        return ApiResult(
          isSuccess: false,
          message: jsonResponse['message'] ?? 'Lỗi không xác định',
          errorCode: jsonResponse['statusCode']?.toString(),
        );
      }
    } catch (e) {
      return ApiResult(isSuccess: false, message: "Lỗi kết nối: ${e.toString()}");
    }
  }
}


