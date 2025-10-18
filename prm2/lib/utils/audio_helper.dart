import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

/// Helper class for playing audio with custom headers (e.g., ngrok bypass)
class AudioHelper {
  /// Plays audio from URL with custom headers
  /// Downloads the audio first, then plays from bytes
  static Future<void> playAudioWithHeaders(
    AudioPlayer player,
    String url, {
    Map<String, String>? headers,
  }) async {
    // Default headers include ngrok bypass
    final effectiveHeaders = {
      'ngrok-skip-browser-warning': 'true',
      'User-Agent': 'Flutter-Client',
      ...?headers,
    };

    try {
      print('🎵 Downloading audio from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: effectiveHeaders,
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to download audio: ${response.statusCode} ${response.reasonPhrase}',
        );
      }

      final bytes = response.bodyBytes;
      print('✅ Audio downloaded: ${bytes.length} bytes');

      // Play from bytes using just_audio
      await player.setAudioSource(AudioSource.uri(Uri.dataFromBytes(bytes)));
      await player.play();
      print('✅ Audio playing from bytes');
    } catch (e, stackTrace) {
      print('❌ Error playing audio: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Sets audio source from URL with custom headers (for pre-loading)
  /// Downloads the audio first, then sets source from bytes
  static Future<void> setAudioSourceWithHeaders(
    AudioPlayer player,
    String url, {
    Map<String, String>? headers,
  }) async {
    // Default headers include ngrok bypass
    final effectiveHeaders = {
      'ngrok-skip-browser-warning': 'true',
      'User-Agent': 'Flutter-Client',
      ...?headers,
    };

    try {
      print('🎵 Pre-loading audio from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: effectiveHeaders,
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to download audio: ${response.statusCode} ${response.reasonPhrase}',
        );
      }

      final bytes = response.bodyBytes;
      print('✅ Audio downloaded: ${bytes.length} bytes');

      // Set source from bytes using just_audio
      await player.setAudioSource(AudioSource.uri(Uri.dataFromBytes(bytes)));
      print('✅ Audio source set from bytes');
    } catch (e, stackTrace) {
      print('❌ Error setting audio source: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
