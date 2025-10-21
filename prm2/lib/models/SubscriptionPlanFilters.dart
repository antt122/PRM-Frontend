// lib/models/SubscriptionPlanFilters.dart
class SubscriptionPlanFilters {
  final int pageNumber;
  final int pageSize;
  final String? searchTerm;
  final String? sortBy;
  final String? sortDirection;
  final bool? isActive;
  // Thêm các trường filter khác nếu bạn muốn mở rộng sau này

  SubscriptionPlanFilters({
    this.pageNumber = 1,
    this.pageSize = 10,
    this.searchTerm,
    this.sortBy = 'createdAt',
    this.sortDirection = 'desc',
    this.isActive,
  });

  SubscriptionPlanFilters copyWith({
    int? pageNumber,
    int? pageSize,
    String? searchTerm,
    String? sortBy,
    String? sortDirection,
    bool? isActive,
  }) {
    return SubscriptionPlanFilters(
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      searchTerm: searchTerm ?? this.searchTerm,
      sortBy: sortBy ?? this.sortBy,
      sortDirection: sortDirection ?? this.sortDirection,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, String> toQueryParameters() {
    final Map<String, String> params = {
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
    };
    if (searchTerm != null && searchTerm!.isNotEmpty) params['searchTerm'] = searchTerm!;
    if (sortBy != null) params['sortBy'] = sortBy!;
    if (sortDirection != null) params['sortDirection'] = sortDirection!;
    if (isActive != null) params['isActive'] = isActive.toString();
    return params;
  }
}