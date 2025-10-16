class PaginationResult<T> {
  final int currentPage;
  final int pageSize;
  final int totalItems;
  final int totalPages;
  final bool hasPrevious;
  final bool hasNext;
  final List<T> items;
  final bool isSuccess;
  final String? message;
  final List<String>? errors;
  final String? errorCode;

  PaginationResult({
    required this.currentPage,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
    required this.hasPrevious,
    required this.hasNext,
    required this.items,
    required this.isSuccess,
    this.message,
    this.errors,
    this.errorCode,
  });

  factory PaginationResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginationResult<T>(
      currentPage: json['currentPage'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 10,
      totalItems: json['totalItems'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      hasPrevious: json['hasPrevious'] as bool? ?? false,
      hasNext: json['hasNext'] as bool? ?? false,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => fromJsonT(item as Map<String, dynamic>))
              .toList() ??
          [],
      isSuccess: json['isSuccess'] as bool? ?? false,
      message: json['message'] as String?,
      errors: (json['errors'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      errorCode: json['errorCode'] as String?,
    );
  }

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
}
