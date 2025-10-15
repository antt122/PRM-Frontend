import 'package:flutter/material.dart';
import '../models/creator_application_status.dart';
import '../utils/app_colors.dart';

// Màn hình hiển thị chi tiết trạng thái đơn đăng ký (phiên bản nghệ thuật)
class ApplicationStatusScreen extends StatelessWidget {
  final CreatorApplicationStatus status;

  const ApplicationStatusScreen({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Trạng thái đơn đăng ký',
            style: TextStyle(color: kPrimaryTextColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: kPrimaryTextColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // 2. Thẻ trạng thái
            _buildStatusChip(),
            const SizedBox(height: 16),

            // 3. Mô tả chính
            Text(
              status.statusDescription,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryTextColor),
            ),
            const SizedBox(height: 8),

            // 4. Ngày nộp đơn
            if (status.submittedAt != null)
              Text(
                'Đã nộp vào ngày: ${status.submittedAt!.day}/${status.submittedAt!.month}/${status.submittedAt!.year}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            const SizedBox(height: 32),

            // 5. Các thông tin chi tiết (nếu có)
            if (status.nextSteps != null && status.nextSteps!.isNotEmpty)
              _buildInfoCard('Các bước tiếp theo', status.nextSteps!),

            if (status.rejectionReason != null &&
                status.rejectionReason!.isNotEmpty)
              _buildInfoCard('Lý do từ chối', status.rejectionReason!,
                  isError: true),

            const SizedBox(height: 40),

            // 6. Nút hành động (nếu có)
            // if (status.canResubmit) _buildResubmitButton(),
          ],
        ),
      ),
    );
  }

  // --- CÁC WIDGET HELPER ---



  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: status.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: status.statusColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hourglass_top_rounded, color: status.statusColor, size: 18),
          const SizedBox(width: 10),
          Text(
            status.status.toUpperCase(),
            style: TextStyle(
              color: status.statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, {bool isError = false}) {
    final cardColor = isError ? Colors.red.withOpacity(0.05) : kHighlightColor;
    final borderColor = isError ? Colors.red.shade200 : kInputBorderColor;
    final titleColor = isError ? Colors.red.shade800 : kPrimaryTextColor;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(fontSize: 14, color: titleColor, height: 1.5),
          ),
        ],
      ),
    );
  }

  // Widget _buildResubmitButton() {
  //   return SizedBox(
  //     width: double.infinity,
  //     child: ElevatedButton(
  //       onPressed: () {
  //         // TODO: Điều hướng đến trang đăng ký lại
  //       },
  //       style: ElevatedButton.styleFrom(
  //         backgroundColor: kPrimaryTextColor,
  //         foregroundColor: Colors.white,
  //         padding: const EdgeInsets.symmetric(vertical: 16),
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(30),
  //         ),
  //       ),
  //       child: const Text('NỘP LẠI ĐƠN'),
  //     ),
  //   );
  // }
}

