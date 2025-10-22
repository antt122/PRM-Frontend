import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'token_manager.dart';
import '../screens/login_screen.dart';
import 'audio_player_service.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();

  AuthService._();

  GlobalKey<NavigatorState>? _navigatorKey;

  /// Set navigator key for global navigation
  void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  /// Handle 401 Unauthorized - logout and redirect to login
  Future<void> handleUnauthorized() async {
    print('🔒 AuthService: Handling 401 Unauthorized');

    try {
      // Force stop audio player first
      await _forceStopAudioPlayer();

      // Clear tokens
      await TokenManager.instance.clearToken();

      // Clear all SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Navigate to login screen
      _navigateToLogin();
    } catch (e) {
      print('❌ AuthService: Error handling unauthorized: $e');
      // Even if there's an error, still try to navigate
      _navigateToLogin();
    }
  }

  /// Navigate to login screen with session expired message
  void _navigateToLogin() {
    if (_navigatorKey?.currentState != null) {
      print('🚀 AuthService: Navigating to login screen');

      // Clear all routes and navigate to login
      _navigatorKey!.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );

      // Show session expired message after navigation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSessionExpiredMessage();
      });
    } else {
      print('❌ AuthService: Navigator not available');
    }
  }

  /// Show session expired message
  void _showSessionExpiredMessage() {
    if (_navigatorKey?.currentContext != null) {
      ScaffoldMessenger.of(_navigatorKey!.currentContext!).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated {
    return TokenManager.instance.accessToken != null;
  }

  /// Logout user manually
  Future<void> logout() async {
    print('🔒 AuthService: Manual logout');
    await handleUnauthorized();
  }

  /// Force stop audio player
  Future<void> _forceStopAudioPlayer() async {
    try {
      print('🔒 AuthService: Force stopping audio player');
      // Get the audio player service instance and stop it
      // Note: This assumes AudioPlayerService is accessible globally
      // You might need to adjust this based on your architecture
      final audioService = AudioPlayerService();
      await audioService.stop();
      print('✅ AuthService: Audio player stopped successfully');
    } catch (e) {
      print('❌ AuthService: Error stopping audio player: $e');
      // Don't throw - continue with logout even if audio stop fails
    }
  }
}
