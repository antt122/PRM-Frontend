class PodcastRecommendation {
  final String podcastId;
  final String title;
  final String recommendationReason;
  final String? topic;
  final String? category;
  final int? durationMinutes;
  final String? contentUrl;

  PodcastRecommendation({
    required this.podcastId,
    required this.title,
    required this.recommendationReason,
    this.topic,
    this.category,
    this.durationMinutes,
    this.contentUrl,
  });

  factory PodcastRecommendation.fromJson(Map<String, dynamic> json) {
    return PodcastRecommendation(
      podcastId: json['podcastId'] as String,
      title: json['title'] as String,
      recommendationReason: json['recommendationReason'] as String,
      topic: json['topic'] as String?,
      category: json['category'] as String?,
      durationMinutes: json['durationMinutes'] as int?,
      contentUrl: json['contentUrl'] as String?,
    );
  }
}

class PodcastRecommendationResponse {
  final List<PodcastRecommendation> recommendations;
  final int totalCount;

  PodcastRecommendationResponse({
    required this.recommendations,
    required this.totalCount,
  });

  factory PodcastRecommendationResponse.fromJson(Map<String, dynamic> json) {
    return PodcastRecommendationResponse(
      recommendations: (json['recommendations'] as List<dynamic>?)
          ?.map((item) => PodcastRecommendation.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      totalCount: json['totalCount'] as int? ?? 0,
    );
  }
}

class GetRecommendationsParams {
  final int? limit;
  final bool? includeListened;

  GetRecommendationsParams({
    this.limit,
    this.includeListened,
  });

  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    if (limit != null) {
      params['limit'] = limit.toString();
    }
    if (includeListened != null) {
      params['includeListened'] = includeListened.toString();
    }
    return params;
  }
}
