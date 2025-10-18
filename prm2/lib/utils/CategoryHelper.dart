class CategoryHelper {
  static const Map<int, String> emotionCategories = {
    1: 'Happy 😊',
    2: 'Sad 😢',
    3: 'Angry 😡',
    4: 'Excited 🤩',
    5: 'Lonely 💭',
    6: 'Hopeful 🌱',
  };

  static const Map<int, String> topicCategories = {
    1: 'Love ❤️',
    2: 'Career 💼',
    3: 'Health 🩺',
    4: 'Family 👨‍👩‍👧‍👦',
    5: 'Travel ✈️',
    6: 'Self-growth 🌿',
    7: 'Friendship 🤝',
  };

  static const Map<int, String> statusMap = {
    0: 'Pending',
    1: 'Active',
    2: 'Rejected',
    3: 'Deleted',
  };

  // Dành cho Podcasts
  static const Map<int, String> podcastEmotions = {
    1: 'Happy 😊', 2: 'Sad 😢', 3: 'Angry 😡', 4: 'Relaxed 🌿', 5: 'Inspired ✨',
    6: 'Curious 🤔', 7: 'Motivated 💪', 8: 'Lonely 💭', 9: 'Calm 😌', 10: 'Excited 🤩',
  };

  static const Map<int, String> podcastTopics = {
    1: 'Love ❤️', 2: 'Career 💼', 3: 'Health 🩺', 4: 'Family 👨‍👩‍👧‍👦', 5: 'Travel ✈️',
    6: 'Self-growth 🌿', 7: 'Friendship 🤝', 8: 'Education 📘', 9: 'Society 🌏', 10: 'Mindfulness 🧘',
  };

  // Dành cho Status
  static const Map<int, String> contentStatus = {
    0: 'Pending', 1: 'Active', 2: 'Rejected', 3: 'Deleted',
  };
}
