import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/PaymentMethodCreateModel.dart';
import '../providers/PaymentMethodFilter.dart';
import '../utils/app_colors.dart';

class PaymentMethodCreateScreen extends ConsumerStatefulWidget {
  const PaymentMethodCreateScreen({super.key});

  @override
  ConsumerState<PaymentMethodCreateScreen> createState() => _PaymentMethodCreateScreenState();
}

class _PaymentMethodCreateScreenState extends ConsumerState<PaymentMethodCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _providerNameController = TextEditingController();
  final _configController = TextEditingController();
  int? _selectedType;
  int? _selectedStatus;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _providerNameController.dispose();
    _configController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final newMethod = PaymentMethodCreateModel(
        name: _nameController.text,
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
        type: _selectedType!,
        providerName: _providerNameController.text,
        configuration: _configController.text.isNotEmpty ? _configController.text : null,
        status: _selectedStatus!,
      );

      final result = await ref.read(paymentMethodServiceProvider).createPaymentMethod(newMethod);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? (result.isSuccess ? '✅ Tạo thành công!' : '❌ Lỗi không xác định')),
            backgroundColor: result.isSuccess ? Colors.green : kAdminErrorColor,
          ),
        );
        if (result.isSuccess) {
          Navigator.pop(context, true); // Quay về và báo hiệu thành công
        }
      }

      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm phương thức thanh toán'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Tên phương thức *'),
                  validator: (value) => (value == null || value.isEmpty) ? 'Tên không được để trống' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _providerNameController,
                  decoration: const InputDecoration(labelText: 'Tên nhà cung cấp *'),
                  validator: (value) => (value == null || value.isEmpty) ? 'Tên nhà cung cấp không được để trống' : null,
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedType,
                        hint: const Text('Loại *'),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('Bank Transfer')),
                          DropdownMenuItem(value: 2, child: Text('E-Wallet')),
                          DropdownMenuItem(value: 3, child: Text('Card')),
                          DropdownMenuItem(value: 4, child: Text('Crypto')),
                        ],
                        onChanged: (value) => setState(() => _selectedType = value),
                        validator: (value) => value == null ? 'Vui lòng chọn loại' : null,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedStatus,
                        hint: const Text('Trạng thái *'),
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('Active')),
                          DropdownMenuItem(value: 0, child: Text('Inactive')),
                        ],
                        onChanged: (value) => setState(() => _selectedStatus = value),
                        validator: (value) => value == null ? 'Vui lòng chọn trạng thái' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _configController,
                  decoration: const InputDecoration(labelText: 'Cấu hình (JSON)'),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Tạo mới'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
