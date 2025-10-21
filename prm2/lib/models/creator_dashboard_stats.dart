class CreatorDashboardStats {
  final int totalPodcasts;
  final int publishedPodcasts;
  final int pendingPodcasts;
  final int rejectedPodcasts;
  final int totalViews;
  final int totalLikes;
  final List<TopPodcast> topPodcasts;

  CreatorDashboardStats({
    required this.totalPodcasts,
    required this.publishedPodcasts,
    required this.pendingPodcasts,
    required this.rejectedPodcasts,
    required this.totalViews,
    required this.totalLikes,
    required this.topPodcasts,
  });

  factory CreatorDashboardStats.fromJson(Map<String, dynamic> json) {
    return CreatorDashboardStats(
      totalPodcasts: json['totalPodcasts'] as int? ?? 0,
      publishedPodcasts: json['publishedPodcasts'] as int? ?? 0,
      pendingPodcasts: json['pendingPodcasts'] as int? ?? 0,
      rejectedPodcasts: json['rejectedPodcasts'] as int? ?? 0,
      totalViews: json['totalViews'] as int? ?? 0,
      totalLikes: json['totalLikes'] as int? ?? 0,
      topPodcasts:
          (json['topPodcasts'] as List<dynamic>?)
              ?.map((item) => TopPodcast.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPodcasts': totalPodcasts,
      'publishedPodcasts': publishedPodcasts,
      'pendingPodcasts': pendingPodcasts,
      'rejectedPodcasts': rejectedPodcasts,
      'totalViews': totalViews,
      'totalLikes': totalLikes,
      'topPodcasts': topPodcasts.map((podcast) => podcast.toJson()).toList(),
    };
  }
}

class TopPodcast {
  final String id;
  final String title;
  final int viewCount;
  final int likeCount;
  final String? publishedAt;

  TopPodcast({
    required this.id,
    required this.title,
    required this.viewCount,
    required this.likeCount,
    this.publishedAt,
  });

  factory TopPodcast.fromJson(Map<String, dynamic> json) {
    return TopPodcast(
      id: json['id'] as String,
      title: json['title'] as String,
      viewCount: json['viewCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      publishedAt: json['publishedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'publishedAt': publishedAt,
    };
  }
}
