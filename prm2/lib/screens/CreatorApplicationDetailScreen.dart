import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/CreatorApplicationDetail.dart';
import '../providers/CreatorApplicationProvider.dart';
import '../utils/app_colors.dart';



class CreatorApplicationDetailScreen extends ConsumerStatefulWidget {
  final String applicationId;
  const CreatorApplicationDetailScreen({super.key, required this.applicationId});

  @override
  ConsumerState<CreatorApplicationDetailScreen> createState() => _CreatorApplicationDetailScreenState();
}

class _CreatorApplicationDetailScreenState extends ConsumerState<CreatorApplicationDetailScreen> {
  bool _isProcessing = false;

  // --- Logic xử lý hành động (Approve/Reject) ---
  Future<void> _onApprove(CreatorApplicationDetail app) async {
    final notes = await _showInputDialog(context, title: 'Phê duyệt đơn', label: 'Ghi chú (tùy chọn)');
    if (notes == null) return;
    _performAction(() => ref.read(apiServiceProvider).approveApplication(applicationId: app.id, notes: notes));
  }

  Future<void> _onReject(CreatorApplicationDetail app) async {
    final reason = await _showInputDialog(context, title: 'Từ chối đơn', label: 'Lý do từ chối', isReject: true);
    if (reason == null || reason.isEmpty) return;
    _performAction(() => ref.read(apiServiceProvider).rejectApplication(applicationId: app.id, reason: reason));
  }

  Future<void> _performAction(Future<dynamic> Function() action) async {
    setState(() => _isProcessing = true);
    final result = await action();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result.message ?? (result.isSuccess ? 'Thao tác thành công!' : 'Lỗi')),
          backgroundColor: result.isSuccess ? Colors.green : kAdminErrorColor));
      if (result.isSuccess) Navigator.pop(context, true);
    }
    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(applicationDetailProvider(widget.applicationId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Duyệt đơn đăng ký'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(applicationDetailProvider(widget.applicationId)),
          ),
        ],
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: kAdminAccentColor)),
        error: (err, st) => Center(child: Text('Lỗi tải dữ liệu: $err')),
        data: (apiResult) {
          if (!apiResult.isSuccess || apiResult.data == null) {
            return Center(child: Text(apiResult.message ?? 'Không tìm thấy đơn.'));
          }
          final app = apiResult.data!;
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildApplicantInfoCard(app),
                    const SizedBox(height: 16),
                    _buildApplicationDetailsCard(app),
                    const SizedBox(height: 16),
                    _buildReviewInfoCard(app),
                  ],
                ),
              ),
              if (app.status == 0) _buildActionBar(app),
            ],
          );
        },
      ),
    );
  }

  // --- CÁC WIDGET THÀNH PHẦN GIAO DIỆN ---

  Widget _buildApplicantInfoCard(CreatorApplicationDetail app) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const CircleAvatar(radius: 24, child: Icon(Icons.person_outline, size: 24)),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(app.userFullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(app.userEmail, style: const TextStyle(color: kAdminSecondaryTextColor)),
              ])),
              _buildStatusChip(app.status),
            ]),
            const Divider(height: 24),
            _buildInfoRow('Vai trò:', app.businessRoleName ?? 'Chưa xác định'),
            _buildInfoRow('Ngày gửi:', app.formattedSubmittedAt),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationDetailsCard(CreatorApplicationDetail app) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chi tiết đơn', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kAdminSecondaryTextColor)),
            const SizedBox(height: 12),
            if (app.experience != null) _buildTitledContent('Kinh nghiệm:', app.experience!),
            if (app.motivation != null) _buildTitledContent('Động lực:', app.motivation!),
            if (app.portfolio != null)
              _buildTitledContent('Portfolio:', app.portfolio!, isLink: true),

            // --- CẬP NHẬT LOGIC HIỂN THỊ MẠNG XÃ HỘI ---
            if (app.socialMedia != null && app.socialMedia!.isNotEmpty) ...[
              const Divider(height: 24, color: kAdminInputBorderColor),
              _buildTitledContent('Mạng xã hội:', ''), // Chỉ hiển thị tiêu đề
              ...app.socialMedia!.entries.map((entry) {
                return _buildClickableInfoRow(
                  context,
                  // Sử dụng một icon chung cho các liên kết
                  icon: _getSocialIcon(entry.key),
                  label: entry.key,
                  value: entry.value.toString(),
                );
              }).toList(),
            ],

            if (app.additionalInfo != null) _buildTitledContent('Thông tin thêm:', app.additionalInfo!),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewInfoCard(CreatorApplicationDetail app) {
    if (app.status == 0) return const SizedBox.shrink();
    return Card(
      color: app.rejectionReason != null ? kAdminErrorColor.withOpacity(0.1) : kAdminCardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thông tin duyệt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kAdminSecondaryTextColor)),
            const SizedBox(height: 12),
            _buildInfoRow('Người duyệt:', app.reviewedByName ?? 'N/A'),
            _buildInfoRow('Ngày duyệt:', app.formattedReviewedAt),
            if (app.reviewNotes != null) _buildTitledContent('Ghi chú:', app.reviewNotes!),
            if (app.rejectionReason != null)
              _buildTitledContent('Lý do từ chối:', app.rejectionReason!, isError: true),
          ],
        ),
      ),
    );
  }

  Widget _buildTitledContent(String title, String content, {bool isLink = false, bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: kAdminSecondaryTextColor)),
          const SizedBox(height: 4),
          isLink
              ? InkWell(
            onTap: () async {
              final uri = Uri.tryParse(content);
              if (uri != null && await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Không thể mở liên kết: $content')),
                );
              }
            },
            child: Text(content, style: const TextStyle(color: kAdminAccentColor, decoration: TextDecoration.underline)),
          )
              : Text(content, style: TextStyle(color: isError ? kAdminErrorColor : kAdminPrimaryTextColor, height: 1.4)),
        ],
      ),
    );
  }

  // --- WIDGET HELPER MỚI ---
  IconData _getSocialIcon(String platformKey) {
    switch (platformKey.toLowerCase()) {
      case 'instagram': return Icons.camera_alt_outlined;
      case 'twitter': return Icons.alternate_email;
      case 'youtube': return Icons.video_library_outlined;
      case 'facebook': return Icons.facebook;
      case 'tiktok': return Icons.music_note_outlined;
      default: return Icons.link; // Icon chung
    }
  }

  Widget _buildClickableInfoRow(BuildContext context, {required IconData icon, required String label, required String value}) {
    final isUrl = value.startsWith('http://') || value.startsWith('https://');

    // Tạo tên hiển thị thân thiện hơn
    String platformName = label;
    if (label.toLowerCase().startsWith('additionalprop')) {
      platformName = 'Link ${label.substring('additionalprop'.length)}';
    } else {
      platformName = label[0].toUpperCase() + label.substring(1);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: kAdminSecondaryTextColor),
          const SizedBox(width: 8),
          Text('$platformName: ', style: const TextStyle(color: kAdminSecondaryTextColor)),
          Expanded(
            child: InkWell(
              onTap: isUrl ? () async {
                final uri = Uri.tryParse(value);
                if (uri != null && await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không thể mở liên kết: $value')));
                }
              } : null,
              child: Text(
                value,
                style: TextStyle(
                  color: isUrl ? kAdminAccentColor : kAdminPrimaryTextColor,
                  decoration: isUrl ? TextDecoration.underline : TextDecoration.none,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ', style: const TextStyle(color: kAdminSecondaryTextColor)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Chip _buildStatusChip(int status) {
    String label;
    Color color;
    switch (status) {
      case 0: label = 'Pending'; color = Colors.orange; break;
      case 1: label = 'Approved'; color = Colors.green; break;
      case 2: label = 'Rejected'; color = kAdminErrorColor; break;
      default: label = 'Unknown'; color = kAdminSecondaryTextColor;
    }
    return Chip(label: Text(label), backgroundColor: color.withOpacity(0.2), labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold));
  }

  Widget _buildActionBar(CreatorApplicationDetail app) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
          color: kAdminCardColor,
          border: Border(top: BorderSide(color: kAdminInputBorderColor.withOpacity(0.5)))),
      child: _isProcessing
          ? const Center(child: CircularProgressIndicator(color: kAdminAccentColor))
          : Row(children: [
        Expanded(child: ElevatedButton.icon(onPressed: () => _onApprove(app), icon: const Icon(Icons.check), label: const Text('Phê duyệt'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white))),
        const SizedBox(width: 12),
        Expanded(child: ElevatedButton.icon(onPressed: () => _onReject(app), icon: const Icon(Icons.close), label: const Text('Từ chối'), style: ElevatedButton.styleFrom(backgroundColor: kAdminErrorColor, foregroundColor: Colors.white))),
      ]),
    );
  }

  Future<String?> _showInputDialog(BuildContext context, {required String title, required String label, bool isReject = false}) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(controller: controller, maxLines: 3, decoration: InputDecoration(labelText: label)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (isReject && controller.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập lý do từ chối.")));
                return;
              }
              Navigator.pop(context, controller.text);
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }
}

