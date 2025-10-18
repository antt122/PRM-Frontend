import 'package:flutter/material.dart';
import '../models/Subscription.dart';
import '../services/api_service.dart';

class CancelSubscriptionScreen extends StatefulWidget {
  final Subscription subscription;

  const CancelSubscriptionScreen({super.key, required this.subscription});

  @override
  State<CancelSubscriptionScreen> createState() => _CancelSubscriptionScreenState();
}

class _CancelSubscriptionScreenState extends State<CancelSubscriptionScreen> {
  final _apiService = ApiService();
  final _reasonController = TextEditingController();

  bool _cancelAtPeriodEnd = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _handleCancel() async {
    setState(() { _isLoading = true; });

    final result = await _apiService.cancelSubscription(
      subscriptionId: widget.subscription.id,
      cancelAtPeriodEnd: _cancelAtPeriodEnd,
      reason: _reasonController.text.trim(),
    );

    if (mounted) {
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? 'Yêu cầu hủy thành công!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${result.message ?? "Không rõ"}'), backgroundColor: Colors.red),
        );
      }
    }

    // Đặt setState ở ngoài `if (mounted)` để đảm bảo _isLoading luôn được cập nhật
    setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hủy Gói Đăng ký'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Bạn sắp thực hiện hủy gói:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            widget.subscription.planDisplayName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Divider(height: 32),

          TextField(
            controller: _reasonController,
            decoration: const InputDecoration(
              labelText: 'Lý do hủy (không bắt buộc)',
              border: OutlineInputBorder(),
              hintText: 'Ví dụ: Người dùng yêu cầu',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),

          SwitchListTile(
            title: const Text('Hủy vào cuối kỳ hạn'),
            subtitle: Text(_cancelAtPeriodEnd
                ? 'Gói sẽ bị hủy khi hết hạn. Người dùng vẫn có thể sử dụng đến hết kỳ.'
                : 'Hủy ngay lập tức. Người dùng sẽ mất quyền truy cập ngay.'),
            value: _cancelAtPeriodEnd,
            onChanged: (newValue) {
              setState(() {
                _cancelAtPeriodEnd = newValue;
              });
            },
            activeColor: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 32),

          // --- THAY ĐỔI TẠI ĐÂY: Chuyển sang ElevatedButton và dùng child có điều kiện ---
          ElevatedButton(
            onPressed: _isLoading ? null : _handleCancel,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            child: _isLoading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
                : const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cancel_outlined, size: 20),
                SizedBox(width: 8),
                Text('Xác nhận Hủy'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}