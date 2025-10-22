import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Widget to display S3 images with proper CORS headers
/// This widget wraps CachedNetworkImage and adds necessary headers for S3 access
class S3CachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, Object)? errorWidget;

  const S3CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // For S3 URLs, we need to use Image.network with headers instead of CachedNetworkImage
    // because CachedNetworkImage doesn't properly pass headers in all cases
    if (imageUrl.contains('.s3.') || imageUrl.contains('.s3-') || imageUrl.contains('://s3.')) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        headers: const {
          'ngrok-skip-browser-warning': 'true',
          // Removed User-Agent - browser doesn't allow setting it anyway
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder?.call(context, imageUrl) ??
              Container(
                width: width,
                height: height,
                color: Colors.grey.shade800,
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                    color: Colors.white54,
                    strokeWidth: 2,
                  ),
                ),
              );
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ Error loading S3 image: $error');
          return errorWidget?.call(context, imageUrl, error) ??
              Container(
                width: width,
                height: height,
                color: Colors.grey.shade800,
                child: const Icon(Icons.error, color: Colors.red),
              );
        },
      );
    }

    // For non-S3 URLs, use CachedNetworkImage as usual
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      httpHeaders: const {
        'ngrok-skip-browser-warning': 'true',
        'User-Agent': 'Flutter-Client',
      },
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }
}
