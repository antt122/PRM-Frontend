// Lớp generic để xử lý mọi kết quả trả về có phân trang từ API
class PaginatedResult<T> {
  final List<T> items;
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final bool hasNext;
  final bool hasPrevious;

  PaginatedResult({
    required this.items,
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PaginatedResult.fromJson(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) fromJsonT,
      ) {
    final itemsList = (json['items'] as List<dynamic>? ?? [])
        .map((item) => fromJsonT(item as Map<String, dynamic>))
        .toList();

    return PaginatedResult<T>(
      items: itemsList,
      totalItems: json['totalItems'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      currentPage: json['currentPage'] as int? ?? 1,
      hasNext: json['hasNext'] as bool? ?? false,
      hasPrevious: json['hasPrevious'] as bool? ?? false,
    );
  }
}
