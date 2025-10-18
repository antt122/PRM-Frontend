class Podcast {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String audioUrl;
  final String duration;
  final String hostName;
  final String guestName;
  final String seriesName;
  final List<int> emotionCategories;
  final List<int> topicCategories;
  final int contentStatus;
  final int viewCount;
  final int likeCount;
  final DateTime publishedAt;

  Podcast({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.audioUrl,
    required this.duration,
    required this.hostName,
    required this.guestName,
    required this.seriesName,
    required this.emotionCategories,
    required this.topicCategories,
    required this.contentStatus,
    required this.viewCount,
    required this.likeCount,
    required this.publishedAt,
  });

  factory Podcast.fromJson(Map<String, dynamic> json) {
    return Podcast(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Không có tiêu đề',
      description: json['description'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      audioUrl: json['audioUrl'] as String? ?? '',
      duration: json['duration'] as String? ?? '0:00',
      hostName: json['hostName'] as String? ?? 'N/A',
      guestName: json['guestName'] as String? ?? 'N/A',
      seriesName: json['seriesName'] as String? ?? 'N/A',
      emotionCategories: List<int>.from(json['emotionCategories'] ?? []),
      topicCategories: List<int>.from(json['topicCategories'] ?? []),
      contentStatus: json['contentStatus'] as int? ?? 0,
      viewCount: json['viewCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      publishedAt: DateTime.tryParse(json['publishedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class PaginatedPodcastsResponse {
  final List<Podcast> podcasts;
  final int totalCount;
  final int page;
  final int pageSize;

  PaginatedPodcastsResponse({
    required this.podcasts,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  factory PaginatedPodcastsResponse.fromJson(Map<String, dynamic> json) {
    List<Podcast> podcastList = [];

    // Kiểm tra xem API trả về có đúng là một danh sách không
    if (json['podcasts'] is List) {
      var list = json['podcasts'] as List;
      podcastList = list.map((podcastJson) => Podcast.fromJson(podcastJson)).toList();
    }
    // Xử lý trường hợp API trả về một đối tượng đơn lẻ thay vì danh sách
    else if (json.containsKey('id') && json.containsKey('title')) {
      // Nếu JSON gốc có vẻ là một đối tượng Podcast, hãy tạo một danh sách chỉ chứa nó
      podcastList.add(Podcast.fromJson(json));
    }

    return PaginatedPodcastsResponse(
      podcasts: podcastList,
      // Nếu là đối tượng đơn lẻ, totalCount sẽ là 1
      totalCount: json['totalCount'] as int? ?? (podcastList.length > 0 ? 1 : 0),
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 10,
    );
  }
}
