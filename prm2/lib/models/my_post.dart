import 'dart:convert';

// Helper function to easily decode a JSON string into a MyPost object
MyPost myPostFromJson(String str) => MyPost.fromJson(json.decode(str));

class MyPost {
  final String id;
  final String title;
  final String audioUrl;
  final String thumbnailUrl;
  final int contentStatus;
  final DateTime createdAt;

  MyPost({
    required this.id,
    required this.title,
    required this.audioUrl,
    required this.thumbnailUrl,
    required this.contentStatus,
    required this.createdAt,
  });

  factory MyPost.fromJson(Map<String, dynamic> json) {
    return MyPost(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Không có tiêu đề',
      audioUrl: json['audioUrl'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      contentStatus: json['contentStatus'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
