import 'dart:convert';

// Model để lưu trữ thông tin của một bài đăng sau khi upload thành công
class MyPost {
  final String id;
  final String title;
  final String description;
  final String audioUrl;      // Thêm trường này
  final String thumbnailUrl;
  final int contentStatus;    // Thêm trường này
  final DateTime createdAt;

  MyPost({
    required this.id,
    required this.title,
    required this.description,
    required this.audioUrl,
    required this.thumbnailUrl,
    required this.contentStatus,
    required this.createdAt,
  });

  // Cập nhật factory để khớp với JSON response
  factory MyPost.fromJson(Map<String, dynamic> json) {
    return MyPost(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Không có tiêu đề',
      description:['description'] as String? ?? 'Phai dài hơn ... kí tự' ,
      audioUrl: json['audioUrl'] as String? ?? '', // Lấy audioUrl
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '', // Key đã chính xác
      contentStatus: json['contentStatus'] as int? ?? 0, // Lấy contentStatus
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

// Helper function để tiện sử dụng
MyPost podcastResponseFromJson(String str) => MyPost.fromJson(json.decode(str));