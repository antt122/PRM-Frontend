class PodcastStatistics {
  final String message;
  final int totalPodcasts;
  final int publishedPodcasts;
  final int pendingPodcasts;
  final int rejectedPodcasts;
  final int totalViews;
  final int totalLikes;

  PodcastStatistics({
    required this.message,
    required this.totalPodcasts,
    required this.publishedPodcasts,
    required this.pendingPodcasts,
    required this.rejectedPodcasts,
    required this.totalViews,
    required this.totalLikes,
  });

  factory PodcastStatistics.fromJson(Map<String, dynamic> json) {
    return PodcastStatistics(
      message: json['message'] as String? ?? '',
      totalPodcasts: json['totalPodcasts'] as int? ?? 0,
      publishedPodcasts: json['publishedPodcasts'] as int? ?? 0,
      pendingPodcasts: json['pendingPodcasts'] as int? ?? 0,
      rejectedPodcasts: json['rejectedPodcasts'] as int? ?? 0,
      totalViews: json['totalViews'] as int? ?? 0,
      totalLikes: json['totalLikes'] as int? ?? 0,
    );
  }
}
