// lib/models/SubscriptionFilters.dart

class SubscriptionFilters {
  final int? pageNumber;
  final int? pageSize;
  final String? userProfileId;
  final String? sortBy;
  final String? sortOrder;
  final String? subscriptionPlanId;
  final int? subscriptionStatus;
  final int? renewalBehavior;
  final bool? isActive;
  final bool? hasCancelScheduled;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? search;

  SubscriptionFilters({
    this.pageNumber,
    this.pageSize,
    this.userProfileId,
    this.sortBy,
    this.sortOrder,
    this.subscriptionPlanId,
    this.subscriptionStatus,
    this.renewalBehavior,
    this.isActive,
    this.hasCancelScheduled,
    this.startDate,
    this.endDate,
    this.search,
  });

  // --- PHƯƠNG THỨC COPYWITH ĐƯỢC THÊM VÀO ĐÂY ---
  SubscriptionFilters copyWith({
    int? pageNumber,
    int? pageSize,
    String? userProfileId,
    String? sortBy,
    String? sortOrder,
    String? subscriptionPlanId,
    int? subscriptionStatus,
    int? renewalBehavior,
    bool? isActive,
    bool? hasCancelScheduled,
    DateTime? startDate,
    DateTime? endDate,
    String? search,
  }) {
    return SubscriptionFilters(
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      userProfileId: userProfileId ?? this.userProfileId,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      subscriptionPlanId: subscriptionPlanId ?? this.subscriptionPlanId,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      renewalBehavior: renewalBehavior ?? this.renewalBehavior,
      isActive: isActive ?? this.isActive,
      hasCancelScheduled: hasCancelScheduled ?? this.hasCancelScheduled,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      search: search ?? this.search,
    );
  }

  Map<String, String> toQueryParameters() {
    final Map<String, String> params = {};
    if (pageNumber != null) params['pageNumber'] = pageNumber.toString();
    if (pageSize != null) params['pageSize'] = pageSize.toString();
    if (userProfileId != null) params['userProfileId'] = userProfileId!;
    if (sortBy != null) params['sortBy'] = sortBy!;
    if (sortOrder != null) params['sortOrder'] = sortOrder!;
    if (subscriptionPlanId != null && subscriptionPlanId!.isNotEmpty) params['subscriptionPlanId'] = subscriptionPlanId!;
    if (subscriptionStatus != null) params['subscriptionStatus'] = subscriptionStatus.toString();
    if (renewalBehavior != null) params['renewalBehavior'] = renewalBehavior.toString();
    if (isActive != null) params['isActive'] = isActive.toString();
    if (hasCancelScheduled != null) params['hasCancelScheduled'] = hasCancelScheduled.toString();
    if (startDate != null) params['startDate'] = startDate!.toIso8601String();
    if (endDate != null) params['endDate'] = endDate!.toIso8601String();
    if (search != null && search!.isNotEmpty) params['search'] = search!;
    return params;
  }
}