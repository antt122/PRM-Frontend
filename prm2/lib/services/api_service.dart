
import 'dart:convert';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
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
import '../models/podcast.dart';
import '../models/pagination_result.dart';
import '../models/podcast_category.dart';
import '../models/podcast_recommendation.dart';

class ApiService {
  // --- CÁC URL ĐƯỢC CHUYỂN THÀNH GETTER ĐỂ TRÁNH RACE CONDITION ---
  static String get _baseUrl => dotenv.env['BASE_URL'] ?? '';

  static String get _authUrl => '$_baseUrl/user/auth';
  static String get _userUrl => '$_baseUrl/user';
  static String get _cmsUrl => '$_baseUrl/cms';

  static String get _registerUrl => '$_authUrl/register';
  static String get _verifyOtpUrl => '$_authUrl/verify-otp';
  static String get _loginUrl => '$_authUrl/login';
  static String get _plansUrl => '$_userUrl/subscription-plans';
  static String get _paymentMethodsUrl => '$_userUrl/payment-methods';
  static String get _registerSubscriptionUrl => '$_userUrl/subscriptions/register';
  static String get _mySubscriptionUrl => '$_userUrl/subscriptions/me'; // <-- THÊM MỚI
  static String get _checkoutUrl => '$_userUrl/profile';
  static String get _creatorApplicationUrl => '$_userUrl/CreatorApplications';
  static String get _creatorStatusUrl => '$_userUrl/CreatorApplications/my-status';
  static String get _creatorPodcastsUrl => '$_baseUrl/content/creator/podcasts';
  static String get _createPodcastUrl => '$_baseUrl/content/creator/podcasts';
  static String get _userPodcastsUrl => '$_baseUrl/content/user/podcasts';
  static String get _recommendationsUrl => '$_baseUrl/recommendations';

  // --- HÀM HELPER MỚI ĐỂ LẤY HEADER CÓ TOKEN ---
  static Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    final headers = {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',  // Bypass ngrok free tier browser warning
      'User-Agent': 'Flutter-Client',  // Identify as non-browser for ngrok
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
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
  
  /// Create a new podcast with audio and thumbnail file upload
  /// 
  /// Parameters:
  /// - title: Podcast title (required, 3-200 chars)
  /// - description: Podcast description (required, 10-2000 chars)
  /// - audioFile: Audio file to upload (required, MP3/WAV/OGG/M4A/MP4, max 500MB)
  /// - thumbnailFile: Thumbnail image file (optional, JPG/PNG/WEBP, max 10MB)
  /// - duration: Duration in seconds (required, 1-18000)
  /// - hostName: Host name (optional, max 100 chars)
  /// - guestName: Guest name (optional, max 100 chars)
  /// - episodeNumber: Episode number (optional, default 1)
  /// - seriesName: Series name (optional, max 200 chars)
  /// - tags: List of tags (optional)
  /// - emotionCategories: List of emotion categories (optional)
  /// - topicCategories: List of topic categories (optional)
  /// - transcriptUrl: URL to transcript (optional, max 1000 chars)
  /// 
  /// Returns: CreatePodcastResponse with podcast ID
  /// 
  /// Throws: Exception if upload fails
  static Future<ApiResult> createPodcast({
    required String title,
    required String description,
    required PlatformFile audioFile,
    dynamic thumbnailFile,  // Can be PlatformFile (web) or XFile (mobile)
    required int duration,
    String? hostName,
    String? guestName,
    int episodeNumber = 1,
    String? seriesName,
    List<String>? tags,
    List<EmotionCategory>? emotionCategories,
    List<TopicCategory>? topicCategories,
    String? transcriptUrl,
  }) async {
    try {
      print('DEBUG: Starting createPodcast');
      print('DEBUG: emotionCategories = $emotionCategories');
      print('DEBUG: topicCategories = $topicCategories');
      
      final url = Uri.parse(_createPodcastUrl);
      final headers = await _getAuthHeaders();
      print('DEBUG: Headers prepared');

      // Create multipart request
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll(headers);

      // Add form fields
      request.fields['Title'] = title;
      request.fields['Description'] = description;
      request.fields['Duration'] = duration.toString();
      request.fields['EpisodeNumber'] = episodeNumber.toString();

      // Optional fields
      if (hostName != null && hostName.isNotEmpty) {
        request.fields['HostName'] = hostName;
      }
      if (guestName != null && guestName.isNotEmpty) {
        request.fields['GuestName'] = guestName;
      }
      if (seriesName != null && seriesName.isNotEmpty) {
        request.fields['SeriesName'] = seriesName;
      }
      if (transcriptUrl != null && transcriptUrl.isNotEmpty) {
        request.fields['TranscriptUrl'] = transcriptUrl;
      }

      // Add tags as individual fields (ASP.NET Form Binder expects: Tags=tag1&Tags=tag2)
      if (tags != null && tags.isNotEmpty) {
        for (int i = 0; i < tags.length; i++) {
          request.fields['Tags[$i]'] = tags[i];
        }
      }

      // Add emotion categories as individual fields (ASP.NET Form Binder expects: EmotionCategories[0]=1&EmotionCategories[1]=2)
      // This way ASP.NET Model Binder can properly deserialize to List<EmotionCategory>
      if (emotionCategories != null && emotionCategories.isNotEmpty) {
        print('DEBUG: Adding emotion categories, count=${emotionCategories.length}');
        for (int i = 0; i < emotionCategories.length; i++) {
          final emotion = emotionCategories[i];
          print('DEBUG: emotion[$i] = ${emotion.name}, value = ${emotion.value}');
          request.fields['EmotionCategories[$i]'] = emotion.value.toString();
        }
      }

      // Add topic categories as individual fields (ASP.NET Form Binder expects: TopicCategories[0]=1&TopicCategories[1]=2)
      if (topicCategories != null && topicCategories.isNotEmpty) {
        print('DEBUG: Adding topic categories, count=${topicCategories.length}');
        for (int i = 0; i < topicCategories.length; i++) {
          final topic = topicCategories[i];
          print('DEBUG: topic[$i] = ${topic.name}, value = ${topic.value}');
          request.fields['TopicCategories[$i]'] = topic.value.toString();
        }
      }

      // Add audio file (required)
      // PlatformFile.bytes is pre-loaded on web, so use it directly
      try {
        print('DEBUG: About to process audio file: ${audioFile.name}');
        final audioBytes = audioFile.bytes;
        if (audioBytes == null || audioBytes.isEmpty) {
          throw Exception('Audio file bytes are empty');
        }
        print('DEBUG: Audio file processed successfully, size=${audioBytes.length}');
        
        request.files.add(
          http.MultipartFile.fromBytes(
            'AudioFile',
            audioBytes,
            filename: audioFile.name,
            contentType: MediaType('audio', 'mpeg'),
          ),
        );
      } catch (e) {
        print('ERROR processing audio file: $e');
        rethrow;
      }

      // Add thumbnail file if provided
      if (thumbnailFile != null) {
        try {
          List<int> thumbBytes;
          String thumbFilename;
          
          // Try to extract bytes from different file types
          if (thumbnailFile is PlatformFile) {
            // Web/Mobile file from file_picker
            thumbBytes = thumbnailFile.bytes ?? [];
            thumbFilename = thumbnailFile.name;
          } else if (thumbnailFile is XFile) {
            // Mobile file from image_picker
            thumbBytes = await thumbnailFile.readAsBytes();
            thumbFilename = thumbnailFile.name;
          } else {
            // Try dynamic approach for unknown types
            print('DEBUG: Thumbnail type is ${thumbnailFile.runtimeType}, attempting dynamic extraction');
            
            // Try to call readAsBytes() dynamically
            if (thumbnailFile.readAsBytes != null) {
              thumbBytes = await thumbnailFile.readAsBytes();
            } else if (thumbnailFile.bytes != null) {
              thumbBytes = thumbnailFile.bytes ?? [];
            } else {
              throw Exception('Cannot extract bytes from thumbnail file type: ${thumbnailFile.runtimeType}');
            }
            
            // Try to get filename
            thumbFilename = thumbnailFile.name ?? thumbnailFile.path?.split('/').last ?? 'thumbnail.jpg';
          }
          
          if (thumbBytes.isEmpty) {
            print('WARNING: Thumbnail file bytes are empty, skipping thumbnail upload');
            // Don't throw - allow podcast creation without thumbnail
          } else {
            print('DEBUG: Thumbnail file processed successfully, size=${thumbBytes.length}');
            
            request.files.add(
              http.MultipartFile.fromBytes(
                'ThumbnailFile',
                thumbBytes,
                filename: thumbFilename,
                contentType: MediaType('image', 'jpeg'),
              ),
            );
          }
        } catch (e) {
          print('ERROR processing thumbnail file: $e');
          print('WARNING: Continuing without thumbnail - thumbnail is optional');
          // Don't rethrow - thumbnail is optional
        }
      }

      // Send request
      print('DEBUG: About to send request to $_createPodcastUrl');
      print('DEBUG: Form fields keys: ${request.fields.keys.toList()}');
      print('DEBUG: Form files count: ${request.files.length}');
      final streamedResponse = await request.send();
      print('DEBUG: Request sent successfully, awaiting response...');
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        // Parse response - backend returns { isSuccess, message, data: {...podcast...} }
        return ApiResult(
          isSuccess: true,
          message: 'Podcast created successfully',
          data: jsonResponse['data'] ?? jsonResponse,
          errorCode: null,
        );
      } else if (response.statusCode == 400) {
        final jsonResponse = jsonDecode(response.body);
        return ApiResult(
          isSuccess: false,
          message: jsonResponse['message'] ?? 'Validation error',
          errors: List<String>.from(jsonResponse['errors'] ?? []),
          errorCode: '400',
        );
      } else if (response.statusCode == 401) {
        return ApiResult(
          isSuccess: false,
          message: 'Unauthorized - Please login again',
          errorCode: '401',
        );
      } else if (response.statusCode == 413) {
        return ApiResult(
          isSuccess: false,
          message: 'File too large - Maximum size is 500MB',
          errorCode: '413',
        );
      } else {
        return ApiResult(
          isSuccess: false,
          message: 'Failed to create podcast: ${response.statusCode}',
          errorCode: '${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      print('ERROR: Exception in createPodcast: $e');
      print('ERROR: Stack trace: $stackTrace');
      return ApiResult(
        isSuccess: false,
        message: 'Error creating podcast: ${e.toString()}',
        errorCode: 'EXCEPTION',
      );
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
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'User-Agent': 'Flutter-Client',
        },
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
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'User-Agent': 'Flutter-Client',
        },
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
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'User-Agent': 'Flutter-Client',
        },
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
        Uri.parse('$_cmsUrl/posts/my-posts?page=$page&pageSize=$pageSize');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers);
      final jsonResponse = jsonDecode(response.body);
      print("jsonResponse: $jsonResponse");
      if (response.statusCode != 200) {
        return ApiResult(
            isSuccess: false, message: 'Lỗi ${response.statusCode}: ${jsonResponse['message']}');
      }

      final itemsList = jsonResponse['posts'] as List<dynamic>?;
      if (itemsList == null) {
        return ApiResult(
            isSuccess: false, message: 'Dữ liệu trả về không đúng định dạng.');
      }

      final posts = itemsList.map((p) => MyPost.fromJson(p)).toList();
      return ApiResult(isSuccess: true, data: posts);
    } catch (e) {
      print("error: $e");
      return ApiResult(isSuccess: false, message: e.toString());
    }
  }

  /// Get creator's podcasts (for Creator Dashboard)
  static Future<PaginationResult<Podcast>> getMyPodcasts({
    int page = 1,
    int pageSize = 20,
  }) async {
    final url = Uri.parse('$_creatorPodcastsUrl/my-podcasts?page=$page&pageSize=$pageSize');
    
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers);
      
      print('[getMyPodcasts] Status: ${response.statusCode}');
      print('[getMyPodcasts] URL: $url');
      print('[getMyPodcasts] Body: ${response.body}');
      
      if (response.statusCode == 404) {
        return PaginationResult<Podcast>(
          currentPage: page,
          pageSize: pageSize,
          totalItems: 0,
          totalPages: 0,
          hasPrevious: false,
          hasNext: false,
          items: [],
          isSuccess: false,
          message: 'Endpoint not found. Please check backend route.',
          errorCode: '404',
        );
      }
      
      if (response.statusCode != 200) {
        return PaginationResult<Podcast>(
          currentPage: page,
          pageSize: pageSize,
          totalItems: 0,
          totalPages: 0,
          hasPrevious: false,
          hasNext: false,
          items: [],
          isSuccess: false,
          message: 'Error ${response.statusCode}: ${response.body}',
          errorCode: response.statusCode.toString(),
        );
      }

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      
      // Backend returns: { podcasts: [...], totalCount, page, pageSize }
      final podcastsList = jsonResponse['podcasts'] as List<dynamic>?;
      if (podcastsList == null) {
        return PaginationResult<Podcast>(
          currentPage: page,
          pageSize: pageSize,
          totalItems: 0,
          totalPages: 0,
          hasPrevious: false,
          hasNext: false,
          items: [],
          isSuccess: false,
          message: 'Invalid response format',
        );
      }

      final podcasts = podcastsList
          .map((json) => Podcast.fromJson(json as Map<String, dynamic>))
          .toList();
      
      final totalCount = jsonResponse['totalCount'] as int? ?? 0;
      final totalPages = (totalCount / pageSize).ceil();

      return PaginationResult<Podcast>(
        currentPage: page,
        pageSize: pageSize,
        totalItems: totalCount,
        totalPages: totalPages,
        hasPrevious: page > 1,
        hasNext: page < totalPages,
        items: podcasts,
        isSuccess: true,
        message: 'Success',
      );
    } catch (e) {
      print('[getMyPodcasts] Error: $e');
      return PaginationResult<Podcast>(
        currentPage: page,
        pageSize: pageSize,
        totalItems: 0,
        totalPages: 0,
        hasPrevious: false,
        hasNext: false,
        items: [],
        isSuccess: false,
        message: 'Exception: $e',
      );
    }
  }

  // ========================================================================
  // === PODCAST APIs FOR USERS ============================================
  // ========================================================================

  /// Get published podcasts for listening (trending/latest/by category)
  static Future<PaginationResult<Podcast>> getPodcasts({
    int page = 1,
    int pageSize = 10,
    List<int>? emotionCategories,
    List<int>? topicCategories,
    String? searchTerm,
    String? seriesName,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'pageSize': pageSize.toString(),
      if (emotionCategories != null && emotionCategories.isNotEmpty)
        'emotionCategories': emotionCategories.join(','),
      if (topicCategories != null && topicCategories.isNotEmpty)
        'topicCategories': topicCategories.join(','),
      if (searchTerm != null && searchTerm.isNotEmpty) 'searchTerm': searchTerm,
      if (seriesName != null && seriesName.isNotEmpty) 'seriesName': seriesName,
    };

    final url = Uri.parse(_userPodcastsUrl).replace(queryParameters: queryParams);

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        return PaginationResult<Podcast>(
          currentPage: page,
          pageSize: pageSize,
          totalItems: 0,
          totalPages: 0,
          hasPrevious: false,
          hasNext: false,
          items: [],
          isSuccess: false,
          message: 'Lỗi ${response.statusCode}',
        );
      }

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      
      // Parse response with correct structure: { podcasts: [...], totalCount, page, pageSize }
      final podcastsList = jsonResponse['podcasts'] as List<dynamic>?;
      if (podcastsList == null) {
        return PaginationResult<Podcast>(
          currentPage: page,
          pageSize: pageSize,
          totalItems: 0,
          totalPages: 0,
          hasPrevious: false,
          hasNext: false,
          items: [],
          isSuccess: false,
          message: 'Invalid response format',
        );
      }

      final podcasts = podcastsList
          .map((json) => Podcast.fromJson(json as Map<String, dynamic>))
          .toList();
      
      final totalCount = jsonResponse['totalCount'] as int? ?? 0;
      final totalPages = (totalCount / pageSize).ceil();

      return PaginationResult<Podcast>(
        currentPage: page,
        pageSize: pageSize,
        totalItems: totalCount,
        totalPages: totalPages,
        hasPrevious: page > 1,
        hasNext: page < totalPages,
        items: podcasts,
        isSuccess: true,
        message: 'Success',
      );
    } catch (e) {
      return PaginationResult<Podcast>(
        currentPage: page,
        pageSize: pageSize,
        totalItems: 0,
        totalPages: 0,
        hasPrevious: false,
        hasNext: false,
        items: [],
        isSuccess: false,
        message: 'Lỗi: ${e.toString()}',
      );
    }
  }

  /// Get trending podcasts (most viewed)
  static Future<PaginationResult<Podcast>> getTrendingPodcasts({
    int page = 1,
    int pageSize = 10,
  }) async {
    final url = Uri.parse('$_userPodcastsUrl/trending?page=$page&pageSize=$pageSize');

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        return PaginationResult<Podcast>(
          currentPage: page,
          pageSize: pageSize,
          totalItems: 0,
          totalPages: 0,
          hasPrevious: false,
          hasNext: false,
          items: [],
          isSuccess: false,
          message: 'Lỗi ${response.statusCode}',
        );
      }

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      
      // Parse response with correct structure: { podcasts: [...], totalCount, page, pageSize }
      final podcastsList = jsonResponse['podcasts'] as List<dynamic>?;
      if (podcastsList == null) {
        return PaginationResult<Podcast>(
          currentPage: page,
          pageSize: pageSize,
          totalItems: 0,
          totalPages: 0,
          hasPrevious: false,
          hasNext: false,
          items: [],
          isSuccess: false,
          message: 'Invalid response format',
        );
      }

      final podcasts = podcastsList
          .map((json) => Podcast.fromJson(json as Map<String, dynamic>))
          .toList();
      
      final totalCount = jsonResponse['totalCount'] as int? ?? 0;
      final totalPages = (totalCount / pageSize).ceil();

      return PaginationResult<Podcast>(
        currentPage: page,
        pageSize: pageSize,
        totalItems: totalCount,
        totalPages: totalPages,
        hasPrevious: page > 1,
        hasNext: page < totalPages,
        items: podcasts,
        isSuccess: true,
        message: 'Success',
      );
    } catch (e) {
      return PaginationResult<Podcast>(
        currentPage: page,
        pageSize: pageSize,
        totalItems: 0,
        totalPages: 0,
        hasPrevious: false,
        hasNext: false,
        items: [],
        isSuccess: false,
        message: 'Lỗi: ${e.toString()}',
      );
    }
  }

  /// Get latest podcasts
  static Future<PaginationResult<Podcast>> getLatestPodcasts({
    int page = 1,
    int pageSize = 10,
  }) async {
    final url = Uri.parse('$_userPodcastsUrl/latest?page=$page&pageSize=$pageSize');

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        return PaginationResult<Podcast>(
          currentPage: page,
          pageSize: pageSize,
          totalItems: 0,
          totalPages: 0,
          hasPrevious: false,
          hasNext: false,
          items: [],
          isSuccess: false,
          message: 'Lỗi ${response.statusCode}',
        );
      }

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      
      // Parse response with correct structure: { podcasts: [...], totalCount, page, pageSize }
      final podcastsList = jsonResponse['podcasts'] as List<dynamic>?;
      if (podcastsList == null) {
        return PaginationResult<Podcast>(
          currentPage: page,
          pageSize: pageSize,
          totalItems: 0,
          totalPages: 0,
          hasPrevious: false,
          hasNext: false,
          items: [],
          isSuccess: false,
          message: 'Invalid response format',
        );
      }

      final podcasts = podcastsList
          .map((json) => Podcast.fromJson(json as Map<String, dynamic>))
          .toList();
      
      final totalCount = jsonResponse['totalCount'] as int? ?? 0;
      final totalPages = (totalCount / pageSize).ceil();

      return PaginationResult<Podcast>(
        currentPage: page,
        pageSize: pageSize,
        totalItems: totalCount,
        totalPages: totalPages,
        hasPrevious: page > 1,
        hasNext: page < totalPages,
        items: podcasts,
        isSuccess: true,
        message: 'Success',
      );
    } catch (e) {
      return PaginationResult<Podcast>(
        currentPage: page,
        pageSize: pageSize,
        totalItems: 0,
        totalPages: 0,
        hasPrevious: false,
        hasNext: false,
        items: [],
        isSuccess: false,
        message: 'Lỗi: ${e.toString()}',
      );
    }
  }

  /// Get podcast by ID (for users - public/published podcasts only)
  static Future<ApiResult<Podcast>> getPodcastById(String id) async {
    final url = Uri.parse('$_userPodcastsUrl/$id');

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        return ApiResult(isSuccess: false, message: 'Không tìm thấy podcast');
      }

      final jsonResponse = jsonDecode(response.body);
      return ApiResult(isSuccess: true, data: Podcast.fromJson(jsonResponse));
    } catch (e) {
      return ApiResult(isSuccess: false, message: 'Lỗi: ${e.toString()}');
    }
  }

  /// Get podcast by ID for creator (view own podcast regardless of status)
  static Future<ApiResult<Podcast>> getCreatorPodcastById(String id) async {
    final url = Uri.parse('$_creatorPodcastsUrl/$id');

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        return ApiResult(isSuccess: false, message: 'Không tìm thấy podcast (Status: ${response.statusCode})');
      }

      final jsonResponse = jsonDecode(response.body);
      return ApiResult(isSuccess: true, data: Podcast.fromJson(jsonResponse));
    } catch (e) {
      return ApiResult(isSuccess: false, message: 'Lỗi: ${e.toString()}');
    }
  }

  /// Search podcasts
  static Future<PaginationResult<Podcast>> searchPodcasts({
    required String keyword,
    int page = 1,
    int pageSize = 10,
  }) async {
    final url = Uri.parse('$_userPodcastsUrl/search?keyword=$keyword&page=$page&pageSize=$pageSize');

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        return PaginationResult<Podcast>(
          currentPage: page,
          pageSize: pageSize,
          totalItems: 0,
          totalPages: 0,
          hasPrevious: false,
          hasNext: false,
          items: [],
          isSuccess: false,
          message: 'Lỗi ${response.statusCode}',
        );
      }

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      
      // Parse response with correct structure: { podcasts: [...], totalCount, page, pageSize }
      final podcastsList = jsonResponse['podcasts'] as List<dynamic>?;
      if (podcastsList == null) {
        return PaginationResult<Podcast>(
          currentPage: page,
          pageSize: pageSize,
          totalItems: 0,
          totalPages: 0,
          hasPrevious: false,
          hasNext: false,
          items: [],
          isSuccess: false,
          message: 'Invalid response format',
        );
      }

      final podcasts = podcastsList
          .map((json) => Podcast.fromJson(json as Map<String, dynamic>))
          .toList();
      
      final totalCount = jsonResponse['totalCount'] as int? ?? 0;
      final totalPages = (totalCount / pageSize).ceil();

      return PaginationResult<Podcast>(
        currentPage: page,
        pageSize: pageSize,
        totalItems: totalCount,
        totalPages: totalPages,
        hasPrevious: page > 1,
        hasNext: page < totalPages,
        items: podcasts,
        isSuccess: true,
        message: 'Success',
      );
    } catch (e) {
      return PaginationResult<Podcast>(
        currentPage: page,
        pageSize: pageSize,
        totalItems: 0,
        totalPages: 0,
        hasPrevious: false,
        hasNext: false,
        items: [],
        isSuccess: false,
        message: 'Lỗi: ${e.toString()}',
      );
    }
  }

  /// Increment view count
  static Future<void> incrementPodcastView(String podcastId) async {
    final url = Uri.parse('$_userPodcastsUrl/$podcastId/view');
    try {
      final headers = await _getAuthHeaders();
      await http.post(url, headers: headers).timeout(const Duration(seconds: 5));
    } catch (e) {
      // Silent fail - không cần thông báo lỗi cho user
    }
  }

  /// Toggle like podcast (like/unlike)
  static Future<ApiResult<bool>> toggleLikePodcast(String podcastId) async {
    final url = Uri.parse('$_userPodcastsUrl/$podcastId/like');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(url, headers: headers).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResult<bool>(
          isSuccess: true,
          data: data['isLiked'] ?? true,
          message: data['message'] ?? 'Success',
        );
      } else {
        return ApiResult<bool>(
          isSuccess: false,
          message: 'Không thể thực hiện thao tác',
        );
      }
    } catch (e) {
      return ApiResult<bool>(
        isSuccess: false,
        message: 'Lỗi: ${e.toString()}',
      );
    }
  }

  /// Check if user liked a podcast
  static Future<bool> checkPodcastLiked(String podcastId) async {
    final url = Uri.parse('$_userPodcastsUrl/$podcastId/liked');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['isLiked'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get AI-powered podcast recommendations for current user
  static Future<ApiResult<PodcastRecommendationResponse>> getMyRecommendations({
    int? limit,
    bool? includeListened,
  }) async {
    final queryParams = <String, String>{};
    if (limit != null) {
      queryParams['limit'] = limit.toString();
    }
    if (includeListened != null) {
      queryParams['includeListened'] = includeListened.toString();
    }

    final url = Uri.parse('$_recommendationsUrl/me').replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    print('🤖 DEBUG: Calling AI recommendations API: $url');

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 15));

      print('🤖 DEBUG: AI recommendations response status: ${response.statusCode}');
      print('🤖 DEBUG: AI recommendations response body: ${response.body}');

      if (response.statusCode != 200) {
        return ApiResult<PodcastRecommendationResponse>(
          isSuccess: false,
          message: 'Lỗi ${response.statusCode} khi lấy đề xuất AI',
        );
      }

      final jsonResponse = jsonDecode(response.body);
      return ApiResult.fromJson(
        jsonResponse,
        (dataJson) => PodcastRecommendationResponse.fromJson(dataJson as Map<String, dynamic>),
      );
    } catch (e) {
      print('🤖 DEBUG: AI recommendations error: $e');
      return ApiResult<PodcastRecommendationResponse>(
        isSuccess: false,
        message: 'Lỗi: ${e.toString()}',
      );
    }
  }

}
