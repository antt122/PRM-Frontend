import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/creator_application_status.dart';
import '../utils/app_colors.dart';
import '../utils/app_fonts.dart';
import 'creator_application_screen.dart';

// Màn hình hiển thị chi tiết trạng thái đơn đăng ký - Mobile Optimized
class ApplicationStatusScreen extends StatelessWidget {
  final CreatorApplicationStatus status;

  const ApplicationStatusScreen({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kGlassBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kGlassBorder, width: 0.5),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: kPrimaryTextColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: kGlassBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kGlassBorder, width: 0.5),
          ),
          child: Text(
            'Trạng thái đơn đăng ký',
            style: AppFonts.title3.copyWith(
              color: kPrimaryTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kBackgroundColor, kSurfaceColor],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  decoration: BoxDecoration(
                    color: kGlassBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kGlassBorder, width: 0.5),
                    boxShadow: [
                      BoxShadow(
                        color: kGlassShadow,
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Header - Compact
                        _buildStatusHeader(),
                        const SizedBox(height: 20),

                        // Application Details - Compact Grid
                        _buildCompactDetails(),
                        const SizedBox(height: 20),

                        // Review Info - Compact
                        if (status.reviewedAt != null) ...[
                          _buildCompactReviewInfo(),
                          const SizedBox(height: 20),
                        ],

                        // Next Steps or Rejection Reason - Compact
                        if (status.nextSteps != null &&
                            status.nextSteps!.isNotEmpty)
                          _buildCompactNextSteps(),

                        if (status.rejectionReason != null &&
                            status.rejectionReason!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildCompactRejectionReason(),
                        ],

                        const SizedBox(height: 20),

                        // Action Button
                        if (status.canResubmit &&
                            status.status.toLowerCase() == 'rejected')
                          _buildResubmitButton(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Row(
      children: [
        // Status Icon - Smaller
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: status.statusColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: status.statusColor, width: 2),
          ),
          child: Icon(status.statusIcon, color: status.statusColor, size: 24),
        ),
        const SizedBox(width: 16),

        // Status Info - Compact
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                status.status.toUpperCase(),
                style: AppFonts.title3.copyWith(
                  color: status.statusColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                status.statusDescription,
                style: AppFonts.caption1.copyWith(color: kPrimaryTextColor),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Nộp đơn: ${status.formattedSubmittedAt}',
                style: AppFonts.caption2.copyWith(color: kSecondaryTextColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chi tiết đơn đăng ký',
          style: AppFonts.title3.copyWith(
            color: kPrimaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Compact Grid Layout
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCompactDetailItem('Kinh nghiệm', status.experience),
                  const SizedBox(height: 8),
                  _buildCompactDetailItem('Portfolio', status.portfolio),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Right Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCompactDetailItem('Động lực', status.motivation),
                  if (status.additionalInfo != null &&
                      status.additionalInfo!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildCompactDetailItem(
                      'Thông tin bổ sung',
                      status.additionalInfo!,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),

        // Social Media - Full Width
        if (status.socialMedia.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildCompactSocialMedia(),
        ],
      ],
    );
  }

  Widget _buildCompactDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFonts.caption2.copyWith(
            color: kSecondaryTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppFonts.caption1.copyWith(
            color: kPrimaryTextColor,
            height: 1.3,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildCompactSocialMedia() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mạng xã hội',
          style: AppFonts.caption2.copyWith(
            color: kSecondaryTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        if (status.socialMedia.isEmpty)
          Text(
            'Không có thông tin',
            style: AppFonts.caption1.copyWith(
              color: kSecondaryTextColor,
              fontStyle: FontStyle.italic,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: status.socialMedia
                .map(
                  (social) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: kSurfaceColor.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      social.toString(),
                      style: AppFonts.caption2.copyWith(
                        color: kPrimaryTextColor,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildCompactReviewInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kSurfaceColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kGlassBorder, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: kSecondaryTextColor, size: 16),
          const SizedBox(width: 8),
          Text(
            'Duyệt: ${status.formattedReviewedAt}',
            style: AppFonts.caption1.copyWith(color: kPrimaryTextColor),
          ),
          if (status.reviewedBy != null) ...[
            const SizedBox(width: 16),
            Icon(Icons.person, color: kSecondaryTextColor, size: 16),
            const SizedBox(width: 4),
            Text(
              status.reviewedBy!,
              style: AppFonts.caption1.copyWith(color: kPrimaryTextColor),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactNextSteps() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kSuccessColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: kSuccessColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: kSuccessColor, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              status.nextSteps!,
              style: AppFonts.caption1.copyWith(
                color: kPrimaryTextColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactRejectionReason() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kErrorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: kErrorColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: kErrorColor, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lý do từ chối',
                  style: AppFonts.caption1.copyWith(
                    color: kErrorColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status.rejectionReason!,
                  style: AppFonts.caption1.copyWith(
                    color: kPrimaryTextColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kAccentColor, kAccentColor.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: kAccentColor.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreatorApplicationScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'GỬI ĐƠN MỚI',
                style: AppFonts.headline.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
