/// Model để giữ trạng thái của các bộ lọc và chuyển đổi chúng
/// thành query parameters cho API.
class SubscriptionPlanFilters {
  final int pageNumber;
  final int pageSize;
  final String? searchTerm;
  final String? sortBy;
  final String? sortDirection;
  // *** Dùng String status theo API doc ***
  final String? status;
  final int? billingPeriodUnit;
  final double? minAmount;
  final double? maxAmount;
  final bool? hasTrialPeriod;
  final int? minTrialDays;
  final String? currency;

  SubscriptionPlanFilters({
    this.pageNumber = 1,
    this.pageSize = 10,
    this.searchTerm,
    this.sortBy = 'createdAt',
    this.sortDirection = 'desc',
    this.status,
    this.billingPeriodUnit,
    this.minAmount,
    this.maxAmount,
    this.hasTrialPeriod,
    this.minTrialDays,
    this.currency,
  });

  /// Hàm 'copyWith' để tạo một bản sao của filter
  /// nhưng với một số giá trị được cập nhật (rất hữu ích cho UI).
  SubscriptionPlanFilters copyWith({
    int? pageNumber,
    int? pageSize,
    String? searchTerm,
    String? sortBy,
    String? sortDirection,
    String? status, // Cho phép cập nhật status
  }) {
    return SubscriptionPlanFilters(
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      searchTerm: searchTerm ?? this.searchTerm,
      sortBy: sortBy ?? this.sortBy,
      sortDirection: sortDirection ?? this.sortDirection,
      status: status, // *** Cho phép gán cả giá trị null (để xóa filter)

      // Giữ nguyên các filter khác
      billingPeriodUnit: billingPeriodUnit ?? this.billingPeriodUnit,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      hasTrialPeriod: hasTrialPeriod ?? this.hasTrialPeriod,
      minTrialDays: minTrialDays ?? this.minTrialDays,
      currency: currency ?? this.currency,
    );
  }

  /// Chuyển đổi object Filter này thành Map<String, String>
  /// để sử dụng trong query parameters của HTTP request.
  Map<String, String> toQueryParameters() {
    final Map<String, String> params = {
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
    };

    if (searchTerm != null && searchTerm!.isNotEmpty) {
      params['searchTerm'] = searchTerm!;
    }
    if (sortBy != null) params['sortBy'] = sortBy!;
    if (sortDirection != null) params['sortDirection'] = sortDirection!;

    // Thêm 'status' (String) nếu nó tồn tại
    if (status != null && status!.isNotEmpty) {
      params['status'] = status!;
    }

    // Thêm các filter khác
    if (billingPeriodUnit != null) {
      params['billingPeriodUnit'] = billingPeriodUnit.toString();
    }
    if (minAmount != null) params['minAmount'] = minAmount.toString();
    if (maxAmount != null) params['maxAmount'] = maxAmount.toString();
    if (hasTrialPeriod != null) {
      params['hasTrialPeriod'] = hasTrialPeriod.toString();
    }
    if (minTrialDays != null) params['minTrialDays'] = minTrialDays.toString();
    if (currency != null) params['currency'] = currency!;

    return params;
  }
}