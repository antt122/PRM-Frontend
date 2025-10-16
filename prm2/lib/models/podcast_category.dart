/// Emotion Categories (matching backend enum)
enum EmotionCategory {
  none(0, 'Không xác định'),
  happy(1, 'Hạnh phúc'),
  sad(2, 'Buồn'),
  anxious(4, 'Lo lắng'),
  angry(8, 'Tức giận'),
  calm(16, 'Bình tĩnh'),
  excited(32, 'Phấn khích'),
  stressed(64, 'Căng thẳng'),
  grateful(128, 'Biết ơn'),
  confused(256, 'Bối rối'),
  hopeful(512, 'Hy vọng');

  final int value;
  final String displayName;

  const EmotionCategory(this.value, this.displayName);

  static EmotionCategory fromValue(int value) {
    return EmotionCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EmotionCategory.none,
    );
  }
}

/// Topic Categories (matching backend enum)
enum TopicCategory {
  none(0, 'Không xác định'),
  mentalHealth(1, 'Sức khỏe tâm thần'),
  mindfulness(2, 'Chánh niệm'),
  relationships(4, 'Mối quan hệ'),
  career(8, 'Sự nghiệp'),
  selfImprovement(16, 'Phát triển bản thân'),
  meditation(32, 'Thiền định'),
  sleep(64, 'Giấc ngủ'),
  stress(128, 'Căng thẳng'),
  anxiety(256, 'Lo âu'),
  depression(512, 'Trầm cảm'),
  spirituality(1024, 'Tâm linh'),
  wellness(2048, 'Sức khỏe tổng thể');

  final int value;
  final String displayName;

  const TopicCategory(this.value, this.displayName);

  static TopicCategory fromValue(int value) {
    return TopicCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TopicCategory.none,
    );
  }
}

/// Category for filtering
class PodcastCategoryFilter {
  final String id;
  final String name;
  final String icon;
  final int value;
  final bool isEmotion;

  PodcastCategoryFilter({
    required this.id,
    required this.name,
    required this.icon,
    required this.value,
    this.isEmotion = true,
  });

  static List<PodcastCategoryFilter> getEmotionFilters() {
    return [
      PodcastCategoryFilter(id: 'all', name: 'Tất cả', icon: '🎧', value: 0),
      PodcastCategoryFilter(id: 'happy', name: 'Hạnh phúc', icon: '😊', value: 1),
      PodcastCategoryFilter(id: 'sad', name: 'Buồn', icon: '😢', value: 2),
      PodcastCategoryFilter(id: 'anxious', name: 'Lo lắng', icon: '😰', value: 4),
      PodcastCategoryFilter(id: 'calm', name: 'Bình tĩnh', icon: '😌', value: 16),
      PodcastCategoryFilter(id: 'stressed', name: 'Căng thẳng', icon: '😫', value: 64),
    ];
  }

  static List<PodcastCategoryFilter> getTopicFilters() {
    return [
      PodcastCategoryFilter(id: 'all', name: 'Tất cả', icon: '📚', value: 0, isEmotion: false),
      PodcastCategoryFilter(id: 'mentalHealth', name: 'Sức khỏe', icon: '🧠', value: 1, isEmotion: false),
      PodcastCategoryFilter(id: 'mindfulness', name: 'Chánh niệm', icon: '🧘', value: 2, isEmotion: false),
      PodcastCategoryFilter(id: 'meditation', name: 'Thiền định', icon: '🕉️', value: 32, isEmotion: false),
      PodcastCategoryFilter(id: 'sleep', name: 'Giấc ngủ', icon: '😴', value: 64, isEmotion: false),
      PodcastCategoryFilter(id: 'wellness', name: 'Wellness', icon: '💚', value: 2048, isEmotion: false),
    ];
  }
}
