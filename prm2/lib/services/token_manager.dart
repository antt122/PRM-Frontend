import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/api_result.dart';
import 'auth_service.dart';

class TokenManager {
  static TokenManager? _instance;
  static TokenManager get instance => _instance ??= TokenManager._();

  TokenManager._();

  Timer? _refreshTimer;
  String? _currentAccessToken;
  DateTime? _tokenExpiry;
  bool _isRefreshing = false;

  /// Initialize token manager with current token
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentAccessToken = prefs.getString('accessToken');

    // Get token expiry from JWT payload
    if (_currentAccessToken != null) {
      _tokenExpiry = _getTokenExpiry(_currentAccessToken!);
      _scheduleRefresh();
    }
  }

  /// Get current access token
  String? get accessToken => _currentAccessToken;

  /// Check if token is expired or will expire soon (within 5 minutes)
  bool get isTokenExpiredOrExpiringSoon {
    if (_tokenExpiry == null) return true;

    final now = DateTime.now().toUtc();
    final fiveMinutesFromNow = now.add(const Duration(minutes: 5));

    return _tokenExpiry!.isBefore(fiveMinutesFromNow);
  }

  /// Update token after successful refresh
  Future<void> updateToken(String newToken, DateTime expiresAt) async {
    _currentAccessToken = newToken;
    _tokenExpiry = expiresAt;

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', newToken);

    // Schedule next refresh
    _scheduleRefresh();

    print('🔄 TokenManager: Token updated, expires at: $expiresAt');
  }

  /// Clear token (on logout)
  Future<void> clearToken() async {
    _currentAccessToken = null;
    _tokenExpiry = null;
    _refreshTimer?.cancel();
    _refreshTimer = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');

    print('🔄 TokenManager: Token cleared');
  }

  /// Schedule automatic refresh
  void _scheduleRefresh() {
    _refreshTimer?.cancel();

    if (_tokenExpiry == null) return;

    final now = DateTime.now().toUtc();
    final refreshTime = _tokenExpiry!.subtract(const Duration(minutes: 5));

    if (refreshTime.isBefore(now)) {
      // Token expires soon, refresh immediately
      _performSilentRefresh();
    } else {
      // Schedule refresh 5 minutes before expiry
      final delay = refreshTime.difference(now);
      _refreshTimer = Timer(delay, _performSilentRefresh);

      print('🔄 TokenManager: Scheduled refresh in ${delay.inMinutes} minutes');
    }
  }

  /// Perform silent refresh
  Future<void> _performSilentRefresh() async {
    if (_isRefreshing) return;

    _isRefreshing = true;

    try {
      print('🔄 TokenManager: Performing silent refresh...');

      final result = await _refreshToken();

      if (result.isSuccess && result.data != null) {
        await updateToken(
          result.data!['accessToken'],
          result.data!['expiresAt'],
        );
        print('✅ TokenManager: Silent refresh successful');
      } else {
        print('❌ TokenManager: Silent refresh failed: ${result.message}');
        // If refresh fails, clear token to force re-login
        await clearToken();
      }
    } catch (e) {
      print('❌ TokenManager: Silent refresh error: $e');
      await clearToken();
    } finally {
      _isRefreshing = false;
    }
  }

  /// Call refresh token API
  Future<ApiResult<Map<String, dynamic>>> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refreshToken');

      if (refreshToken == null) {
        return ApiResult(
          isSuccess: false,
          message: 'No refresh token available',
        );
      }

      // Get base URL from ApiService
      final baseUrl = dotenv.env['BASE_URL'] ?? '';
      final url = Uri.parse('$baseUrl/user/auth/refresh-token');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $refreshToken',
              'ngrok-skip-browser-warning': 'true',
              'User-Agent': 'Flutter-Client',
            },
          )
          .timeout(const Duration(seconds: 10));

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['isSuccess'] == true) {
        final data = jsonResponse['data'];
        return ApiResult(
          isSuccess: true,
          data: {
            'accessToken': data['accessToken'],
            'expiresAt': DateTime.parse(data['expiresAt']),
          },
        );
      } else if (response.statusCode == 401) {
        // Refresh token is also expired - trigger logout
        print(
          '🔒 TokenManager: Refresh token expired (401), triggering logout',
        );
        await AuthService.instance.handleUnauthorized();
        return ApiResult(isSuccess: false, message: 'Refresh token expired');
      } else {
        return ApiResult(
          isSuccess: false,
          message: jsonResponse['message'] ?? 'Refresh token failed',
        );
      }
    } catch (e) {
      return ApiResult(
        isSuccess: false,
        message: 'Refresh token error: ${e.toString()}',
      );
    }
  }

  /// Extract token expiry from JWT payload
  DateTime? _getTokenExpiry(String token) {
    try {
      // JWT format: header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Decode payload (base64url)
      final payload = parts[1];
      // Add padding if needed
      final paddedPayload = payload + '=' * (4 - payload.length % 4);
      final decodedPayload = utf8.decode(base64Url.decode(paddedPayload));

      final payloadJson = jsonDecode(decodedPayload);
      final exp = payloadJson['exp'] as int?;

      if (exp != null) {
        // Convert Unix timestamp to DateTime
        return DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
      }

      return null;
    } catch (e) {
      print('❌ TokenManager: Error parsing token expiry: $e');
      return null;
    }
  }

  /// Force refresh token (for manual refresh)
  Future<bool> forceRefresh() async {
    if (_isRefreshing) return false;

    await _performSilentRefresh();
    return _currentAccessToken != null;
  }

  /// Dispose resources
  void dispose() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }
}
