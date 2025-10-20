  import 'package:intl/intl.dart';

class CreatorApplicationDetail {
  final String id;
  final String userId;
  final String userEmail;
  final String userFullName;
  final DateTime submittedAt;
  final int status;
  final String? experience;
  final String? portfolio;
  final String? motivation;
  // --- TRẢ LẠI CẤU TRÚC MAP ---
  final Map<String, dynamic>? socialMedia;
  final String? additionalInfo;
  final DateTime? reviewedAt;
  final String? reviewedByName;
  final String? rejectionReason;
  final String? reviewNotes;
  final String? businessRoleName;

  CreatorApplicationDetail({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userFullName,
    required this.submittedAt,
    required this.status,
    this.experience,
    this.portfolio,
    this.motivation,
    this.socialMedia,
    this.additionalInfo,
    this.reviewedAt,
    this.reviewedByName,
    this.rejectionReason,
    this.reviewNotes,
    this.businessRoleName,
  });

  String get formattedSubmittedAt => DateFormat('dd/MM/yyyy - HH:mm').format(submittedAt);
  String get formattedReviewedAt => reviewedAt != null ? DateFormat('dd/MM/yyyy - HH:mm').format(reviewedAt!) : 'Chưa được duyệt';

  factory CreatorApplicationDetail.fromJson(Map<String, dynamic> json) {
    return CreatorApplicationDetail(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userEmail: json['userEmail'] as String? ?? 'N/A',
      userFullName: json['userFullName'] as String? ?? 'N/A',
      submittedAt: DateTime.tryParse(json['submittedAt'] as String? ?? '') ?? DateTime.now(),
      status: json['status'] as int? ?? 0,
      experience: json['experience'] as String?,
      portfolio: json['portfolio'] as String?,
      motivation: json['motivation'] as String?,
      // --- LẤY TRỰC TIẾP MAP TỪ JSON ---
      socialMedia: json['socialMedia'] as Map<String, dynamic>?,
      additionalInfo: json['additionalInfo'] as String?,
      reviewedAt: DateTime.tryParse(json['reviewedAt'] as String? ?? ''),
      reviewedByName: json['reviewedByName'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      reviewNotes: json['reviewNotes'] as String?,
      businessRoleName: json['businessRoleName'] as String?,
    );
  }
}

