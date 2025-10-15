import 'dart:convert';

// Helper function
PostDetail postDetailFromJson(String str) => PostDetail.fromJson(json.decode(str));

class PostDetail {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String audioUrl;
  final int duration;
  final String? transcriptUrl;
  final String? hostName;
  final String? guestName;
  final int episodeNumber;
  final String? seriesName;
  final List<String> tags;
  final List<int> emotionCategories;
  final List<int> topicCategories;
  final int contentStatus;
  final int viewCount;
  final int likeCount;
  final DateTime createdAt;
  final DateTime? publishedAt;
  final String createdBy;

  PostDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.audioUrl,
    required this.duration,
    this.transcriptUrl,
    this.hostName,
    this.guestName,
    required this.episodeNumber,
    this.seriesName,
    required this.tags,
    required this.emotionCategories,
    required this.topicCategories,
    required this.contentStatus,
    required this.viewCount,
    required this.likeCount,
    required this.createdAt,
    this.publishedAt,
    required this.createdBy,
  });

  factory PostDetail.fromJson(Map<String, dynamic> json) {
    // API trả về duration dạng String "0", cần parse an toàn
    final durationString = json['duration']?.toString() ?? '0';
    final parsedDuration = int.tryParse(durationString) ?? 0;

    return PostDetail(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Không có tiêu đề',
      description: json['description'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      audioUrl: json['audioUrl'] as String? ?? '',
      duration: parsedDuration,
      transcriptUrl: json['transcriptUrl'] as String?,
      hostName: json['hostName'] as String?,
      guestName: json['guestName'] as String?,
      episodeNumber: json['episodeNumber'] as int? ?? 0,
      seriesName: json['seriesName'] as String?,
      tags: List<String>.from(json['tags'] as List? ?? []),
      emotionCategories: List<int>.from(json['emotionCategories'] as List? ?? []),
      topicCategories: List<int>.from(json['topicCategories'] as List? ?? []),
      contentStatus: json['contentStatus'] as int? ?? 0,
      viewCount: json['viewCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      publishedAt: json['publishedAt'] != null ? DateTime.tryParse(json['publishedAt']) : null,
      createdBy: json['createdBy'] as String? ?? '',
    );
  }
}

