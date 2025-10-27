import 'dart:async';
import 'package:flutter/material.dart';
import '../models/SubscriptionPlan.dart';
import '../providers/SubscriptionPlanFilters.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'CreateSubscriptionScreen.dart';
import 'SubscriptionPlanDetailScreen.dart'; // Giả sử bạn có file màu này

// --- WIDGET MỚI ĐỂ HIỂN THỊ TRẠNG THÁI ---
// (Bạn có thể đặt widget này ở cuối file hoặc import từ file component)
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


class SubscriptionPlanManagementScreen extends StatefulWidget {
  const SubscriptionPlanManagementScreen({super.key});

  @override
  State<SubscriptionPlanManagementScreen> createState() =>
      _SubscriptionPlanManagementScreenState();
}

class _SubscriptionPlanManagementScreenState
    extends State<SubscriptionPlanManagementScreen> {
  final ApiService _apiService = ApiService();
  final _searchController = TextEditingController();
  Timer? _debounce;

  bool _isLoading = true;
  String? _error;
  List<SubscriptionPlan> _plans = [];

  int _currentPage = 1;
  int _totalPages = 1;

  late SubscriptionPlanFilters _currentFilters;

  @override
  void initState() {
    super.initState();
    _currentFilters = SubscriptionPlanFilters();
    _fetchPlans();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchPlans({int? page}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
      if (page != null) {
        _currentFilters = _currentFilters.copyWith(pageNumber: page);
      }
    });

    final result = await _apiService.getSubscriptionPlans(_currentFilters);

    if (mounted) {
      setState(() {
        if (result.isSuccess && result.data != null) {
          _plans = result.data!.items;
          _currentPage = result.data!.currentPage;
          _totalPages = result.data!.totalPages;
        } else {
          _error = result.message ?? "Lỗi không xác định";
          _plans = [];
        }
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _currentFilters = _currentFilters.copyWith(
          searchTerm: _searchController.text.trim(),
          pageNumber: 1,
        );
      });
      _fetchPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAdminBackgroundColor,
      appBar: AppBar(
        title: const Text('Quản lý Gói Plan',
            style: TextStyle(color: kAdminPrimaryTextColor)),
        backgroundColor: kAdminBackgroundColor,
        iconTheme: const IconThemeData(color: kAdminPrimaryTextColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: kAdminAccentColor),
            tooltip: 'Tạo gói mới',
            onPressed: () async {
              final bool? result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CreateSubscriptionScreen()),
              );
              if (result == true) {
                _fetchPlans();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(
                child: CircularProgressIndicator(color: kAdminAccentColor))
                : _error != null
                ? Center(
                child: Text('Lỗi: $_error',
                    style: const TextStyle(color: kAdminErrorColor)))
                : _plans.isEmpty
                ? const Center(
                child: Text('Không tìm thấy gói nào.',
                    style: TextStyle(
                        color: kAdminSecondaryTextColor)))
                : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _plans.length,
              itemBuilder: (context, index) =>
                  _buildPlanCard(_plans[index]),
              separatorBuilder: (context, index) =>
              const SizedBox(height: 12),
            ),
          ),
          if (!_isLoading && _totalPages > 1) _buildPaginationControls(),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _searchController,
              style: const TextStyle(color: kAdminPrimaryTextColor),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên gói...',
                hintStyle: const TextStyle(color: kAdminSecondaryTextColor),
                prefixIcon:
                const Icon(Icons.search, color: kAdminSecondaryTextColor),
                filled: true,
                fillColor: kAdminCardColor,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  // --- HÀM _buildPlanCard ĐÃ ĐƯỢC CẬP NHẬT ---
  Widget _buildPlanCard(SubscriptionPlan plan) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubscriptionPlanDetailScreen(planId: plan.id),
          ),
        ).then((_) {
          _fetchPlans();
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kAdminCardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kAdminInputBorderColor.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dòng trên cùng
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // Căn lề trên để chip và title thẳng hàng
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên plan
                Expanded(
                  child: Text(
                    plan.displayName,
                    style: const TextStyle(
                        color: kAdminPrimaryTextColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(width: 8), // Khoảng cách

                // --- THÊM STATUSCHIP VÀO ĐÂY ---
                StatusChip(status: plan.status),
              ],
            ),
            const SizedBox(height: 4),
            Text('Tên mã: ${plan.name}',
                style: const TextStyle(color: kAdminSecondaryTextColor)),

            // --- ĐÃ XÓA DÒNG TEXT TRẠNG THÁI Ở ĐÂY ---

            const Divider(height: 20, color: kAdminInputBorderColor),
            _buildInfoRow(Icons.price_change_outlined,
                '${plan.formattedAmount} / ${plan.billingPeriodUnitName}'),
            const SizedBox(height: 8),
            if (plan.trialDays != null && plan.trialDays! > 0)
              _buildInfoRow(
                  Icons.timer_outlined, 'Dùng thử: ${plan.trialDays} ngày'),
            const SizedBox(height: 8),
            _buildInfoRow(
                Icons.calendar_today_outlined, 'Ngày tạo: ${plan.formattedCreatedAt}'),
          ],
        ),
      ),
    );
  }
  // --- KẾT THÚC HÀM _buildPlanCard ---

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: kAdminSecondaryTextColor),
        const SizedBox(width: 8),
        Expanded(
            child: Text(text,
                style: const TextStyle(color: kAdminSecondaryTextColor),
                overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildPaginationControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: kAdminCardColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon:
            const Icon(Icons.chevron_left, color: kAdminSecondaryTextColor),
            onPressed: _currentPage > 1
                ? () => _fetchPlans(page: _currentPage - 1)
                : null,
          ),
          Text(
            'Trang $_currentPage / $_totalPages',
            style: const TextStyle(color: kAdminSecondaryTextColor),
          ),
          IconButton(
            icon:
            const Icon(Icons.chevron_right, color: kAdminSecondaryTextColor),
            onPressed: _currentPage < _totalPages
                ? () => _fetchPlans(page: _currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }
}