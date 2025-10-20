import 'package:intl/intl.dart';

class UserDetail {
  final String id;
  final String userId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? address;
  final String? avatarPath;
  final DateTime? lastLoginAt;
  final int status;
  final DateTime createdAt;
  final List<String> roles;

  UserDetail({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.address,
    this.avatarPath,
    this.lastLoginAt,
    required this.status,
    required this.createdAt,
    required this.roles,
  });

  // Helper getters để format ngày tháng
  String get formattedCreatedAt => DateFormat('dd/MM/yyyy - HH:mm').format(createdAt);
  String get formattedLastLoginAt =>
      lastLoginAt != null ? DateFormat('dd/MM/yyyy - HH:mm').format(lastLoginAt!) : 'Chưa từng đăng nhập';

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      fullName: json['fullName'] as String? ?? 'N/A',
      email: json['email'] as String? ?? 'N/A',
      phoneNumber: json['phoneNumber'] as String?,
      address: json['address'] as String?,
      avatarPath: json['avatarPath'] as String?,
      lastLoginAt: DateTime.tryParse(json['lastLoginAt'] as String? ?? ''),
      status: json['status'] as int? ?? 1, // Mặc định Inactive
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      roles: List<String>.from(json['roles'] as List? ?? []),
    );
  }
}

