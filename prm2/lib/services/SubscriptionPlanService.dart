
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/ApiResult.dart';
import '../models/CreatePlanRequest.dart';
import '../models/SubscriptionPlan.dart';
import '../models/UpdatePlanRequest.dart';

class SubscriptionPlanService {

  static String get _baseUrl => dotenv.env['BASE_URL'] ?? '';
  static String get _cmsUrl => '$_baseUrl/cms';
  static String get _getSubscriptionPlansCms => '$_cmsUrl/subscription-plans';


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
