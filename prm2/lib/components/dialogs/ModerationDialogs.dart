import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';


// Dialog cho Approve và Reject
Future<String?> showApproveRejectDialog(BuildContext context, {required bool isApproving}) async {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: kAdminCardColor,
      title: Text(isApproving ? 'Duyệt Podcast' : 'Từ chối Podcast'),
      content: TextField(
        controller: controller,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: isApproving ? 'Ghi chú (tùy chọn)' : 'Lý do từ chối',
          hintText: 'Nhập nội dung...',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            if (!isApproving && controller.text.isEmpty) {
              // Yêu cầu lý do khi từ chối
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Vui lòng nhập lý do từ chối.'),
                backgroundColor: kAdminErrorColor,
              ));
            } else {
              Navigator.pop(context, controller.text);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isApproving ? Colors.green : kAdminErrorColor,
          ),
          child: Text(isApproving ? 'Duyệt' : 'Từ chối'),
        ),
      ],
    ),
  );
}

// Dialog xác nhận xóa
Future<bool?> showDeleteConfirmDialog(BuildContext context, String podcastTitle) async {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: kAdminCardColor,
      title: const Text('Xác nhận Xóa'),
      content: Text('Bạn có chắc chắn muốn xóa vĩnh viễn podcast "$podcastTitle"? Hành động này không thể hoàn tác.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: kAdminErrorColor),
          child: const Text('Xóa vĩnh viễn'),
        ),
      ],
    ),
  );
}
