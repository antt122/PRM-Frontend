import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/CmsUser.dart';
import '../models/PaginatedResult.dart';
import '../models/ApiResult.dart';
import '../services/api_service.dart';

// Lớp trạng thái cho bộ lọc
@immutable
class UserFilter {
  final int page;
  final String? search;
  final int? status;

  const UserFilter({
    this.page = 1,
    this.search,
    this.status,
  });

  UserFilter copyWith({
    int? page,
    String? search,
    int? status,
  }) {
    return UserFilter(
      page: page ?? this.page,
      search: search ?? this.search,
      status: status ?? this.status,
    );
  }
}

// Notifier để quản lý và cập nhật trạng thái bộ lọc
class UserFilterNotifier extends StateNotifier<UserFilter> {
  UserFilterNotifier() : super(const UserFilter());

  void setPage(int page) {
    state = state.copyWith(page: page);
  }

  void applyFilters({String? search, int? status}) {
    state = state.copyWith(
      page: 1, // Luôn reset về trang 1 khi áp dụng bộ lọc mới
      search: search,
      status: status,
    );
  }
}

// Provider cho bộ lọc
final userFilterProvider =
StateNotifierProvider<UserFilterNotifier, UserFilter>((ref) {
  return UserFilterNotifier();
});

// Provider cung cấp ApiService (để có thể tái sử dụng)
final userApiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Provider chính để lấy dữ liệu người dùng, sẽ tự động chạy lại khi filter thay đổi
final usersProvider =
FutureProvider.autoDispose<ApiResult<PaginatedResult<CmsUser>>>((ref) async {
  final filter = ref.watch(userFilterProvider);
  final apiService = ref.watch(userApiServiceProvider);
  return apiService.getUsers(
    page: filter.page,
    search: filter.search,
    status: filter.status,
  );
});
