import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/StoryService.dart';
import '../models/Story.dart';
import '../models/ApiResult.dart';


// --- Filter State (Giữ nguyên) ---
@immutable
class StoryFilter {
  final int page;
  final int pageSize;
  final String searchTerm;
  final int? status;
  final bool? isModeratorPick;
  final List<int> emotionCategories;
  final List<int> topicCategories;

  const StoryFilter({
    this.page = 1,
    this.pageSize = 10,
    this.searchTerm = '',
    this.status,
    this.isModeratorPick,
    this.emotionCategories = const [],
    this.topicCategories = const [],
  });

  StoryFilter copyWith({
    int? page,
    int? pageSize,
    String? searchTerm,
    int? status,
    bool? isModeratorPick,
    List<int>? emotionCategories,
    List<int>? topicCategories,
  }) {
    return StoryFilter(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      searchTerm: searchTerm ?? this.searchTerm,
      status: status ?? this.status,
      isModeratorPick: isModeratorPick ?? this.isModeratorPick,
      emotionCategories: emotionCategories ?? this.emotionCategories,
      topicCategories: topicCategories ?? this.topicCategories,
    );
  }
}

class StoryFilterNotifier extends StateNotifier<StoryFilter> {
  StoryFilterNotifier() : super(const StoryFilter());

  void setFilter(StoryFilter filter) {
    state = filter.copyWith(page: 1); // Reset về trang 1 khi áp dụng filter mới
  }

  void setPage(int page) {
    state = state.copyWith(page: page);
  }
}

final storyFilterProvider = StateNotifierProvider<StoryFilterNotifier, StoryFilter>((ref) {
  return StoryFilterNotifier();
});

// --- CẬP NHẬT SERVICE PROVIDER ---
// Cung cấp một instance của StoryService mới
final storyServiceProvider = Provider<StoryService>((ref) {
  return StoryService();
});

// --- CẬP NHẬT DATA FETCHING PROVIDER ---
// Provider này giờ sẽ trả về ApiResult
final storiesProvider = FutureProvider.autoDispose<ApiResult<PaginatedStoriesResponse>>((ref) async {
  final filter = ref.watch(storyFilterProvider);
  final storyService = ref.watch(storyServiceProvider);
  // Gọi hàm mới và trả về kết quả
  return storyService.getStories(filter);
});

