import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/api_result.dart';
import '../models/subscription_plan.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart'; // Dùng màu sắc chung

class CheckoutScreen extends StatefulWidget {
  final SubscriptionPlan plan;

  const CheckoutScreen({super.key, required this.plan});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late Future<ApiResult<UserProfile>> _userProfileFuture;

  @override
  void initState() {
    super.initState();
    _userProfileFuture = ApiService.getUserProfile();
  }

  String _formatPrice(double amount, String currency) {
    final formatCurrency = NumberFormat.decimalPattern('vi_VN');
    return '${formatCurrency.format(amount)} $currency';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Thanh toán', style: TextStyle(color: kPrimaryTextColor)),
        backgroundColor: kBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: kPrimaryTextColor),
      ),
      body: FutureBuilder<ApiResult<UserProfile>>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kPrimaryTextColor));
          }
          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.isSuccess) {
            return Center(child: Text('Lỗi: ${snapshot.data?.message ?? "Không thể tải thông tin người dùng."}'));
          }

          final user = snapshot.data!.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CỘT GIAO HÀNG
                Expanded(child: _buildShippingDetails(user)),
                const SizedBox(width: 24),
                // CỘT THANH TOÁN
                Expanded(child: _buildPaymentMethods()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildShippingDetails(UserProfile user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Giao hàng tận nơi', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kPrimaryTextColor)),
        const SizedBox(height: 24),
        _buildInfoRow('Họ và tên:', user.fullName),
        _buildInfoRow('Email:', user.email),
        _buildInfoRow('Số điện thoại:', user.phoneNumber),
        _buildInfoRow('Địa chỉ nhà:', user.address),
        _buildInfoRow('Lưu ý cho shop:', 'Đóng gói cẩn thận!'),
        const Divider(height: 32),
        _buildInfoRow('Tổng tiền thanh toán:', _formatPrice(widget.plan.amount, widget.plan.currency), isBold: true),
        const SizedBox(height: 24),
        _buildStyledButton('Thanh toán'),
      ],
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Thanh toán online', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kPrimaryTextColor)),
        const SizedBox(height: 24),
        // Các phương thức thanh toán có thể là các widget riêng...
        _buildPaymentOption('Chuyển khoản', 'Momo, VNPay...'),
        const SizedBox(height: 16),
        _buildStyledButton('Thanh toán'),
        const SizedBox(height: 24),
        _buildPaymentOption('Thẻ tín dụng / ghi nợ', 'Visa, Master...'),
        const SizedBox(height: 16),
        _buildStyledButton('Thanh toán'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: kPrimaryTextColor,
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: kInputBorderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_box_outline_blank, color: kPrimaryTextColor),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: kPrimaryTextColor)),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStyledButton(String text) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryTextColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(text),
      ),
    );
  }
}
