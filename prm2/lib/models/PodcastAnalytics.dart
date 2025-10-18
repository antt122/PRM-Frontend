import 'package:intl/intl.dart';

class PodcastAnalytics {
  final String podcastId;
  final String title;
  final String createdBy;
  final String status;
  final int viewCount;
  final int likeCount;
  final DateTime createdAt;
  final DateTime? publishedAt;
  final String message;

  PodcastAnalytics({
    required this.podcastId,
    required this.title,
    required this.createdBy,
    required this.status,
    required this.viewCount,
    required this.likeCount,
    required this.createdAt,
    this.publishedAt,
    required this.message,
  });

  String get formattedCreatedAt => DateFormat('dd/MM/yyyy').format(createdAt);
  String get formattedPublishedAt => publishedAt != null ? DateFormat('dd/MM/yyyy').format(publishedAt!) : 'Chưa xuất bản';

  factory PodcastAnalytics.fromJson(Map<String, dynamic> json) {
    return PodcastAnalytics(
      podcastId: json['podcastId'] as String? ?? '',
      title: json['title'] as String? ?? 'N/A',
      createdBy: json['createdBy'] as String? ?? '',
      status: json['status'] as String? ?? 'Unknown',
      viewCount: json['viewCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      publishedAt: DateTime.tryParse(json['publishedAt'] as String? ?? ''),
      message: json['message'] as String? ?? '',
    );
  }
}
