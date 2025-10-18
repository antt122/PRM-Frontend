import 'dart:convert';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/Story.dart';
import '../providers/StoryFilter.dart';
import '../models/ApiResult.dart';


class StoryService {
  // Lấy URL từ biến môi trường, có giá trị dự phòng
  String get _baseUrl => dotenv.env['BASE_URL'] ?? '' ;
  String get _storiesUrl => '$_baseUrl/cms/community/stories';

  // Hàm helper để lấy header chứa token xác thực
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

  // Hàm lấy danh sách stories, trả về ApiResult
  Future<ApiResult<PaginatedStoriesResponse>> getStories(StoryFilter filter) async {
    final queryParams = {
      'Page': filter.page.toString(),
      'PageSize': filter.pageSize.toString(),
      if (filter.status != null) 'Status': filter.status.toString(),
      if (filter.isModeratorPick != null) 'IsModeratorPick': filter.isModeratorPick.toString(),
      if (filter.searchTerm.isNotEmpty) 'SearchTerm': filter.searchTerm,
      ...Map.fromIterables(
          filter.emotionCategories.map((e) => 'EmotionCategories'),
          filter.emotionCategories.map((e) => e.toString())),
      ...Map.fromIterables(
          filter.topicCategories.map((t) => 'TopicCategories'),
          filter.topicCategories.map((t) => t.toString())),
    };

    final uri = Uri.parse(_storiesUrl).replace(queryParameters: queryParams);

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 20));

      // --- SỬA LỖI Ở ĐÂY ---
      // Nếu server trả về 200 OK nhưng body trống, coi như thành công với danh sách rỗng.
      if (response.statusCode == 200 && response.body.isEmpty) {
        return ApiResult(
          isSuccess: true,
          data: PaginatedStoriesResponse(stories: [], totalCount: 0, page: filter.page, pageSize: filter.pageSize),
        );
      }
      // --- HẾT PHẦN SỬA ---

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final paginatedData = PaginatedStoriesResponse.fromJson(jsonResponse);
        return ApiResult(isSuccess: true, data: paginatedData);
      } else {
        return ApiResult(
          isSuccess: false,
          message: jsonResponse['message'] as String? ?? 'Lỗi không xác định từ server.',
          errors: (jsonResponse['errors'] as List<dynamic>?)?.cast<String>(),
        );
      }
    } catch (e) {
      return ApiResult(isSuccess: false, message: 'Đã xảy ra lỗi: ${e.toString()}');
    }
  }
}

