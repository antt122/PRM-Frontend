import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/Podcast.dart';
import '../models/PodcastAnalytics.dart';
import '../models/PodcastDetail.dart';
import '../models/PodcastStatistics.dart';
import '../models/ApiResult.dart';
import '../services/PodcastService.dart';
import 'package:flutter/material.dart';


// --- Lớp trạng thái cho bộ lọc của tab "Tất cả" ---
@immutable
class PodcastFilter {
  final int page;
  final int pageSize;
  final String searchTerm;
  final String seriesName;
  final int? status;
  final List<int> emotionCategories;
  final List<int> topicCategories;

  const PodcastFilter({
    this.page = 1,
    this.pageSize = 10,
    this.searchTerm = '',
    this.seriesName = '',
    this.status,
    this.emotionCategories = const [],
    this.topicCategories = const [],
  });

  PodcastFilter copyWith({
    int? page,
    int? pageSize,
    String? searchTerm,
    String? seriesName,
    int? status,
    List<int>? emotionCategories,
    List<int>? topicCategories,
  }) {
    return PodcastFilter(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      searchTerm: searchTerm ?? this.searchTerm,
      seriesName: seriesName ?? this.seriesName,
      status: status ?? this.status,
      emotionCategories: emotionCategories ?? this.emotionCategories,
      topicCategories: topicCategories ?? this.topicCategories,
    );
  }
}

// --- Notifier để quản lý và cập nhật bộ lọc ---
class PodcastFilterNotifier extends StateNotifier<PodcastFilter> {
  PodcastFilterNotifier() : super(const PodcastFilter());

  void setFilter(PodcastFilter filter) {
    state = filter.copyWith(page: 1);
  }

  void setPage(int page) {
    state = state.copyWith(page: page);
  }
}

// --- CÁC PROVIDER CHO CHỨC NĂNG QUẢN LÝ PODCAST ---

// 1. Provider cho bộ lọc của tab "Tất cả"
final podcastFilterProvider =
StateNotifierProvider<PodcastFilterNotifier, PodcastFilter>((ref) {
  return PodcastFilterNotifier();
});

// 2. Provider cung cấp một instance của PodcastService (NGUỒN CHÂN LÝ DUY NHẤT)
final podcastServiceProvider = Provider<PodcastService>((ref) {
  return PodcastService();
});

// 3. Provider chính để lấy danh sách "Tất cả" podcast.
final podcastsProvider =
FutureProvider.autoDispose<ApiResult<PaginatedPodcastsResponse>>((ref) async {
  final filter = ref.watch(podcastFilterProvider);
  final podcastService = ref.watch(podcastServiceProvider);
  return podcastService.getPodcasts(filter);
});

// 4. Provider cho màn hình chi tiết podcast.
final podcastDetailProvider =
FutureProvider.autoDispose.family<ApiResult<PodcastDetail>, String>(
        (ref, podcastId) async {
      final podcastService = ref.watch(podcastServiceProvider);
      return podcastService.getPodcastDetail(podcastId);
    });

// 5. Provider cho thống kê chi tiết
final podcastAnalyticsProvider = FutureProvider.autoDispose.family<ApiResult<PodcastAnalytics>, String>((ref, podcastId) {
  final podcastService = ref.watch(podcastServiceProvider);
  return podcastService.getPodcastAnalytics(podcastId);
});

// 6. Provider cho thống kê tổng quan
final podcastStatisticsProvider = FutureProvider.autoDispose<ApiResult<PodcastStatistics>>((ref) {
  final podcastService = ref.watch(podcastServiceProvider);
  return podcastService.getPodcastStatistics();
});

