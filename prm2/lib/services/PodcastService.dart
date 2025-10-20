import 'dart:convert';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/Podcast.dart';
import '../models/PodcastAnalytics.dart';
import '../models/PodcastDetail.dart';
import '../models/PodcastStatistics.dart';
import '../models/ApiResult.dart';
import '../providers/PendingPodcastFilter.dart';
import '../providers/PodcastFilter.dart';

abstract class IPodcastService {
  Future<ApiResult<PaginatedPodcastsResponse>> getPodcasts(PodcastFilter filter);
}

class PodcastService implements IPodcastService {
  String get _baseUrl => dotenv.env['BASE_URL'] ?? '';
  String get _podcastsUrl => '$_baseUrl/cms/podcasts';
  String get _pendingPodcastsUrl => '$_baseUrl/cms/podcasts/pending';

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ;
    return {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
  }

  @override
  Future<ApiResult<PaginatedPodcastsResponse>> getPodcasts(PodcastFilter filter) async {
    final queryParams = {
      'page': filter.page.toString(),
      'pageSize': filter.pageSize.toString(),
      if (filter.status != null) 'status': filter.status.toString(),
      if (filter.searchTerm.isNotEmpty) 'searchTerm': filter.searchTerm,
      if (filter.seriesName.isNotEmpty) 'seriesName': filter.seriesName,
      ...Map.fromIterables(
          filter.emotionCategories.map((e) => 'emotionCategories'),
          filter.emotionCategories.map((e) => e.toString())),
      ...Map.fromIterables(
          filter.topicCategories.map((t) => 'topicCategories'),
          filter.topicCategories.map((t) => t.toString())),
    };
    final uri = Uri.parse(_podcastsUrl).replace(queryParameters: queryParams);

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200 && response.body.isEmpty) {
        return ApiResult(
            isSuccess: true,
            data: PaginatedPodcastsResponse(podcasts: [], totalCount: 0, page: 1, pageSize: filter.pageSize));
      }
      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResult(isSuccess: true, data: PaginatedPodcastsResponse.fromJson(jsonResponse));
      } else {
        return ApiResult(
          isSuccess: jsonResponse['isSuccess'] ?? false,
          message: jsonResponse['message'],
        );
      }
    } catch (e) {
      return ApiResult(isSuccess: false, message: 'Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  Future<ApiResult<PaginatedPodcastsResponse>> getPendingPodcasts(PendingPodcastFilter filter) async {
    final queryParams = {
      'page': filter.page.toString(),
      'pageSize': filter.pageSize.toString(),
      if (filter.searchTerm.isNotEmpty) 'SearchTerm': filter.searchTerm,
      ...Map.fromIterables(
          filter.emotionCategories.map((e) => 'emotionCategories'),
          filter.emotionCategories.map((e) => e.toString())),
      ...Map.fromIterables(
          filter.topicCategories.map((t) => 'topicCategories'),
          filter.topicCategories.map((t) => t.toString())),
    };
    final uri = Uri.parse(_pendingPodcastsUrl).replace(queryParameters: queryParams);

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200 && response.body.isEmpty) {
        return ApiResult(isSuccess: true, data: PaginatedPodcastsResponse(podcasts: [], totalCount: 0, page: 1, pageSize: filter.pageSize));
      }

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResult(isSuccess: true, data: PaginatedPodcastsResponse.fromJson(jsonResponse));
      } else {
        return ApiResult(
          isSuccess: jsonResponse['isSuccess'] ?? false,
          message: jsonResponse['message'],
        );
      }
    } catch (e) {
      return ApiResult(isSuccess: false, message: 'Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  Future<ApiResult<PodcastDetail>> getPodcastDetail(String podcastId) async {
    final uri = Uri.parse('$_podcastsUrl/$podcastId');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final podcastDetail = PodcastDetail.fromJson(jsonResponse);
        return ApiResult(isSuccess: true, data: podcastDetail);
      } else {
        final jsonResponse = jsonDecode(response.body);
        return ApiResult(
          isSuccess: false,
          message: jsonResponse['message'] as String? ?? 'Lỗi ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResult(isSuccess: false, message: 'Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  Future<ApiResult<dynamic>> approvePodcast(String podcastId, {String? notes}) async {
    final uri = Uri.parse('$_podcastsUrl/$podcastId/approve');
    final body = jsonEncode({'approvalNotes': notes});
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(uri, headers: headers, body: body);
      final jsonResponse = jsonDecode(response.body);
      // SỬA LỖI: Tạo ApiResult trực tiếp
      return ApiResult(
        isSuccess: jsonResponse['isSuccess'] ?? (response.statusCode >= 200 && response.statusCode < 300),
        message: jsonResponse['message'],
      );
    } catch (e) {
      return ApiResult(isSuccess: false, message: e.toString());
    }
  }

  Future<ApiResult<dynamic>> rejectPodcast(String podcastId, {required String reason}) async {
    final uri = Uri.parse('$_podcastsUrl/$podcastId/reject');
    final body = jsonEncode({'rejectionReason': reason});
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

  // --- HÀM 3: DELETE PODCAST (ĐÃ SỬA LỖI) ---
  Future<ApiResult<dynamic>> deletePodcast(String podcastId) async {
    final uri = Uri.parse('$_podcastsUrl/$podcastId');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(uri, headers: headers);
      final jsonResponse = jsonDecode(response.body);
      // SỬA LỖI: Tạo ApiResult trực tiếp
      return ApiResult(
        isSuccess: jsonResponse['isSuccess'] ?? (response.statusCode >= 200 && response.statusCode < 300),
        message: jsonResponse['message'],
      );
    } catch (e) {
      return ApiResult(isSuccess: false, message: e.toString());
    }
  }


  Future<ApiResult<PodcastAnalytics>> getPodcastAnalytics(String podcastId) async {
    final uri = Uri.parse('$_podcastsUrl/$podcastId/analytics');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers);
      final jsonResponse = jsonDecode(response.body);
      // API này trả về dữ liệu trực tiếp, không có isSuccess/data
      if (response.statusCode == 200) {
        return ApiResult(isSuccess: true, data: PodcastAnalytics.fromJson(jsonResponse));
      } else {
        return ApiResult(isSuccess: false, message: jsonResponse['message'] ?? 'Lỗi ${response.statusCode}');
      }
    } catch (e) {
      return ApiResult(isSuccess: false, message: 'Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  // --- HÀM MỚI 2: LẤY THỐNG KÊ TỔNG QUAN ---
  Future<ApiResult<PodcastStatistics>> getPodcastStatistics() async {
    final uri = Uri.parse('$_podcastsUrl/statistics');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers);
      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResult(isSuccess: true, data: PodcastStatistics.fromJson(jsonResponse));
      } else {
        return ApiResult(isSuccess: false, message: jsonResponse['message'] ?? 'Lỗi ${response.statusCode}');
      }
    } catch (e) {
      return ApiResult(isSuccess: false, message: 'Đã xảy ra lỗi: ${e.toString()}');
    }
  }
}