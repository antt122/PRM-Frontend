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



