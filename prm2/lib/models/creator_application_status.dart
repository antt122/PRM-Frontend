import 'package:flutter/material.dart';

// Model để lưu trữ thông tin trạng thái đơn đăng ký
class CreatorApplicationStatus {
  final String applicationId;
  final String status;
  final String statusDescription;
  final DateTime? submittedAt;
  final bool canResubmit;
  final String? nextSteps;
  final String? rejectionReason;

  CreatorApplicationStatus({
    required this.applicationId,
    required this.status,
    required this.statusDescription,
    this.submittedAt,
    required this.canResubmit,
    this.nextSteps,
    this.rejectionReason,
  });

  factory CreatorApplicationStatus.fromJson(Map<String, dynamic> json) {
    return CreatorApplicationStatus(
      applicationId: json['applicationId'] as String? ?? '',
      status: json['status'] as String? ?? 'Unknown',
      statusDescription: json['statusDescription'] as String? ?? '',
      submittedAt: json['submittedAt'] != null
          ? DateTime.tryParse(json['submittedAt'])
          : null,
      canResubmit: json['canResubmit'] as bool? ?? false,
      nextSteps: json['nextSteps'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
    );
  }

  // Helper để lấy màu sắc tương ứng với trạng thái
  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade700;
      case 'approved':
        return Colors.green.shade700;
      case 'rejected':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }
}
