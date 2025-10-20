import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/PaymentMethodDetail.dart';
import '../providers/PaymentMethodFilter.dart';
import '../utils/app_colors.dart';
import 'PaymentMethodEditScreen.dart';



// --- CHUYỂN SANG STATEFUL WIDGET ĐỂ QUẢN LÝ STATE ---
class PaymentMethodDetailScreen extends ConsumerStatefulWidget {
  final String methodId;
  const PaymentMethodDetailScreen({super.key, required this.methodId});

  @override
  ConsumerState<PaymentMethodDetailScreen> createState() => _PaymentMethodDetailScreenState();
}

class _PaymentMethodDetailScreenState extends ConsumerState<PaymentMethodDetailScreen> {
  bool _isProcessing = false;

  // --- HÀM XỬ LÝ XÓA ---
  Future<void> _handleDelete() async {
    final detailAsync = ref.read(paymentMethodDetailProvider(widget.methodId));
    final method = detailAsync.value?.data;
    if (method == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa vĩnh viễn phương thức "${method.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: kAdminErrorColor),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isProcessing = true);
      final result = await ref.read(paymentMethodServiceProvider).deletePaymentMethod(widget.methodId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? (result.isSuccess ? '✅ Xóa thành công!' : '❌ Lỗi')),
            backgroundColor: result.isSuccess ? Colors.green : kAdminErrorColor,
          ),
        );
        if (result.isSuccess) {
          Navigator.pop(context, true); // Quay về và báo hiệu thành công
        }
      }
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(paymentMethodDetailProvider(widget.methodId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết Phương thức'),
        actions: [
          if (detailAsync.hasValue && detailAsync.value!.isSuccess)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Chỉnh sửa',
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaymentMethodEditScreen(initialData: detailAsync.value!.data!)),
                );
                if (result == true) {
                  ref.refresh(paymentMethodDetailProvider(widget.methodId));
                }
              },
            ),
          // --- THÊM MENU VỚI TÙY CHỌN XÓA ---
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _handleDelete();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_outline, color: kAdminErrorColor),
                  title: Text('Xóa', style: TextStyle(color: kAdminErrorColor)),
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () => ref.refresh(paymentMethodDetailProvider(widget.methodId).future),
        child: detailAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: kAdminAccentColor)),
          error: (err, st) => Center(child: Text('Lỗi tải dữ liệu: $err')),
          data: (apiResult) {
            if (!apiResult.isSuccess || apiResult.data == null) {
              return Center(child: Text(apiResult.message ?? 'Không tìm thấy dữ liệu.'));
            }
            final method = apiResult.data!;
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildInfoCard(context, method),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- CÁC HÀM HELPER BUILD UI ---
  Widget _buildInfoCard(BuildContext context, PaymentMethodDetail method) {
    final bool isActive = method.status == 'Active';
    final statusColor = isActive ? Colors.green : kAdminSecondaryTextColor;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(method.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                ),
                Chip(
                  avatar: Icon(Icons.circle, size: 12, color: statusColor),
                  label: Text(method.status),
                  backgroundColor: statusColor.withOpacity(0.1),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Provider: ${method.providerName}', style: const TextStyle(color: kAdminSecondaryTextColor, fontWeight: FontWeight.w500)),
            const Divider(height: 32),
            _buildInfoRow(context, 'Mô tả', method.description),
            _buildInfoRow(context, 'Loại', method.typeName),
            _buildInfoRow(context, 'Cấu hình', method.configuration, isCode: true),
            const Divider(height: 32),
            _buildAuditRow('Tạo bởi', method.createdBy, method.formattedCreatedAt),
            if (method.updatedBy != null)
              _buildAuditRow('Cập nhật bởi', method.updatedBy, method.formattedUpdatedAt),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, {bool isCode = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: kAdminSecondaryTextColor, fontSize: 14)),
          const SizedBox(height: 4),
          isCode
              ? Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: kAdminBackgroundColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(value, style: const TextStyle(fontFamily: 'monospace')),
          )
              : Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }

// HÀM _buildAuditRow ĐÃ SỬA LỖI
  Widget _buildAuditRow(String label, String? user, String date) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        // Canh icon và text thẳng hàng theo chiều dọc
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.person_outline, size: 16, color: kAdminSecondaryTextColor),
          const SizedBox(width: 8),
          // THAY ĐỔI QUAN TRỌNG NHẤT: BỌC TEXT BẰNG EXPANDED
          Expanded(
            child: Text(
              '$label ${user ?? 'N/A'} • $date',
              style: const TextStyle(color: kAdminSecondaryTextColor, fontSize: 12),
              // softWrap: true là mặc định, nhưng để đây cho rõ ràng
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}

