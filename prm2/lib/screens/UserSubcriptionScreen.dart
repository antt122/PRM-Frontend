import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/Subscription.dart';
import '../providers/SubscriptionFilters.dart';
import '../services/api_service.dart';

// --- THAY ĐỔI 1: Thêm import cho màn hình chi tiết ---
import 'SubscriptionDetailScreen.dart';

class UserSubscriptionScreen extends StatefulWidget {
  final String userId;

  const UserSubscriptionScreen({
    super.key,
    required this.userId,
  });

  @override
  State<UserSubscriptionScreen> createState() => _UserSubscriptionScreenState();
}

class _UserSubscriptionScreenState extends State<UserSubscriptionScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;
  List<Subscription> _subscriptions = [];
  late SubscriptionFilters _currentFilters;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentFilters = SubscriptionFilters(
      userProfileId: widget.userId,
      pageNumber: 1,
      pageSize: 50,
      sortBy: 'createdAt',
      sortOrder: 'desc',
    );
    _fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final result = await _apiService.getSubscriptions(_currentFilters);
      if (mounted) {
        if (result.isSuccess && result.data != null) {
          setState(() { _subscriptions = result.data!.items; });
        } else {
          setState(() { _error = result.message ?? 'Không thể tải dữ liệu'; });
        }
      }
    } catch (e) {
      if (mounted) { setState(() { _error = "Lỗi kết nối: ${e.toString()}"; }); }
    } finally {
      if (mounted) { setState(() { _isLoading = false; }); }
    }
  }

  void _onSearchSubmitted(String search) {
    setState(() {
      _currentFilters = _currentFilters.copyWith(
        search: search.trim(), // Sửa 'search' thành 'keyword' cho đúng với model
        pageNumber: 1,
      );
    });
    _fetchData();
  }

  void _onClearSearch() {
    _searchController.clear();
    setState(() {
      _currentFilters = _currentFilters.copyWith(
        search: '', // Sửa 'search' thành 'keyword'
        pageNumber: 1,
      );
    });
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử Gói Đăng ký'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm theo Plan Name, Display Name...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _onClearSearch,
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onSubmitted: _onSearchSubmitted,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchData,
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Lỗi: $_error', textAlign: TextAlign.center),
        ),
      );
    }
    if (_subscriptions.isEmpty) {
      if (_currentFilters.search != null && _currentFilters.search!.isNotEmpty) {
        return const Center(child: Text('Không tìm thấy kết quả nào.'));
      }
      return const Center(child: Text('Người dùng này không có gói đăng ký nào.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _subscriptions.length,
      itemBuilder: (context, index) {
        final subscription = _subscriptions[index];

        // --- THAY ĐỔI 2: Bọc Card bằng InkWell để xử lý điều hướng ---
        return InkWell(
          onTap: () {
            // Điều hướng đến trang chi tiết khi bấm vào
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubscriptionDetailScreen(
                  // Truyền ID của item được bấm
                  subscriptionId: subscription.id,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: SubscriptionListItem(subscription: subscription),
        );
      },
    );
  }
}

// --- WIDGET CARD ĐÃ ĐƯỢC CẬP NHẬT: BỎ EXPANSION TILE ---
class SubscriptionListItem extends StatelessWidget {
  final Subscription subscription;

  const SubscriptionListItem({required this.subscription, super.key});

  String _formatDate(DateTime? date, {bool showTime = false}) {
    if (date == null) return 'N/A';
    final format = showTime ? DateFormat('dd/MM/yyyy HH:mm') : DateFormat('dd/MM/yyyy');
    return format.format(date);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green.shade600;
      case 'canceled':
        return Colors.red.shade600;
      case 'expired':
        return Colors.grey.shade600;
      default:
        return Colors.orange.shade600;
    }
  }

  Widget _buildDateColumn(BuildContext context, String label, DateTime date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatDate(date),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBillingPeriodBadge(String billingPeriodUnit) {
    final isYear = billingPeriodUnit.toLowerCase() == 'year';
    final Color color = isYear ? Colors.cyan.shade700 : Colors.amber.shade800;
    final String text = isYear ? 'YEARLY' : 'MONTHLY';
    final IconData icon = isYear ? Icons.diamond_outlined : Icons.calendar_month_outlined;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(subscription.subscriptionStatusName);
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final formattedAmount = currencyFormatter.format(subscription.amount);

    // Không cần Stack và _buildRenewalBadge nữa nếu muốn card đơn giản hơn
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 8,
              color: statusColor,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription.planDisplayName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          formattedAmount,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildBillingPeriodBadge(subscription.billingPeriodUnit),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Trạng thái: ${subscription.subscriptionStatusName}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDateColumn(context, 'Ngày bắt đầu', subscription.currentPeriodStart),
                        _buildDateColumn(context, 'Ngày kết thúc', subscription.currentPeriodEnd),
                      ],
                    ),
                    // --- THAY ĐỔI 3: Đã bỏ ExpansionTile (Xem chi tiết) ---
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}