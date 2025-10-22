/// Emotion Categories (matching backend enum exactly)
/// Backend values: Happiness=1, Sadness=2, Anxiety=3, Anger=4, Fear=5, Love=6, Hope=7, Gratitude=8, Mindfulness=9, SelfCompassion=10
enum EmotionCategory {
  none(0, 'Không xác định'),
  happiness(1, 'Hạnh phúc'),        // Backend: Happiness = 1
  sadness(2, 'Buồn'),               // Backend: Sadness = 2
  anxiety(3, 'Lo lắng'),            // Backend: Anxiety = 3
  anger(4, 'Tức giận'),             // Backend: Anger = 4
  fear(5, 'Sợ hãi'),                // Backend: Fear = 5
  love(6, 'Yêu thương'),            // Backend: Love = 6
  hope(7, 'Hy vọng'),               // Backend: Hope = 7
  gratitude(8, 'Biết ơn'),          // Backend: Gratitude = 8
  mindfulness(9, 'Chánh niệm'),     // Backend: Mindfulness = 9
  selfCompassion(10, 'Tự nhân hậu'); // Backend: SelfCompassion = 10

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

/// Topic Categories (matching backend enum exactly)
/// Backend values: MentalHealth=1, Relationships=2, SelfCare=3, Mindfulness=4, PersonalGrowth=5, WorkLifeBalance=6, Stress=7, Depression=8, Anxiety=9, Therapy=10
enum TopicCategory {
  none(0, 'Không xác định'),
  mentalHealth(1, 'Sức khỏe tâm thần'),      // Backend: MentalHealth = 1
  relationships(2, 'Mối quan hệ'),           // Backend: Relationships = 2
  selfCare(3, 'Chăm sóc bản thân'),          // Backend: SelfCare = 3
  mindfulness(4, 'Chánh niệm'),              // Backend: Mindfulness = 4
  personalGrowth(5, 'Phát triển bản thân'),  // Backend: PersonalGrowth = 5
  workLifeBalance(6, 'Cân bằng công việc'),  // Backend: WorkLifeBalance = 6
  stress(7, 'Căng thẳng'),                   // Backend: Stress = 7
  depression(8, 'Trầm cảm'),                 // Backend: Depression = 8
  anxiety(9, 'Lo âu'),                       // Backend: Anxiety = 9
  therapy(10, 'Trị liệu');                   // Backend: Therapy = 10

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
      PodcastCategoryFilter(id: 'happiness', name: 'Hạnh phúc', icon: '😊', value: 1),
      PodcastCategoryFilter(id: 'sadness', name: 'Buồn', icon: '😢', value: 2),
      PodcastCategoryFilter(id: 'anxiety', name: 'Lo lắng', icon: '😰', value: 3),
      PodcastCategoryFilter(id: 'anger', name: 'Tức giận', icon: '😠', value: 4),
      PodcastCategoryFilter(id: 'fear', name: 'Sợ hãi', icon: '😨', value: 5),
      PodcastCategoryFilter(id: 'love', name: 'Yêu thương', icon: '�', value: 6),
      PodcastCategoryFilter(id: 'hope', name: 'Hy vọng', icon: '🌟', value: 7),
      PodcastCategoryFilter(id: 'gratitude', name: 'Biết ơn', icon: '🙏', value: 8),
      PodcastCategoryFilter(id: 'mindfulness', name: 'Chánh niệm', icon: '🧘', value: 9),
      PodcastCategoryFilter(id: 'selfCompassion', name: 'Tự nhân hậu', icon: '�', value: 10),
    ];
  }

  static List<PodcastCategoryFilter> getTopicFilters() {
    return [
      PodcastCategoryFilter(id: 'all', name: 'Tất cả', icon: '📚', value: 0, isEmotion: false),
      PodcastCategoryFilter(id: 'mentalHealth', name: 'Sức khỏe', icon: '🧠', value: 1, isEmotion: false),
      PodcastCategoryFilter(id: 'relationships', name: 'Mối quan hệ', icon: '👥', value: 2, isEmotion: false),
      PodcastCategoryFilter(id: 'selfCare', name: 'Chăm sóc bản thân', icon: '💆', value: 3, isEmotion: false),
      PodcastCategoryFilter(id: 'mindfulness', name: 'Chánh niệm', icon: '🧘', value: 4, isEmotion: false),
      PodcastCategoryFilter(id: 'personalGrowth', name: 'Phát triển', icon: '🌱', value: 5, isEmotion: false),
      PodcastCategoryFilter(id: 'workLifeBalance', name: 'Cân bằng', icon: '⚖️', value: 6, isEmotion: false),
      PodcastCategoryFilter(id: 'stress', name: 'Căng thẳng', icon: '�', value: 7, isEmotion: false),
      PodcastCategoryFilter(id: 'depression', name: 'Trầm cảm', icon: '😔', value: 8, isEmotion: false),
      PodcastCategoryFilter(id: 'anxiety', name: 'Lo âu', icon: '😟', value: 9, isEmotion: false),
      PodcastCategoryFilter(id: 'therapy', name: 'Trị liệu', icon: '⚕️', value: 10, isEmotion: false),
    ];
  }
}
