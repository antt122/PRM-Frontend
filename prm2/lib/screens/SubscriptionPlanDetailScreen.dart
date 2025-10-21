import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/SubscriptionPlan.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'UpdatePlanScreen.dart';

class SubscriptionPlanDetailScreen extends StatefulWidget {
  final String planId;

  const SubscriptionPlanDetailScreen({super.key, required this.planId});

  @override
  State<SubscriptionPlanDetailScreen> createState() => _SubscriptionPlanDetailScreenState();
}

class _SubscriptionPlanDetailScreenState extends State<SubscriptionPlanDetailScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;
  SubscriptionPlan? _plan;

  @override
  void initState() {
    super.initState();
    _fetchPlanDetails();
  }

  Future<void> _fetchPlanDetails() async {
    if (!_isLoading) setState(() { _isLoading = true; });
    try {
      final result = await _apiService.getSubscriptionPlanById(widget.planId);
      if (mounted) {
        if (result.isSuccess && result.data != null) {
          setState(() { _plan = result.data; _error = null; });
        } else {
          setState(() { _error = result.message ?? 'Không tìm thấy Gói Plan'; });
        }
      }
    } catch (e) {
      if (mounted) { setState(() { _error = "Lỗi kết nối: ${e.toString()}"; }); }
    } finally {
      if (mounted) { setState(() { _isLoading = false; }); }
    }
  }

  void _navigateToUpdateScreen() async {
    if (_plan == null) return;

    final bool? wasUpdated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateSubscriptionPlanScreen(initialPlan: _plan!),
      ),
    );

    if (wasUpdated == true) {
      _fetchPlanDetails();
    }
  }

  Future<void> _handleDeletePlan() async {
    if (_plan == null) return;
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kAdminCardColor,
          title: const Text('Xác nhận Xóa', style: TextStyle(color: kAdminPrimaryTextColor)),
          content: Text('Bạn có chắc chắn muốn xóa Gói Plan "${_plan!.displayName}" không?', style: const TextStyle(color: kAdminSecondaryTextColor)),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy', style: TextStyle(color: kAdminSecondaryTextColor)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Xóa', style: TextStyle(color: kAdminErrorColor)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmDelete != true) return;

    final result = await _apiService.deleteSubscriptionPlan(widget.planId);

    if (mounted) {
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? 'Xóa thành công!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${result.message ?? "Không rõ"}'), backgroundColor: kAdminErrorColor),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAdminBackgroundColor,
      appBar: AppBar(
        title: Text(_plan?.displayName ?? 'Chi tiết Gói Plan', style: const TextStyle(color: kAdminPrimaryTextColor)),
        backgroundColor: kAdminBackgroundColor,
        iconTheme: const IconThemeData(color: kAdminPrimaryTextColor),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchPlanDetails,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: kAdminAccentColor));
    }
    if (_error != null) {
      return Center(child: Text('Lỗi: $_error', style: const TextStyle(color: kAdminErrorColor)));
    }
    if (_plan == null) {
      return const Center(child: Text('Không có dữ liệu', style: TextStyle(color: kAdminSecondaryTextColor)));
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _PlanDetailCard(plan: _plan!),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _navigateToUpdateScreen,
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Chỉnh sửa gói'),
          style: ElevatedButton.styleFrom(
            backgroundColor: kAdminAccentColor,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _handleDeletePlan,
          icon: const Icon(Icons.delete_outline),
          label: const Text('Xóa Gói Plan'),
          style: ElevatedButton.styleFrom(
            backgroundColor: kAdminCardColor,
            foregroundColor: kAdminErrorColor,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: kAdminErrorColor),
            ),
          ),
        ),
      ],
    );
  }
}

// Widget để hiển thị chi tiết
class _PlanDetailCard extends StatelessWidget {
  final SubscriptionPlan plan;
  const _PlanDetailCard({required this.plan});

  // --- SỬA LỖI: ĐIỀN LẠI NỘI DUNG CHO CÁC HÀM HELPER ---

  Widget _buildInfoRow(String label, String value, {bool isMono = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label:', style: const TextStyle(color: kAdminSecondaryTextColor, fontSize: 16)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: kAdminPrimaryTextColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: isMono ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(title.toUpperCase(), style: const TextStyle(color: kAdminSecondaryTextColor, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
    );
  }

  // --- THÊM HELPER MỚI ĐỂ XỬ LÝ STATUS ---
  // -----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kAdminCardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(plan.displayName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kAdminPrimaryTextColor)),
          const SizedBox(height: 8),
          Text(plan.description ?? 'Không có mô tả', style: const TextStyle(fontSize: 16, color: kAdminSecondaryTextColor)),
          const SizedBox(height: 16),

          // --- THAY ĐỔI: SỬ DỤNG HELPER MỚI VỚI plan.status ---

          const Divider(height: 32, color: kAdminInputBorderColor),

          _buildSectionHeader('Thông tin chung'),
          _buildInfoRow('Tên mã', plan.name),
          _buildInfoRow('Trạng thái', plan.status),
          _buildInfoRow('Giá tiền', plan.formattedAmount),
          _buildInfoRow('Tiền tệ', plan.currency),
          _buildInfoRow('Chu kỳ', '${plan.billingPeriodCount} ${plan.billingPeriodUnitName}'),
          _buildInfoRow('Ngày dùng thử', '${plan.trialDays ?? 0} ngày'),

          _buildSectionHeader('Thông tin định danh'),
          _buildInfoRow('Plan ID', plan.id, isMono: true),

          _buildSectionHeader('Thông tin hệ thống'),
          _buildInfoRow('Ngày tạo', plan.formattedCreatedAt),
          if (plan.updatedAt != null)
            _buildInfoRow('Cập nhật lần cuối', DateFormat('dd/MM/yyyy HH:mm').format(plan.updatedAt!)),

          _buildSectionHeader('Cấu hình tính năng (JSON)'),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kAdminBackgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kAdminInputBorderColor),
            ),
            child: Text(
              plan.featureConfig ?? 'Không có cấu hình',
              style: const TextStyle(color: kAdminSecondaryTextColor, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}