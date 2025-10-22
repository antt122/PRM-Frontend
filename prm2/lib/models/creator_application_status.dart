import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

// Model để lưu trữ thông tin trạng thái đơn đăng ký
class CreatorApplicationStatus {
  final String applicationId;
  final String status;
  final String statusDescription;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? rejectionReason;
  final String experience;
  final String portfolio;
  final String motivation;
  final List<dynamic> socialMedia;
  final String? additionalInfo;
  final String requestedBusinessRole;
  final bool canResubmit;
  final String? nextSteps;

  CreatorApplicationStatus({
    required this.applicationId,
    required this.status,
    required this.statusDescription,
    this.submittedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.rejectionReason,
    required this.experience,
    required this.portfolio,
    required this.motivation,
    required this.socialMedia,
    this.additionalInfo,
    required this.requestedBusinessRole,
    required this.canResubmit,
    this.nextSteps,
  });

  factory CreatorApplicationStatus.fromJson(Map<String, dynamic> json) {
    return CreatorApplicationStatus(
      applicationId: json['applicationId'] as String? ?? '',
      status: json['status'] as String? ?? 'Unknown',
      statusDescription: json['statusDescription'] as String? ?? '',
      submittedAt: json['submittedAt'] != null
          ? DateTime.tryParse(json['submittedAt'])
          : null,
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.tryParse(json['reviewedAt'])
          : null,
      reviewedBy: json['reviewedBy'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      experience: json['experience'] as String? ?? '',
      portfolio: json['portfolio'] as String? ?? '',
      motivation: json['motivation'] as String? ?? '',
      socialMedia: json['socialMedia'] as List<dynamic>? ?? [],
      additionalInfo: json['additionalInfo'] as String?,
      requestedBusinessRole:
          json['requestedBusinessRole'] as String? ?? 'Content Creator',
      canResubmit: json['canResubmit'] as bool? ?? false,
      nextSteps: json['nextSteps'] as String?,
    );
  }

  // Helper để lấy màu sắc tương ứng với trạng thái
  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return kWarningColor;
      case 'approved':
        return kSuccessColor;
      case 'rejected':
        return kErrorColor;
      default:
        return kSecondaryTextColor;
    }
  }

  // Helper để lấy icon tương ứng với trạng thái
  IconData get statusIcon {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_top_rounded;
      case 'approved':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  // Helper để format ngày tháng
  String get formattedSubmittedAt {
    if (submittedAt == null) return 'Không xác định';
    return '${submittedAt!.day}/${submittedAt!.month}/${submittedAt!.year}';
  }

  String get formattedReviewedAt {
    if (reviewedAt == null) return 'Chưa được duyệt';
    return '${reviewedAt!.day}/${reviewedAt!.month}/${reviewedAt!.year}';
  }
}
