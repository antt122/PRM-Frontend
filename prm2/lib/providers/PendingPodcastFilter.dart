import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/Podcast.dart';
import '../models/ApiResult.dart';
import '../services/PodcastService.dart';


// Lớp chứa trạng thái của bộ lọc
@immutable
class PendingPodcastFilter {
  final int page;
  final int pageSize;
  final String searchTerm;
  final List<int> emotionCategories;
  final List<int> topicCategories;

  const PendingPodcastFilter({
    this.page = 1,
    this.pageSize = 10,
    this.searchTerm = '',
    this.emotionCategories = const [],
    this.topicCategories = const [],
  });

  PendingPodcastFilter copyWith({
    int? page, int? pageSize, String? searchTerm,
    List<int>? emotionCategories, List<int>? topicCategories,
  }) {
    return PendingPodcastFilter(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      searchTerm: searchTerm ?? this.searchTerm,
      emotionCategories: emotionCategories ?? this.emotionCategories,
      topicCategories: topicCategories ?? this.topicCategories,
    );
  }
}

// Notifier để quản lý và cập nhật trạng thái bộ lọc
class PendingPodcastFilterNotifier extends StateNotifier<PendingPodcastFilter> {
  PendingPodcastFilterNotifier() : super(const PendingPodcastFilter());

  void setFilter(PendingPodcastFilter filter) {
    state = filter.copyWith(page: 1); // Reset về trang 1 khi áp dụng filter mới
  }

  void setPage(int page) {
    state = state.copyWith(page: page);
  }
}

final pendingPodcastFilterProvider = StateNotifierProvider<PendingPodcastFilterNotifier, PendingPodcastFilter>((ref) {
  return PendingPodcastFilterNotifier();
});

// Provider cung cấp ApiService
final podcastServiceProvider = Provider<PodcastService>((ref) => PodcastService());

// Provider chính để lấy dữ liệu, sẽ tự động chạy lại khi filter thay đổi
final pendingPodcastsProvider = FutureProvider.autoDispose<ApiResult<PaginatedPodcastsResponse>>((ref) async {
  final filter = ref.watch(pendingPodcastFilterProvider);
  // Gọi service từ provider mới
  final podcastService = ref.watch(podcastServiceProvider);
  return podcastService.getPendingPodcasts(filter);
});
