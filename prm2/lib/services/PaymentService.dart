import 'dart:convert';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/CmsUser.dart';
import '../models/PaginatedResult.dart';
import '../models/PaymentMethod.dart';
import '../models/PaymentMethodCreateModel.dart';
import '../models/PaymentMethodDetail.dart';
import '../models/ApiResult.dart';
import '../providers/PaymentMethodFilter.dart';


class PaymentService {
  String get _baseUrl => dotenv.env['BASE_URL'] ?? '';
  String get _paymentMethodsUrl => '$_baseUrl/cms/payment-methods';

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? 'YOUR_SAMPLE_TOKEN_HERE';
    return {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
  }

  Future<ApiResult<PaginatedResult<PaymentMethod>>> getPaymentMethods(PaymentMethodFilter filter) async {
    final queryParams = {
      'Page': filter.page.toString(),
      'PageSize': filter.pageSize.toString(),
      'SortBy': filter.sortBy,
      'IsAscending': filter.isAscending.toString(),
      if (filter.search != null && filter.search!.isNotEmpty) 'Search': filter.search!,
      if (filter.status != null) 'Status': filter.status!,
      if (filter.providerName != null) 'ProviderName': filter.providerName!,
      if (filter.type != null) 'Type': filter.type.toString(),
    };

    final uri = Uri.parse(_paymentMethodsUrl).replace(queryParameters: queryParams);

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 20));
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['isSuccess'] == true) {
        final paginatedData = PaginatedResult.fromJson(jsonResponse, (json) => PaymentMethod.fromJson(json));
        return ApiResult(isSuccess: true, data: paginatedData);
      } else {
        return ApiResult(
          isSuccess: jsonResponse['isSuccess'] ?? false,
          message: jsonResponse['message'],
          errors: (jsonResponse['errors'] as List<dynamic>?)?.cast<String>(),
        );
      }
    } catch (e) {
      return ApiResult(isSuccess: false, message: 'Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  Future<ApiResult<dynamic>> createPaymentMethod(PaymentMethodCreateModel model) async {
    final uri = Uri.parse(_paymentMethodsUrl);
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(model.toJson()),
      );
      final jsonResponse = jsonDecode(response.body);

      return ApiResult(
        isSuccess: jsonResponse['isSuccess'] ?? (response.statusCode >= 200 && response.statusCode < 300),
        message: jsonResponse['message'],
        errors: (jsonResponse['errors'] as List<dynamic>?)?.cast<String>(),
        errorCode: jsonResponse['errorCode'],
      );
    } catch (e) {
      return ApiResult(isSuccess: false, message: 'Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  Future<ApiResult<PaymentMethodDetail>> getPaymentMethodDetail(String id) async {
    final uri = Uri.parse('$_paymentMethodsUrl/$id');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(uri, headers: headers);
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['isSuccess'] == true) {
        return ApiResult.fromJson(jsonResponse, (data) => PaymentMethodDetail.fromJson(data as Map<String, dynamic>));
      } else {
        return ApiResult(
          isSuccess: jsonResponse['isSuccess'] ?? false,
          message: jsonResponse['message'],
          errors: (jsonResponse['errors'] as List<dynamic>?)?.cast<String>(),
        );
      }
    } catch (e) {
      return ApiResult(isSuccess: false, message: 'Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  Future<ApiResult<dynamic>> updatePaymentMethod({
    required String id,
    required PaymentMethodCreateModel model, // Tái sử dụng model tạo mới
  }) async {
    final uri = Uri.parse('$_paymentMethodsUrl/$id');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        uri,
        headers: headers,
        body: jsonEncode(model.toJson()),
      );
      final jsonResponse = jsonDecode(response.body);
      return ApiResult(
        isSuccess: jsonResponse['isSuccess'] ?? (response.statusCode >= 200 && response.statusCode < 300),
        message: jsonResponse['message'],
        errors: (jsonResponse['errors'] as List<dynamic>?)?.cast<String>(),
      );
    } catch (e) {
      return ApiResult(isSuccess: false, message: 'Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  Future<ApiResult<dynamic>> deletePaymentMethod(String id) async {
    final uri = Uri.parse('$_paymentMethodsUrl/$id');
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(uri, headers: headers);
      final jsonResponse = jsonDecode(response.body);

      return ApiResult(
        isSuccess: jsonResponse['isSuccess'] ?? (response.statusCode >= 200 && response.statusCode < 300),
        message: jsonResponse['message'],
        errors: (jsonResponse['errors'] as List<dynamic>?)?.cast<String>(),
      );
    } catch (e) {
      return ApiResult(isSuccess: false, message: 'Đã xảy ra lỗi: ${e.toString()}');
    }
  }
}
