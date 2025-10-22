import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Custom NetworkImage that adds ngrok-skip-browser-warning header
class CustomNetworkImage extends ImageProvider<CustomNetworkImage> {
  const CustomNetworkImage(this.url, {this.scale = 1.0, this.headers});

  final String url;
  final double scale;
  final Map<String, String>? headers;

  @override
  Future<CustomNetworkImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<CustomNetworkImage>(this);
  }

  @override
  ImageStreamCompleter loadImage(CustomNetworkImage key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
      debugLabel: key.url,
      informationCollector: () => <DiagnosticsNode>[
        DiagnosticsProperty<ImageProvider>('Image provider', this),
        DiagnosticsProperty<CustomNetworkImage>('Image key', key),
      ],
    );
  }

  Future<ui.Codec> _loadAsync(CustomNetworkImage key, ImageDecoderCallback decode) async {
    try {
      final Uri resolved = Uri.base.resolve(key.url);
      
      // Create headers with ngrok bypass
      final requestHeaders = <String, String>{
        'ngrok-skip-browser-warning': 'true',
        'User-Agent': 'Flutter-Client',
        ...?key.headers,
      };

      final http.Response response = await http.get(
        resolved,
        headers: requestHeaders,
      );

      if (response.statusCode != 200) {
        throw NetworkImageLoadException(
          statusCode: response.statusCode,
          uri: resolved,
        );
      }

      final Uint8List bytes = response.bodyBytes;
      if (bytes.lengthInBytes == 0) {
        throw Exception('NetworkImage is an empty file: $resolved');
      }

      return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
    } catch (e) {
      // Re-throw with proper error handling
      rethrow;
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is CustomNetworkImage && other.url == url && other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(url, scale);

  @override
  String toString() => '${objectRuntimeType(this, 'CustomNetworkImage')}("$url", scale: $scale)';
}
