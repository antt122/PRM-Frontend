import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/SubscriptionPlan.dart'; // Giả sử model này tồn tại
import '../models/UpdatePlanRequest.dart'; // Model bạn đã cung cấp
import '../services/SubscriptionPlanService.dart'; // Giả sử service này tồn tại

class UpdateSubscriptionPlanScreen extends StatefulWidget {
  final SubscriptionPlan initialPlan;

  const UpdateSubscriptionPlanScreen({super.key, required this.initialPlan});

  @override
  State<UpdateSubscriptionPlanScreen> createState() => _UpdateSubscriptionPlanScreenState();
}

class _UpdateSubscriptionPlanScreenState extends State<UpdateSubscriptionPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = SubscriptionPlanService();
  bool _isLoading = false;

  // Controllers cho TẤT CẢ các trường
  late TextEditingController _nameController;
  late TextEditingController _displayNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _featureConfigController;
  late TextEditingController _currencyController;
  late TextEditingController _billingPeriodCountController;
  late TextEditingController _amountController;
  late TextEditingController _trialDaysController;

  // --- THAY ĐỔI 1: Controller cho status không còn cần thiết nữa (nhưng vẫn giữ để code cũ không lỗi) ---
  late TextEditingController _statusController;
  // --- THAY ĐỔI 2: Thêm biến state mới cho Dropdown (kiểu int) ---
  int? _selectedStatus;

  // State cho trường Dropdown (billingPeriodUnit)
  late int _selectedBillingUnit;
// Bên ngoài hàm build(), trong class State
  int? _selectedStatus2;

  @override
  void initStatus() {
    super.initState();
    // Đặt giá trị mặc định là 1 (Active) khi widget khởi tạo
    _selectedStatus2 = 1;
  }
  
  @override
  void initState() {
    super.initState();
    // Khởi tạo tất cả controllers từ initialPlan
    _nameController = TextEditingController(text: widget.initialPlan.name);
    _displayNameController = TextEditingController(text: widget.initialPlan.displayName);
    _descriptionController = TextEditingController(text: widget.initialPlan.description);

    _featureConfigController = TextEditingController(text: widget.initialPlan.featureConfig ?? '');
    _currencyController = TextEditingController(text: widget.initialPlan.currency ?? 'VND');

    _billingPeriodCountController = TextEditingController(text: widget.initialPlan.billingPeriodCount.toString());
    _amountController = TextEditingController(text: widget.initialPlan.amount.toString());
    _trialDaysController = TextEditingController(text: widget.initialPlan.trialDays?.toString() ?? '0');

    // --- THAY ĐỔI 3: Khởi tạo biến _selectedStatus (int?) từ status (String) ---
    _statusController = TextEditingController(text: widget.initialPlan.status);
    _selectedStatus = int.tryParse(widget.initialPlan.status);
    // ----------------------------------------------------

    // Khởi tạo giá trị Dropdown
    _selectedBillingUnit = widget.initialPlan.billingPeriodUnit;
  }

  @override
  void dispose() {
    // Dispose tất cả controllers
    _nameController.dispose();
    _displayNameController.dispose();
    _descriptionController.dispose();
    _featureConfigController.dispose();
    _currencyController.dispose();
    _billingPeriodCountController.dispose();
    _amountController.dispose();
    _trialDaysController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; });

    final request = UpdatePlanRequest(
      name: _nameController.text.trim(),
      displayName: _displayNameController.text.trim(),
      description: _descriptionController.text.trim(),
      featureConfig: _featureConfigController.text.trim(),
      currency: _currencyController.text.trim(),

      billingPeriodCount: int.tryParse(_billingPeriodCountController.text.trim()),
      billingPeriodUnit: _selectedBillingUnit,
      amount: double.tryParse(_amountController.text.trim()),
      trialDays: int.tryParse(_trialDaysController.text.trim()),

      // --- THAY ĐỔI 4: Sử dụng biến _selectedStatus (kiểu int?) trực tiếp ---
      status: _selectedStatus,
    );

    final result = await _apiService.updateSubscriptionPlan(widget.initialPlan.id, request);

    if(mounted) {
      if(result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thành công!'), backgroundColor: Colors.green));
        Navigator.pop(context, true); // Trả về true để refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: ${result.message ?? "Không rõ"}'), backgroundColor: Colors.red));
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
            // ... (Các TextFormField khác giữ nguyên) ...

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Tên mã (Name)'),
              validator: (v) => (v == null || v.isEmpty) ? 'Không được để trống' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _displayNameController,
              decoration: const InputDecoration(labelText: 'Tên hiển thị (Display Name)'),
              validator: (v) => (v == null || v.isEmpty) ? 'Không được để trống' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Mô tả (Description)'),
              maxLines: 3,
              validator: (v) => (v == null || v.isEmpty) ? 'Không được để trống' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _featureConfigController,
              decoration: const InputDecoration(labelText: 'Cấu hình tính năng (JSON string)'),
              maxLines: 4,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _currencyController,
              decoration: const InputDecoration(labelText: 'Tiền tệ (Currency)'),
              validator: (v) => (v == null || v.isEmpty) ? 'Không được để trống' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Giá tiền (Amount)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
              validator: (v) => (v == null || v.isEmpty) ? 'Không được để trống' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _billingPeriodCountController,
              decoration: const InputDecoration(labelText: 'Số chu kỳ (Billing Period Count)'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) => (v == null || v.isEmpty) ? 'Không được để trống' : null,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<int>(
              value: _selectedBillingUnit,
              decoration: const InputDecoration(labelText: 'Đơn vị chu kỳ (Billing Period Unit)'),
              items: const [
                DropdownMenuItem(value: 1, child: Text('1: Tháng (Month)')),
                DropdownMenuItem(value: 2, child: Text('2: Năm (Year)')),
              ],
              onChanged: (value) => setState(() => _selectedBillingUnit = value ?? 1),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _trialDaysController,
              decoration: const InputDecoration(labelText: 'Số ngày dùng thử (Trial Days)'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) => (v == null || v.isEmpty) ? 'Không được để trống' : null,
            ),
            const SizedBox(height: 16),

            // --- THAY ĐỔI 5: Thay thế DropdownButtonFormField<String> bằng DropdownButtonFormField<int> ---
            DropdownButtonFormField<int>(
              // Sử dụng biến state int?
              value: _selectedStatus2,
              decoration: const InputDecoration(
                labelText: 'Trạng thái (Status)',
              ),
              items: const [
                DropdownMenuItem(
                  value: 1, // Giá trị là int
                  child: Text('1: Active (Hoạt động)'),
                ),
                DropdownMenuItem(
                  value: 0, // Giá trị là int
                  child: Text('0: Inactive (Không hoạt động)'),
                ),
              ],
              onChanged: (int? newValue) {
                // Cập nhật biến state int?
                setState(() {
                  _selectedStatus = newValue;
                  // (Tùy chọn) Cập nhật controller cũ nếu bạn vẫn cần
                  _statusController.text = newValue?.toString() ?? '';
                });
              },
              // Validator kiểm tra null
              validator: (v) => (v == null) ? 'Vui lòng chọn trạng thái' : null,
            ),
            const SizedBox(height: 32),

            // --- Submit Button ---
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)
              ),
              child: _isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                  : const Text('Lưu thay đổi'),
            )
          ],
        ),
      ),
    );
  }
}