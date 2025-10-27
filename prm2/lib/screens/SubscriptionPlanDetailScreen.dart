import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/SubscriptionPlan.dart';
import '../services/SubscriptionPlanService.dart';
import '../utils/app_colors.dart';
import 'UpdatePlanScreen.dart'; // Đổi tên file này nếu cần

// --- WIDGET STATUSCHIP (Được thêm vào) ---
// (Bạn có thể chuyển widget này sang file component riêng nếu muốn)
class StatusChip extends StatelessWidget {
  final String? status;

  const StatusChip({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color dotColor;
    String statusText;

    // Logic màu sắc dựa trên status
    switch (status?.toLowerCase()) {
      case 'active':
        dotColor = Colors.green;
        statusText = 'Active';
        break;
      case 'inactive':
        dotColor = Colors.red;
        statusText = 'Inactive';
        break;
      case 'pending':
        dotColor = Colors.orange; // Màu vàng (cam) cho Pending
        statusText = 'Pending';
        break;
      default:
      // Xử lý các trường hợp khác (null, rỗng, hoặc không xác định)
        dotColor = Colors.grey;
        statusText = (status == null || status!.isEmpty) ? 'Unknown' : status!;
        // Viết hoa chữ cái đầu
        statusText = statusText[0].toUpperCase() + statusText.substring(1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        // Dùng màu nền mờ từ theme của bạn
        color: kAdminInputBorderColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16), // Bo tròn
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Chỉ chiếm không gian cần thiết
        children: [
          // Chấm tròn màu
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          // Chữ trạng thái
          Text(
            statusText,
            style: const TextStyle(color: kAdminPrimaryTextColor, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
// --- KẾT THÚC WIDGET STATUSCHIP ---


class SubscriptionPlanDetailScreen extends StatefulWidget {
  final String planId;

  const SubscriptionPlanDetailScreen({super.key, required this.planId});

  @override
  State<SubscriptionPlanDetailScreen> createState() =>
      _SubscriptionPlanDetailScreenState();
}

class _SubscriptionPlanDetailScreenState
    extends State<SubscriptionPlanDetailScreen> {
  final SubscriptionPlanService _apiService = SubscriptionPlanService();
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

  // --- WIDGET BUILD CỦA CARD ĐÃ ĐƯỢC CẬP NHẬT ---
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
          // --- THAY ĐỔI: Thêm Row để chứa Title và Status Chip ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start, // Căn lề trên
            children: [
              // Title (bọc trong Expanded để không overflow)
              Expanded(
                child: Text(
                  plan.displayName,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: kAdminPrimaryTextColor),
                ),
              ),
              const SizedBox(width: 16), // Khoảng cách
              // Status Chip
              StatusChip(status: plan.status),
            ],
          ),
          // --- KẾT THÚC THAY ĐỔI ---

          const SizedBox(height: 8),
          Text(plan.description ?? 'Không có mô tả',
              style: const TextStyle(fontSize: 16, color: kAdminSecondaryTextColor)),

          const Divider(height: 32, color: kAdminInputBorderColor),

          _buildSectionHeader('Thông tin chung'),
          _buildInfoRow('Tên mã', plan.name),
          _buildInfoRow('Giá tiền', plan.formattedAmount),

          // --- THAY ĐỔI: Đã xóa dòng _buildInfoRow('Trạng thái', plan.status) ---

          _buildInfoRow('Tiền tệ', plan.currency),
          _buildInfoRow(
              'Chu kỳ', '${plan.billingPeriodCount} ${plan.billingPeriodUnitName}'),
          _buildInfoRow('Ngày dùng thử', '${plan.trialDays ?? 0} ngày'),

          _buildSectionHeader('Thông tin định danh'),
          _buildInfoRow('Plan ID', plan.id, isMono: true),

          _buildSectionHeader('Thông tin hệ thống'),
          _buildInfoRow('Ngày tạo', plan.formattedCreatedAt),
          if (plan.updatedAt != null)
            _buildInfoRow('Cập nhật lần cuối',
                DateFormat('dd/MM/yyyy HH:mm').format(plan.updatedAt!)),

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
              style: const TextStyle(
                  color: kAdminSecondaryTextColor, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}