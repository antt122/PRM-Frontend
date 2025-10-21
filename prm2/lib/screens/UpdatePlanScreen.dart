import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/SubscriptionPlan.dart'; // Giả sử model này tồn tại
import '../models/UpdatePlanRequest.dart'; // Model bạn đã cung cấp
import '../services/api_service.dart'; // Giả sử service này tồn tại

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

  // Controllers cho TẤT CẢ các trường
  late TextEditingController _nameController;
  late TextEditingController _displayNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _featureConfigController;
  late TextEditingController _currencyController;
  late TextEditingController _billingPeriodCountController;
  late TextEditingController _amountController;
  late TextEditingController _trialDaysController;
  late TextEditingController _statusController;

  // State cho trường Dropdown (billingPeriodUnit)
  late int _selectedBillingUnit;

  @override
  void initState() {
    super.initState();
    // Khởi tạo tất cả controllers từ initialPlan
    _nameController = TextEditingController(text: widget.initialPlan.name);
    _displayNameController = TextEditingController(text: widget.initialPlan.displayName);
    _descriptionController = TextEditingController(text: widget.initialPlan.description);

    // Giả sử initialPlan có các trường này, nếu không có, bạn cần thêm ?? ''
    _featureConfigController = TextEditingController(text: widget.initialPlan.featureConfig ?? '');
    _currencyController = TextEditingController(text: widget.initialPlan.currency ?? 'VND');

    // Chuyển đổi số sang String cho Controllers
    _billingPeriodCountController = TextEditingController(text: widget.initialPlan.billingPeriodCount.toString());
    _amountController = TextEditingController(text: widget.initialPlan.amount.toString());
    _trialDaysController = TextEditingController(text: widget.initialPlan.trialDays?.toString() ?? '0');

    // --- THAY ĐỔI: SỬ DỤNG 'status' (STRING) TỪ MODEL MỚI ---
    // Model 'SubscriptionPlan' (widget.initialPlan) đã được cập nhật
    // để sử dụng 'status' (kiểu String) thay vì 'isActive' (kiểu bool).
    _statusController = TextEditingController(text: widget.initialPlan.status);
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

    // Tạo request object, parse các giá trị từ String sang kiểu dữ liệu đúng
    final request = UpdatePlanRequest(
      name: _nameController.text.trim(),
      displayName: _displayNameController.text.trim(),
      description: _descriptionController.text.trim(),
      featureConfig: _featureConfigController.text.trim(),
      currency: _currencyController.text.trim(),

      // Chuyển từ Text sang int?
      billingPeriodCount: int.tryParse(_billingPeriodCountController.text.trim()),
      // Lấy từ state
      billingPeriodUnit: _selectedBillingUnit,
      // Chuyển từ Text sang double?
      amount: double.tryParse(_amountController.text.trim()),
      // Chuyển từ Text sang int?
      trialDays: int.tryParse(_trialDaysController.text.trim()),

      // --- THAY ĐỔI: API có thể vẫn mong đợi INT cho 'status' ---
      // (Nếu API của bạn mong đợi String, hãy đổi thành: _statusController.text.trim())
      status: int.tryParse(_statusController.text.trim()),
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
    // (Lưu ý: Yêu cầu về màu sắc (xanh, đỏ, vàng) không áp dụng cho
    // màn hình Form này, nó chỉ áp dụng cho màn hình hiển thị/danh sách)
    return Scaffold(
      appBar: AppBar(
        title: Text('Chỉnh sửa: ${widget.initialPlan.displayName}'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // --- name (String) ---
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Tên mã (Name)'),
              validator: (v) => (v == null || v.isEmpty) ? 'Không được để trống' : null,
            ),
            const SizedBox(height: 16),

            // --- displayName (String) ---
            TextFormField(
              controller: _displayNameController,
              decoration: const InputDecoration(labelText: 'Tên hiển thị (Display Name)'),
              validator: (v) => (v == null || v.isEmpty) ? 'Không được để trống' : null,
            ),
            const SizedBox(height: 16),

            // --- description (String) ---
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Mô tả (Description)'),
              maxLines: 3,
              validator: (v) => (v == null || v.isEmpty) ? 'Không được để trống' : null,
            ),
            const SizedBox(height: 16),

            // --- featureConfig (String) ---
            TextFormField(
              controller: _featureConfigController,
              decoration: const InputDecoration(labelText: 'Cấu hình tính năng (JSON string)'),
              maxLines: 4,
            ),
            const SizedBox(height: 16),

            // --- currency (String) ---
            TextFormField(
              controller: _currencyController,
              decoration: const InputDecoration(labelText: 'Tiền tệ (Currency)'),
              validator: (v) => (v == null || v.isEmpty) ? 'Không được để trống' : null,
            ),
            const SizedBox(height: 16),

            // --- amount (double) ---
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Giá tiền (Amount)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
              validator: (v) => (v == null || v.isEmpty) ? 'Không được để trống' : null,
            ),
            const SizedBox(height: 16),

            // --- billingPeriodCount (int) ---
            TextFormField(
              controller: _billingPeriodCountController,
              decoration: const InputDecoration(labelText: 'Số chu kỳ (Billing Period Count)'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) => (v == null || v.isEmpty) ? 'Không được để trống' : null,
            ),
            const SizedBox(height: 16),

            // --- billingPeriodUnit (int) ---
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

            // --- trialDays (int) ---
            TextFormField(
              controller: _trialDaysController,
              decoration: const InputDecoration(labelText: 'Số ngày dùng thử (Trial Days)'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) => (v == null || v.isEmpty) ? 'Không được để trống' : null,
            ),
            const SizedBox(height: 16),

            // --- status (int/String) ---
            TextFormField(
              controller: _statusController,
              decoration: const InputDecoration(
                  labelText: 'Trạng thái (Status)',
                  hintText: 'active, inactive, pending...' // Gợi ý bằng chữ
              ),
              // keyboardType: TextInputType.number, // Xóa dòng này
              // inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Xóa dòng này
              validator: (v) => (v == null || v.isEmpty) ? 'Không được để trống' : null,
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