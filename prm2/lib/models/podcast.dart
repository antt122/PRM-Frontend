import 'package:intl/intl.dart';

/// Model for Podcast item in list view
class Podcast {
  final String id;
  final String title;
  final String description;
  final String? thumbnailUrl;
  final String? audioFileUrl;
  final int duration; // in seconds
  final String? hostName;
  final String? guestName;
  final int? episodeNumber;
  final String? seriesName;
  final List<String> tags;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final String contentStatus;
  final List<int> emotionCategories;  // Changed from int to List<int>
  final List<int> topicCategories;    // Changed from int to List<int>
  final DateTime createdAt;
  final DateTime? publishedAt;
  final String createdBy;

  Podcast({
    required this.id,
    required this.title,
    required this.description,
    this.thumbnailUrl,
    this.audioFileUrl,
    required this.duration,
    this.hostName,
    this.guestName,
    this.episodeNumber,
    this.seriesName,
    this.tags = const [],
    this.viewCount = 0,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    required this.contentStatus,
    this.emotionCategories = const [],  // Default to empty list
    this.topicCategories = const [],    // Default to empty list
    required this.createdAt,
    this.publishedAt,
    required this.createdBy,
  });

  factory Podcast.fromJson(Map<String, dynamic> json) {
    // Helper to transform S3 URLs - DISABLED because CachedNetworkImage handles S3 with headers
    // and audio_player_service also handles S3 URLs directly with headers
    String? transformS3Url(String? url) {
      // Just return URL as-is, let CachedNetworkImage and AudioPlayerService handle headers
      return url;
    }

    // Parse duration: could be int (seconds) or string ("HH:MM:SS")
    int durationSeconds = 0;
    final duration = json['duration'];
    if (duration is int) {
      durationSeconds = duration;
    } else if (duration is String) {
      // Parse "HH:MM:SS" format
      try {
        final parts = duration.split(':');
        if (parts.length == 3) {
          final hours = int.parse(parts[0]);
          final minutes = int.parse(parts[1]);
          final seconds = int.parse(parts[2]);
          durationSeconds = (hours * 3600) + (minutes * 60) + seconds;
        }
      } catch (e) {
        print('ERROR parsing duration: $duration, error: $e');
        durationSeconds = 0;
      }
    }

    return Podcast(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      thumbnailUrl: transformS3Url(json['thumbnailUrl'] as String?),
      audioFileUrl: transformS3Url(json['audioFileUrl'] as String? ?? json['audioUrl'] as String?),  // Try both keys
      duration: durationSeconds,
      hostName: json['hostName'] as String?,
      guestName: json['guestName'] as String?,
      episodeNumber: json['episodeNumber'] as int?,
      seriesName: json['seriesName'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((t) => t.toString()).toList() ?? [],
      viewCount: json['viewCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      shareCount: json['shareCount'] as int? ?? 0,
      contentStatus: _parseContentStatus(json['contentStatus']),
      emotionCategories: (json['emotionCategories'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [],
      topicCategories: (json['topicCategories'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      publishedAt: json['publishedAt'] != null 
          ? DateTime.parse(json['publishedAt'] as String) 
          : null,
      createdBy: json['createdBy'] as String,
    );
  }

  /// Helper to parse contentStatus from int or String
  /// Backend enum: Draft=1, PendingReview=2, PendingModeration=3, Approved=4, Published=5, Rejected=6, Archived=7
  static String _parseContentStatus(dynamic status) {
    if (status is int) {
      // Map int values to status strings (matching backend ContentStatus enum)
      switch (status) {
        case 1:
          return 'Draft';
        case 2:
          return 'PendingReview';
        case 3:
          return 'PendingModeration';
        case 4:
          return 'Approved';
        case 5:
          return 'Published';
        case 6:
          return 'Rejected';
        case 7:
          return 'Archived';
        default:
          return 'Draft';
      }
    }
    return (status as String?) ?? 'Draft';
  }

  String get formattedDuration {
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    final seconds = duration % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  String get formattedDate {
    final date = publishedAt ?? createdAt;
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      if (difference.inHours < 1) {
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  String get formattedViews {
    if (viewCount >= 1000000) {
      return '${(viewCount / 1000000).toStringAsFixed(1)}M';
    } else if (viewCount >= 1000) {
      return '${(viewCount / 1000).toStringAsFixed(1)}K';
    }
    return viewCount.toString();
  }

  /// Get emotion category names from IDs
  List<String> get emotionCategoryNames {
    final emotionMap = {
      1: 'Hạnh phúc',
      2: 'Buồn',
      3: 'Lo lắng',
      4: 'Tức giận',
      5: 'Sợ hãi',
      6: 'Yêu thương',
      7: 'Hy vọng',
      8: 'Biết ơn',
      9: 'Chánh niệm',
      10: 'Tự nhân hậu',
    };
    return emotionCategories.map((id) => emotionMap[id] ?? 'Unknown').toList();
  }

  /// Get topic category names from IDs
  List<String> get topicCategoryNames {
    final topicMap = {
      1: 'Sức khỏe tinh thần',
      2: 'Mối quan hệ',
      3: 'Tự chăm sóc',
      4: 'Chánh niệm',
      5: 'Phát triển cá nhân',
      6: 'Cân bằng công việc-cuộc sống',
      7: 'Căng thẳng',
      8: 'Trầm cảm',
      9: 'Lo âu',
      10: 'Trị liệu',
    };
    return topicCategories.map((id) => topicMap[id] ?? 'Unknown').toList();
  }

  /// Get content status display name in Vietnamese
  String get contentStatusDisplay {
    switch (contentStatus) {
      case 'Draft':
        return 'Bản nháp';
      case 'PendingReview':
        return 'Chờ phê duyệt';
      case 'PendingModeration':
        return 'Chờ kiểm duyệt';
      case 'Approved':
        return 'Được phê duyệt';
      case 'Published':
        return 'Đã xuất bản';
      case 'Rejected':
        return 'Bị từ chối';
      case 'Archived':
        return 'Đã lưu trữ';
      default:
        return contentStatus;
    }
  }
}
