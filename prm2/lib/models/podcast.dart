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
  final int emotionCategories;
  final int topicCategories;
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
    required this.emotionCategories,
    required this.topicCategories,
    required this.createdAt,
    this.publishedAt,
    required this.createdBy,
  });

  factory Podcast.fromJson(Map<String, dynamic> json) {
    return Podcast(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      audioFileUrl: json['audioFileUrl'] as String?,
      duration: json['duration'] as int? ?? 0,
      hostName: json['hostName'] as String?,
      guestName: json['guestName'] as String?,
      episodeNumber: json['episodeNumber'] as int?,
      seriesName: json['seriesName'] as String?,
      tags: (json['tags'] as String?)?.split(',').where((t) => t.isNotEmpty).toList() ?? [],
      viewCount: json['viewCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      shareCount: json['shareCount'] as int? ?? 0,
      contentStatus: json['contentStatus'] as String? ?? 'Draft',
      emotionCategories: json['emotionCategories'] as int? ?? 0,
      topicCategories: json['topicCategories'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      publishedAt: json['publishedAt'] != null 
          ? DateTime.parse(json['publishedAt'] as String) 
          : null,
      createdBy: json['createdBy'] as String,
    );
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
}
