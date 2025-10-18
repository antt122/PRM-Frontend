class Story {
  final String id;
  final String title;
  final String description;
  final bool isAnonymous;
  final String authorDisplayName;
  final int contentStatus;
  final List<int> emotionCategories;
  final List<int> topicCategories;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final bool isModeratorPick;
  final DateTime publishedAt;

  Story({
    required this.id,
    required this.title,
    required this.description,
    required this.isAnonymous,
    required this.authorDisplayName,
    required this.contentStatus,
    required this.emotionCategories,
    required this.topicCategories,
    required this.viewCount,
    required this.likeCount,
    required this.commentCount,
    required this.isModeratorPick,
    required this.publishedAt,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'No Title',
      description: json['description'] as String? ?? '',
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      authorDisplayName: json['authorDisplayName'] as String? ?? 'Unknown Author',
      contentStatus: json['contentStatus'] as int? ?? 0,
      emotionCategories: List<int>.from(json['emotionCategories'] ?? []),
      topicCategories: List<int>.from(json['topicCategories'] ?? []),
      viewCount: json['viewCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      isModeratorPick: json['isModeratorPick'] as bool? ?? false,
      publishedAt: DateTime.tryParse(json['publishedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class PaginatedStoriesResponse {
  final List<Story> stories;
  final int totalCount;
  final int page;
  final int pageSize;

  PaginatedStoriesResponse({
    required this.stories,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  factory PaginatedStoriesResponse.fromJson(Map<String, dynamic> json) {
    var storyList = (json['stories'] as List? ?? [])
        .map((storyJson) => Story.fromJson(storyJson))
        .toList();
    return PaginatedStoriesResponse(
      stories: storyList,
      totalCount: json['totalCount'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 10,
    );
  }
}
