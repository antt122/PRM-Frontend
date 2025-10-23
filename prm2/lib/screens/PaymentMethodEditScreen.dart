import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/PaymentMethodCreateModel.dart';
import '../models/PaymentMethodDetail.dart';
import '../providers/PaymentMethodFilter.dart';
import '../utils/app_colors.dart';

class PaymentMethodEditScreen extends ConsumerStatefulWidget {
  final PaymentMethodDetail initialData;
  const PaymentMethodEditScreen({super.key, required this.initialData});

  @override
  ConsumerState<PaymentMethodEditScreen> createState() => _PaymentMethodEditScreenState();
}

class _PaymentMethodEditScreenState extends ConsumerState<PaymentMethodEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _providerNameController;
  late TextEditingController _configController;
  late int _selectedType;
  late int _selectedStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Điền sẵn thông tin từ đối tượng được truyền vào
    _nameController = TextEditingController(text: widget.initialData.name);
    _descriptionController = TextEditingController(text: widget.initialData.description);
    _providerNameController = TextEditingController(text: widget.initialData.providerName);
    _configController = TextEditingController(text: widget.initialData.configuration);

    // Mapping từ typeName sang type (int)
    switch(widget.initialData.typeName.toLowerCase()) {
      case 'creditcard': _selectedType = 1; break;
      case 'cash': _selectedType = 2; break;
      case 'ewallet': _selectedType = 3; break;
      case 'banktransfer': _selectedType = 4; break;
      default: _selectedType = 1;
    }
    _selectedStatus = widget.initialData.status == 'Active' ? 1 : 0;
  }

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

      final updatedMethod = PaymentMethodCreateModel(
        name: _nameController.text,
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
        type: _selectedType,
        providerName: _providerNameController.text,
        configuration: _configController.text.isNotEmpty ? _configController.text : null,
        status: _selectedStatus,
      );

      final result = await ref.read(paymentMethodServiceProvider).updatePaymentMethod(
        id: widget.initialData.id,
        model: updatedMethod,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? (result.isSuccess ? '✅ Cập nhật thành công!' : '❌ Lỗi')),
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
        title: const Text('Chỉnh sửa Phương thức'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Tên phương thức *')),
              const SizedBox(height: 20),
              TextFormField(controller: _providerNameController, decoration: const InputDecoration(labelText: 'Tên nhà cung cấp *')),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                        value: _selectedType,
                        hint: const Text('Loại *'),
                        items: const [
                          // DropdownMenuItem(value: 1, child: Text('Bank Transfer')),
                          // DropdownMenuItem(value: 2, child: Text('E-Wallet')),
                          // DropdownMenuItem(value: 3, child: Text('Card')),
                          // DropdownMenuItem(value: 4, child: Text('Crypto')),
                          DropdownMenuItem(value: 1, child: Text('CreditCard ')),
                          DropdownMenuItem(value: 2, child: Text('Cash')),
                          DropdownMenuItem(value: 3, child: Text('EWallet ')),
                          DropdownMenuItem(value: 4, child: Text('BankTransfer ')),
                        ],
                        onChanged: (v) => setState(() => _selectedType = v!)),
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
                        onChanged: (v) => setState(() => _selectedStatus = v!)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Mô tả'), maxLines: 3),
              const SizedBox(height: 20),
              TextFormField(controller: _configController, decoration: const InputDecoration(labelText: 'Cấu hình (JSON)'), maxLines: 3),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading ? const CircularProgressIndicator() : const Text('Lưu thay đổi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
