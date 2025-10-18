import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;

/// Custom cache manager for audio files
/// Provides persistent storage with automatic cleanup
class AudioCacheManager {
  static const key = 'healinkAudioCache';
  
  static CacheManager instance = CacheManager(
    Config(
      key,
      // Cache up to 100 audio files
      maxNrOfCacheObjects: 100,
      
      // Keep files for 30 days
      stalePeriod: const Duration(days: 30),
      
      // Custom headers for S3/ngrok bypass
      fileService: HttpFileService(
        httpClient: CustomHttpClient(),
      ),
    ),
  );
}

/// Custom HTTP client with headers for S3 and ngrok
class CustomHttpClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    // Add custom headers to every request
    request.headers['ngrok-skip-browser-warning'] = 'true';
    request.headers['User-Agent'] = 'Flutter-Client';
    
    return _inner.send(request);
  }
  
  @override
  void close() {
    _inner.close();
  }
}
