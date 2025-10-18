// File: lib/screens/UpdateSubscriptionScreen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/Subscription.dart';
import '../models/UpdateSubscriptionRequest.dart';
import '../services/api_service.dart';

class UpdateSubscriptionScreen extends StatefulWidget {
  final Subscription initialSubscription;

  const UpdateSubscriptionScreen({
    super.key,
    required this.initialSubscription,
  });

  @override
  State<UpdateSubscriptionScreen> createState() =>
      _UpdateSubscriptionScreenState();
}

class _UpdateSubscriptionScreenState extends State<UpdateSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  // Controllers và state cho các field
  late int _selectedStatus;
  late int _selectedRenewal;
  late bool _cancelAtPeriodEnd;
  late DateTime _currentPeriodEnd;
  final TextEditingController _dateController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Khởi tạo giá trị từ subscription ban đầu
    _selectedStatus = widget.initialSubscription.subscriptionStatus;
    _selectedRenewal = widget.initialSubscription.renewalBehavior;
    _cancelAtPeriodEnd = widget.initialSubscription.cancelAtPeriodEnd;
    _currentPeriodEnd = widget.initialSubscription.currentPeriodEnd;
    _dateController.text = DateFormat('dd/MM/yyyy').format(_currentPeriodEnd);
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) {
      return; // Không gửi nếu form không hợp lệ
    }

    setState(() { _isLoading = true; });

    final request = UpdateSubscriptionRequest(
      subscriptionStatus: _selectedStatus,
      renewalBehavior: _selectedRenewal,
      cancelAtPeriodEnd: _cancelAtPeriodEnd,
      currentPeriodEnd: _currentPeriodEnd.toIso8601String(),
    );

    final result = await _apiService.updateSubscription(
      widget.initialSubscription.id,
      request,
    );

    setState(() { _isLoading = false; });

    if (mounted) {
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        // Trả về true để màn hình chi tiết biết cần tải lại dữ liệu
        Navigator.of(context).pop(true);
      } else {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Cập nhật thất bại'),
            content: Text(result.message ?? 'Đã có lỗi xảy ra.'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _currentPeriodEnd,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _currentPeriodEnd) {
      setState(() {
        _currentPeriodEnd = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cập nhật Gói Đăng ký'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dropdown cho Subscription Status
              DropdownButtonFormField<int>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Trạng thái Gói', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('InTrial')),
                  DropdownMenuItem(value: 2, child: Text('Active')),
                  DropdownMenuItem(value: 3, child: Text('PastDue')),
                  DropdownMenuItem(value: 4, child: Text('Canceled')),
                  DropdownMenuItem(value: 5, child: Text('Paused')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() { _selectedStatus = value; });
                },
              ),
              const SizedBox(height: 20),

              // Dropdown cho Renewal Behavior
              DropdownButtonFormField<int>(
                value: _selectedRenewal,
                decoration: const InputDecoration(labelText: 'Hình thức gia hạn', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Tự động gia hạn (AutoRenew)')),
                  DropdownMenuItem(value: 2, child: Text('Thủ công (Manual)')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() { _selectedRenewal = value; });
                },
              ),
              const SizedBox(height: 20),

              // Switch cho Cancel at Period End
              SwitchListTile(
                title: const Text('Hủy vào cuối kỳ'),
                value: _cancelAtPeriodEnd,
                onChanged: (value) {
                  setState(() { _cancelAtPeriodEnd = value; });
                },
                secondary: Icon(_cancelAtPeriodEnd ? Icons.cancel_schedule_send : Icons.check_circle_outline),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 20),

              // Chọn ngày kết thúc kỳ
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Ngày kết thúc kỳ hiện tại',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => _selectDate(context),
              ),

              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitUpdate,
                icon: _isLoading ? const SizedBox.shrink() : const Icon(Icons.save_alt_outlined),
                label: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('LƯU THAY ĐỔI'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
