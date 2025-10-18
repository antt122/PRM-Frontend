import 'package:intl/intl.dart';

class UserDetail {
  final String id;
  // --- THÊM TRƯỜNG NÀY ---
  final String userId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? address;
  final String? avatarPath;
  final DateTime? lastLoginAt;
  final int status; // 0: Active, 1: Inactive, 2: Pending
  final DateTime createdAt;
  final List<String> roles;

  UserDetail({
    required this.id,
    required this.userId, // Thêm vào constructor
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

  // Helper để format ngày tháng
  String _formatDate(DateTime? date) {
    if (date == null) return 'Chưa từng đăng nhập';
    return DateFormat('dd/MM/yyyy - HH:mm').format(date);
  }

  String get formattedCreatedAt => _formatDate(createdAt);
  String get formattedLastLoginAt => _formatDate(lastLoginAt);

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '', // Lấy userId từ JSON
      fullName: json['fullName'] as String? ?? 'N/A',
      email: json['email'] as String? ?? 'N/A',
      phoneNumber: json['phoneNumber'] as String?,
      address: json['address'] as String?,
      avatarPath: json['avatarPath'] as String?,
      lastLoginAt: DateTime.tryParse(json['lastLoginAt'] as String? ?? ''),
      status: json['status'] as int? ?? 1, // Mặc định là Inactive
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      roles: List<String>.from(json['roles'] as List? ?? []),
    );
  }
}

