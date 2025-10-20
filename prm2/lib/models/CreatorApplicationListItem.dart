import 'package:intl/intl.dart';

class CreatorApplicationListItem {
  final String id;
  final String userFullName;
  final String userEmail;
  final DateTime submittedAt;
  final String status; // Giữ lại là String để UI hiển thị
  final String experienceSummary;
  final String? portfolioUrl;
  final String businessRoleName;

  CreatorApplicationListItem({
    required this.id,
    required this.userFullName,
    required this.userEmail,
    required this.submittedAt,
    required this.status,
    required this.experienceSummary,
    this.portfolioUrl,
    required this.businessRoleName,
  });

  String get formattedSubmittedAt => DateFormat('dd/MM/yyyy').format(submittedAt);

  factory CreatorApplicationListItem.fromJson(Map<String, dynamic> json) {
    // --- SỬA LỖI Ở ĐÂY ---
    // Chuyển đổi status từ int sang String
    String statusString;
    switch (json['status'] as int?) {
      case 0:
        statusString = 'Pending';
        break;
      case 1:
        statusString = 'Approved';
        break;
      case 2:
        statusString = 'Rejected';
        break;
      default:
        statusString = 'Unknown';
    }

    return CreatorApplicationListItem(
      id: json['id'] as String? ?? '',
      userFullName: json['userFullName'] as String? ?? 'N/A',
      userEmail: json['userEmail'] as String? ?? 'N/A',
      submittedAt: DateTime.tryParse(json['submittedAt'] as String? ?? '') ?? DateTime.now(),
      status: statusString, // Gán chuỗi đã được chuyển đổi
      experienceSummary: json['experienceSummary'] as String? ?? '',
      portfolioUrl: json['portfolioUrl'] as String?,
      businessRoleName: json['businessRoleName'] as String? ?? 'N/A',
    );
  }
}

