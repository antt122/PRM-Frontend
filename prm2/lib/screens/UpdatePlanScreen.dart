import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/SubscriptionPlan.dart';
import '../models/UpdatePlanRequest.dart';
import '../services/api_service.dart';

class UpdateSubscriptionPlanScreen extends StatefulWidget {
  final SubscriptionPlan initialPlan;

  const UpdateSubscriptionPlanScreen({super.key, required this.initialPlan});

  @override
  State<UpdateSubscriptionPlanScreen> createState() => _UpdateSubscriptionPlanScreenState();
}

class _UpdateSubscriptionPlanScreenState extends State<UpdateSubscriptionPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  bool _isLoading = false;

  // Controllers và state variables
  late TextEditingController _nameController;
  late TextEditingController _displayNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _trialDaysController;
  late int _selectedBillingUnit;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    // Khởi tạo giá trị cho form từ Gói Plan được truyền vào
    _nameController = TextEditingController(text: widget.initialPlan.name);
    _displayNameController = TextEditingController(text: widget.initialPlan.displayName);
    _descriptionController = TextEditingController(text: widget.initialPlan.description);
    _amountController = TextEditingController(text: widget.initialPlan.amount.toString());
    _trialDaysController = TextEditingController(text: widget.initialPlan.trialDays?.toString() ?? '0');
    _selectedBillingUnit = widget.initialPlan.billingPeriodUnit;
    _isActive = widget.initialPlan.isActive;
  }

  // ... (dispose controllers)

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; });

    final request = UpdatePlanRequest(
      displayName: _displayNameController.text.trim(),
      description: _descriptionController.text.trim(),
      amount: double.tryParse(_amountController.text),
      trialDays: int.tryParse(_trialDaysController.text),
      billingPeriodUnit: _selectedBillingUnit,
      status: _isActive ? 1 : 2, // 1: Active, 2: Inactive
      // Thêm các trường khác nếu bạn cho phép chỉnh sửa
    );

    final result = await _apiService.updateSubscriptionPlan(widget.initialPlan.id, request);

    if(mounted) {
      if(result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thành công!'), backgroundColor: Colors.green));
        Navigator.pop(context, true); // Trả về true để refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: ${result.message}'), backgroundColor: Colors.red));
      }
    }
    setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chỉnh sửa: ${widget.initialPlan.displayName}'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _displayNameController,
              decoration: const InputDecoration(labelText: 'Tên hiển thị'),
              validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Mô tả'),
              maxLines: 3,
              validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Giá tiền'),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _trialDaysController,
              decoration: const InputDecoration(labelText: 'Số ngày dùng thử'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Trạng thái Kích hoạt'),
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              child: _isLoading ? const CircularProgressIndicator() : const Text('Lưu thay đổi'),
            )
          ],
        ),
      ),
    );
  }
}