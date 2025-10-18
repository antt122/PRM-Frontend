// Model để chứa thông tin chi tiết của một người dùng trong CMS
class CmsUser {
  final String id;
  final String? userId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final int status; // 1: Active, 2: Inactive
  final List<String> roles;
  final DateTime createdAt;

  CmsUser({
    required this.id,
    this.userId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.status,
    required this.roles,
    required this.createdAt,
  });

  factory CmsUser.fromJson(Map<String, dynamic> json) {
    return CmsUser(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String?,
      fullName: json['fullName'] as String? ?? 'N/A',
      email: json['email'] as String? ?? 'N/A',
      phoneNumber: json['phoneNumber'] as String?,
      status: json['status'] as int? ?? 2,
      roles: List<String>.from(json['roles'] as List? ?? []),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

// Lớp generic để xử lý mọi kết quả trả về có phân trang từ API
class PaginatedResult<T> {
  final List<T> items;
  final int totalItems;
  final int totalPages;
  final int currentPage;

  PaginatedResult({
    required this.items,
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
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
    );
  }
}

