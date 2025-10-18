// File: D:/healink/cms_an/PRM-Frontend/prm2/lib/screens/SubscriptionDetailScreen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/Subscription.dart';
import '../services/api_service.dart';
import 'CancelSubscriptionScreen.dart';
import 'UpdateSubscriptionScreen.dart';

class SubscriptionDetailScreen extends StatefulWidget {
  final String subscriptionId;

  const SubscriptionDetailScreen({
    super.key,
    required this.subscriptionId,
  });

  @override
  State<SubscriptionDetailScreen> createState() => _SubscriptionDetailScreenState();
}

class _SubscriptionDetailScreenState extends State<SubscriptionDetailScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;
  Subscription? _subscription;

  @override
  void initState() {
    super.initState();
    _fetchSubscriptionDetails();
  }

  Future<void> _fetchSubscriptionDetails() async {
    if (!_isLoading) {
      setState(() { _isLoading = true; });
    }
    try {
      final result = await _apiService.getSubscriptionById(widget.subscriptionId);
      if (mounted) {
        if (result.isSuccess && result.data != null) {
          setState(() {
            _subscription = result.data;
            _error = null;
          });
        } else {
          setState(() {
            _error = result.message ?? 'Không tìm thấy Subscription';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Lỗi kết nối: ${e.toString()}";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void onSubscriptionUpdated() {
    _fetchSubscriptionDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết Gói Đăng ký'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSubscriptionDetails,
        child: _buildResultView(),
      ),
    );
  }

  Widget _buildResultView() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Lỗi: $_error', style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
        ),
      );
    }
    if (_subscription != null) {
      return ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SubscriptionResultCard(
            subscription: _subscription!,
            onUpdate: onSubscriptionUpdated,
          ),
        ],
      );
    }
    return const Center(child: Text('Không có dữ liệu để hiển thị.'));
  }
}


class SubscriptionResultCard extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback onUpdate;

  const SubscriptionResultCard({
    required this.subscription,
    required this.onUpdate,
    super.key
  });

  void _navigateToUpdateScreen(BuildContext context) async {
    final bool? wasUpdated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateSubscriptionScreen(
          initialSubscription: subscription,
        ),
      ),
    );
    if (wasUpdated == true) {
      onUpdate();
    }
  }

  void _navigateToCancelScreen(BuildContext context) async {
    final bool? wasCanceled = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CancelSubscriptionScreen(
          subscription: subscription,
        ),
      ),
    );
    if (wasCanceled == true) {
      onUpdate();
    }
  }

  // --- CÁC HÀM HELPER ĐÃ ĐƯỢC ĐIỀN LẠI ĐẦY ĐỦ ---
  String _formatDate(DateTime? date, {bool showTime = false}) {
    if (date == null) return 'N/A';
    final format = showTime ? DateFormat('dd/MM/yyyy HH:mm') : DateFormat('dd/MM/yyyy');
    return format.format(date);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active': return Colors.green.shade600;
      case 'canceled': return Colors.red.shade600;
      case 'expired': return Colors.grey.shade600;
      case 'pastdue': return Colors.amber.shade700;
      case 'intrial': return Colors.blue.shade600;
      default: return Colors.orange.shade600;
    }
  }

  Widget _buildBillingPeriodBadge(String billingPeriodUnit) {
    final isYear = billingPeriodUnit.toLowerCase() == 'year';
    final Color color = isYear ? Colors.cyan.shade700 : Colors.amber.shade800;
    final String text = isYear ? 'YEARLY' : 'MONTHLY';
    final IconData icon = isYear ? Icons.diamond_outlined : Icons.savings_outlined;

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
          Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.bold, color: valueColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade500,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(subscription.subscriptionStatusName);
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final formattedAmount = currencyFormatter.format(subscription.amount);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subscription.planDisplayName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  formattedAmount,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                _buildBillingPeriodBadge(subscription.billingPeriodUnit),
              ],
            ),
            const Divider(height: 24),

            _buildSectionHeader('Thông tin ID'),
            _buildInfoRow(context, 'Subscription ID', subscription.id),
            _buildInfoRow(context, 'User Profile ID', subscription.userProfileId),
            _buildInfoRow(context, 'Subscription Plan ID', subscription.subscriptionPlanId),
            _buildInfoRow(context, 'Plan Name', subscription.planName),

            _buildSectionHeader('Thời hạn gói'),
            _buildInfoRow(context, 'Trạng thái', subscription.subscriptionStatusName, valueColor: statusColor),
            _buildInfoRow(context, 'Ngày bắt đầu', _formatDate(subscription.currentPeriodStart, showTime: true)),
            _buildInfoRow(context, 'Ngày kết thúc', _formatDate(subscription.currentPeriodEnd, showTime: true)),

            _buildSectionHeader('Gia hạn & Hủy'),
            _buildInfoRow(context, 'Hình thức gia hạn', subscription.renewalBehaviorName),
            _buildInfoRow(context, 'Hủy vào cuối kỳ', subscription.cancelAtPeriodEnd ? 'Có' : 'Không'),
            if(subscription.cancelAt != null)
              _buildInfoRow(context, 'Hủy vào ngày', _formatDate(subscription.cancelAt, showTime: true)),
            if(subscription.canceledAt != null)
              _buildInfoRow(context, 'Đã hủy vào', _formatDate(subscription.canceledAt, showTime: true), valueColor: Colors.red.shade600),

            _buildSectionHeader('Thông tin hệ thống'),
            _buildInfoRow(context, 'Ngày tạo', _formatDate(subscription.createdAt, showTime: true)),
            if(subscription.updatedAt != null)
              _buildInfoRow(context, 'Cập nhật lần cuối', _formatDate(subscription.updatedAt, showTime: true)),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToUpdateScreen(context),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Chỉnh sửa gói'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToCancelScreen(context),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Hủy gói'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.1),
                  foregroundColor: Colors.red.shade700,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.red.shade200),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}