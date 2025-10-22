import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/CreatePlanRequest.dart';
import '../services/SubscriptionPlanService.dart';

class CreateSubscriptionScreen extends StatefulWidget {
  const CreateSubscriptionScreen({super.key});

  @override
  State<CreateSubscriptionScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends State<CreateSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = SubscriptionPlanService();
  bool _isLoading = false;

  // Controllers cho các trường
  final _nameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _trialDaysController = TextEditingController(text: '0');
  final _billingPeriodCountController = TextEditingController(text: '1');

  // State cho các dropdown
  int _selectedBillingUnit = 1; // 1: Month
  int _selectedStatus = 1; // 1: Active
  String _selectedCurrency = 'VND';

  @override
  void dispose() {
    _nameController.dispose();
    _displayNameController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _trialDaysController.dispose();
    _billingPeriodCountController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() { _isLoading = true; });

    final request = CreatePlanRequest(
      name: _nameController.text.trim(),
      displayName: _displayNameController.text.trim(),
      description: _descriptionController.text.trim(),
      amount: double.tryParse(_amountController.text) ?? 0.0,
      trialDays: int.tryParse(_trialDaysController.text) ?? 0,
      billingPeriodCount: int.tryParse(_billingPeriodCountController.text) ?? 1,
      billingPeriodUnit: _selectedBillingUnit,
      status: _selectedStatus,
      currency: _selectedCurrency,
    );

    final result = await _apiService.createSubscriptionPlan(request);

    if (mounted) {
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo gói plan thành công!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Trả về true để báo màn hình trước refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${result.message ?? "Không rõ"}'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo Gói Plan Mới'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Tên mã (vd: basic, premium)'),
              validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập tên mã' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _displayNameController,
              decoration: const InputDecoration(labelText: 'Tên hiển thị (vd: Gói Cơ bản)'),
              validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập tên hiển thị' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Mô tả'),
              maxLines: 3,
              validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập mô tả' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Giá tiền'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
              validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập giá tiền' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedBillingUnit,
              decoration: const InputDecoration(labelText: 'Chu kỳ thanh toán'),
              items: const [
                DropdownMenuItem(value: 1, child: Text('Tháng (Month)')),
                DropdownMenuItem(value: 2, child: Text('Năm (Year)')),
              ],
              onChanged: (value) => setState(() => _selectedBillingUnit = value ?? 1),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _trialDaysController,
              decoration: const InputDecoration(labelText: 'Số ngày dùng thử'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập số ngày' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedStatus,
              decoration: const InputDecoration(labelText: 'Trạng thái'),
              items: const [
                DropdownMenuItem(value: 1, child: Text('Hoạt động (Active)')),
                DropdownMenuItem(value: 2, child: Text('Không hoạt động (Inactive)')),
              ],
              onChanged: (value) => setState(() => _selectedStatus = value ?? 1),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Tạo Gói Plan'),
            )
          ],
        ),
      ),
    );
  }
}