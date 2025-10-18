import 'package:intl/intl.dart';

class CmsUserProfile {
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? address;
  final String? avatarPath;
  final DateTime createdAt;

  CmsUserProfile({
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.address,
    this.avatarPath,
    required this.createdAt,
  });

  // Helper getter để format ngày tạo
  String get formattedCreatedAt {
    return DateFormat('dd/MM/yyyy').format(createdAt);
  }

  factory CmsUserProfile.fromJson(Map<String, dynamic> json) {
    return CmsUserProfile(
      fullName: json['fullName'] as String? ?? 'N/A',
      email: json['email'] as String? ?? 'N/A',
      phoneNumber: json['phoneNumber'] as String?,
      address: json['address'] as String?,
      avatarPath: json['avatarPath'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
