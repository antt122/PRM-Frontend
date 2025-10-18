import 'dart:async';
import 'package:flutter/material.dart';
import '../models/SubscriptionPlan.dart';
import '../models/SubscriptionPlanFilters.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'CreateSubscriptionScreen.dart';
import 'SubscriptionPlanDetailScreen.dart'; // Giả sử bạn có file màu này

class SubscriptionPlanManagementScreen extends StatefulWidget {
  const SubscriptionPlanManagementScreen({super.key});

  @override
  State<SubscriptionPlanManagementScreen> createState() =>
      _SubscriptionPlanManagementScreenState();
}

class _SubscriptionPlanManagementScreenState extends State<SubscriptionPlanManagementScreen> {
  final ApiService _apiService = ApiService();
  final _searchController = TextEditingController();
  Timer? _debounce;

  bool _isLoading = true;
  String? _error;
  List<SubscriptionPlan> _plans = [];

  // --- THAY ĐỔI: Thêm các biến state để lưu thông tin phân trang từ response ---
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
      // Cập nhật trang yêu cầu trong bộ lọc
      if (page != null) {
        _currentFilters = _currentFilters.copyWith(pageNumber: page);
      }
    });

    final result = await _apiService.getSubscriptionPlans(_currentFilters);

    if (mounted) {
      setState(() {
        if (result.isSuccess && result.data != null) {
          _plans = result.data!.items;
          // --- THAY ĐỔI: Cập nhật state từ response với tên thuộc tính đúng ---
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
          pageNumber: 1, // Reset về trang 1 khi tìm kiếm
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
        title: const Text('Quản lý Gói Plan', style: TextStyle(color: kAdminPrimaryTextColor)),
        backgroundColor: kAdminBackgroundColor,
        iconTheme: const IconThemeData(color: kAdminPrimaryTextColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: kAdminAccentColor),
            tooltip: 'Tạo gói mới',
            onPressed: () async {
              final bool? result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateSubscriptionScreen()),
              );
              // Nếu kết quả trả về là true (tức là tạo thành công),
              // thì tải lại danh sách
              if (result == true) {
                _fetchPlans();
              }            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: kAdminAccentColor))
                : _error != null
                ? Center(child: Text('Lỗi: $_error', style: const TextStyle(color: kAdminErrorColor)))
                : _plans.isEmpty
                ? const Center(child: Text('Không tìm thấy gói nào.', style: TextStyle(color: kAdminSecondaryTextColor)))
                : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _plans.length,
              itemBuilder: (context, index) => _buildPlanCard(_plans[index]),
              separatorBuilder: (context, index) => const SizedBox(height: 12),
            ),
          ),
          // --- THAY ĐỔI: Bỏ tham số không cần thiết ---
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
                prefixIcon: const Icon(Icons.search, color: kAdminSecondaryTextColor),
                filled: true,
                fillColor: kAdminCardColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubscriptionPlanDetailScreen(planId: plan.id),
          ),
        ).then((_) {
          // Khi quay lại từ màn hình chi tiết, tải lại dữ liệu để cập nhật
          // thay đổi nếu có (ví dụ sau khi Edit hoặc Delete)
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    plan.displayName,
                    style: const TextStyle(color: kAdminPrimaryTextColor, fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusChip(plan.isActive),
              ],
            ),
            const SizedBox(height: 4),
            Text('Tên mã: ${plan.name}', style: const TextStyle(color: kAdminSecondaryTextColor)),
            const Divider(height: 20, color: kAdminInputBorderColor),
            _buildInfoRow(Icons.price_change_outlined, '${plan.formattedAmount} / ${plan.billingPeriodUnitName}'),
            const SizedBox(height: 8),
            if (plan.trialDays != null && plan.trialDays! > 0)
              _buildInfoRow(Icons.timer_outlined, 'Dùng thử: ${plan.trialDays} ngày'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.calendar_today_outlined, 'Ngày tạo: ${plan.formattedCreatedAt}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: kAdminSecondaryTextColor),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(color: kAdminSecondaryTextColor), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildStatusChip(bool isActive) {
    final String label = isActive ? 'Hoạt động' : 'Không hoạt động';
    final Color color = isActive ? Colors.green : kAdminErrorColor;
    return Chip(
      label: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
      backgroundColor: color.withOpacity(0.15),
      padding: EdgeInsets.zero,
      side: BorderSide.none,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  // --- THAY ĐỔI: Cập nhật lại toàn bộ widget này để dùng state ---
  Widget _buildPaginationControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: kAdminCardColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: kAdminSecondaryTextColor),
            onPressed: _currentPage > 1
                ? () => _fetchPlans(page: _currentPage - 1)
                : null,
          ),
          Text(
            'Trang $_currentPage / $_totalPages',
            style: const TextStyle(color: kAdminSecondaryTextColor),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: kAdminSecondaryTextColor),
            onPressed: _currentPage < _totalPages
                ? () => _fetchPlans(page: _currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }
}