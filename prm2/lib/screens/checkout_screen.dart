
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prm2/models/payment_method.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/api_result.dart';
import '../models/subscription_plan.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';

class CheckoutScreen extends StatefulWidget {
  final SubscriptionPlan plan;

  const CheckoutScreen({super.key, required this.plan});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late Future<ApiResult<List<PaymentMethod>>> _paymentMethodsFuture;
  String? _selectedPaymentMethodId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _paymentMethodsFuture = ApiService.getPaymentMethods();
  }

  String _formatPrice(double amount, String currency) {
    final formatCurrency = NumberFormat.decimalPattern('vi_VN');
    return '${formatCurrency.format(amount)} $currency';
  }

  Future<void> _handlePayment() async {
    if (_selectedPaymentMethodId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn một phương thức thanh toán.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await ApiService.registerSubscription(
      planId: widget.plan.id,
      paymentMethodId: _selectedPaymentMethodId!,
    );

    setState(() {
      _isLoading = false;
    });

    if (result.isSuccess && result.data != null) {
      final url = Uri.parse(result.data!.paymentUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể mở link thanh toán: ${result.data!.paymentUrl}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${result.message ?? "Không thể tạo thanh toán."}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Xác nhận đăng ký', style: TextStyle(color: kPrimaryTextColor)),
        backgroundColor: kBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: kPrimaryTextColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPlanSummary(),
            const SizedBox(height: 32),
            const Text(
              'Chọn phương thức thanh toán',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryTextColor),
            ),
            const SizedBox(height: 16),
            _buildPaymentMethodsList(),
          ],
        ),
      ),
      bottomNavigationBar: _buildConfirmButton(),
    );
  }

  Widget _buildPlanSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.plan.displayName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kPrimaryTextColor),
          ),
          const SizedBox(height: 8),
          Text(
            widget.plan.description,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          ),
          const Divider(height: 32, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng cộng', style: TextStyle(fontSize: 16, color: kPrimaryTextColor)),
              Text(
                _formatPrice(widget.plan.amount, widget.plan.currency),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kAccentColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsList() {
    return FutureBuilder<ApiResult<List<PaymentMethod>>>(
      future: _paymentMethodsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: kPrimaryTextColor));
        }
        if (!snapshot.hasData || snapshot.data?.data == null || !snapshot.data!.isSuccess) {
          return Center(child: Text('Lỗi tải phương thức thanh toán: ${snapshot.data?.message ?? ""}'));
        }

        // SỬA LỖI Ở ĐÂY: Lọc danh sách để chỉ giữ lại các phương thức 'Active'
        final allMethods = snapshot.data!.data!;
        final activeMethods = allMethods.where((method) => method.status == 'Active').toList();

        if (activeMethods.isEmpty) {
          return const Center(child: Text('Không có phương thức thanh toán nào hoạt động.'));
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activeMethods.length, // Dùng danh sách đã lọc
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final method = activeMethods[index]; // Dùng danh sách đã lọc
            return RadioListTile<String>(
              title: Text(method.name, style: const TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text(method.description),
              value: method.id,
              groupValue: _selectedPaymentMethodId,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethodId = value;
                });
              },
              activeColor: kAccentColor,
              secondary: _getProviderIcon(method.providerName),
              controlAffinity: ListTileControlAffinity.trailing,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              tileColor: _selectedPaymentMethodId == method.id ? kAccentColor.withOpacity(0.1) : Colors.white,
            );
          },
        );
      },
    );
  }

  Widget _getProviderIcon(String providerName) {
    // Có thể mở rộng để hiển thị logo thật
    IconData iconData;
    switch (providerName.toLowerCase()) {
      case 'momo':
        iconData = Icons.payment; // Thay bằng logo Momo
        break;
      case 'vnpay':
        iconData = Icons.account_balance_wallet; // Thay bằng logo VNPay
        break;
      default:
        iconData = Icons.credit_card;
    }
    return Icon(iconData, color: kPrimaryTextColor, size: 40);
  }

  Widget _buildConfirmButton() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handlePayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: kAccentColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        child: _isLoading
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
            : const Text('Thanh toán'),
      ),
    );
  }
}
