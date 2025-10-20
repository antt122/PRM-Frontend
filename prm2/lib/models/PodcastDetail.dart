import 'package:intl/intl.dart';

class PodcastDetail {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String audioUrl;
  final String duration;
  final String? transcriptUrl;
  final String hostName;
  final String guestName;
  final int episodeNumber;
  final String seriesName;
  final List<String> tags;
  final List<int> emotionCategories;
  final List<int> topicCategories;
  final int contentStatus;
  final int viewCount;
  final int likeCount;
  final DateTime createdAt;
  final DateTime? publishedAt;
  final String createdBy;

  PodcastDetail({
    required this.id, required this.title, required this.description,
    required this.thumbnailUrl, required this.audioUrl, required this.duration,
    this.transcriptUrl, required this.hostName, required this.guestName,
    required this.episodeNumber, required this.seriesName, required this.tags,
    required this.emotionCategories, required this.topicCategories,
    required this.contentStatus, required this.viewCount, required this.likeCount,
    required this.createdAt, this.publishedAt, required this.createdBy,
  });

  String get formattedCreatedAt => DateFormat('MMM dd, yyyy • HH:mm').format(createdAt);
  String get formattedPublishedAt => publishedAt != null ? DateFormat('MMM dd, yyyy • HH:mm').format(publishedAt!) : 'Chưa xuất bản';

  factory PodcastDetail.fromJson(Map<String, dynamic> json) {
    return PodcastDetail(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Không có tiêu đề',
      description: json['description'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      audioUrl: json['audioUrl'] as String? ?? '',
      duration: json['duration'] as String? ?? '0:00',
      transcriptUrl: json['transcriptUrl'] as String?,
      hostName: json['hostName'] as String? ?? 'N/A',
      guestName: json['guestName'] as String? ?? 'N/A',
      episodeNumber: json['episodeNumber'] as int? ?? 0,
      seriesName: json['seriesName'] as String? ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      emotionCategories: List<int>.from(json['emotionCategories'] ?? []),
      topicCategories: List<int>.from(json['topicCategories'] ?? []),
      contentStatus: json['contentStatus'] as int? ?? 0,
      viewCount: json['viewCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      publishedAt: DateTime.tryParse(json['publishedAt'] as String? ?? ''),
      createdBy: json['createdBy'] as String? ?? '',
    );
  }
}
