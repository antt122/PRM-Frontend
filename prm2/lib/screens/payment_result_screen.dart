import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import '../utils/app_colors.dart';
import '../utils/app_fonts.dart';

class PaymentResultScreen extends StatefulWidget {
  final Map<String, String>? queryParams;

  const PaymentResultScreen({super.key, this.queryParams});

  @override
  State<PaymentResultScreen> createState() => _PaymentResultScreenState();
}

class _PaymentResultScreenState extends State<PaymentResultScreen> {
  @override
  void initState() {
    super.initState();
    // Parse query parameters from deep link
    _parsePaymentResult();
  }

  void _parsePaymentResult() {
    if (widget.queryParams != null) {
      print('🔍 Payment result params: ${widget.queryParams}');
    } else {
      print('❌ No query params provided to PaymentResultScreen');
    }
  }

  String _formatDateTime(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
      return DateFormat('dd/MM/yyyy HH:mm:ss').format(date);
    } catch (e) {
      return '';
    }
  }

  String _formatAmount(String? amount) {
    if (amount == null) return '';
    try {
      final amountValue = int.parse(amount);
      return NumberFormat('#,###').format(amountValue);
    } catch (e) {
      return amount;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Parse payment result from query params
    final resultCode = widget.queryParams?['resultCode'] ?? '';
    final orderId = widget.queryParams?['orderId'];
    final transId = widget.queryParams?['transId'];
    final amount = widget.queryParams?['amount'];
    final message = widget.queryParams?['message'];
    final responseTime = widget.queryParams?['responseTime'];

    final isSuccess = resultCode == '0';

    return Scaffold(
      backgroundColor: kBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kGlassBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kGlassBorder, width: 0.5),
          ),
          child: IconButton(
            icon: const Icon(Icons.close, color: kPrimaryTextColor),
            onPressed: () {
              // Navigate to home screen
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/', (route) => false);
            },
          ),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: kGlassBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kGlassBorder, width: 0.5),
          ),
          child: Text(
            'Kết quả thanh toán',
            style: AppFonts.title2.copyWith(
              color: kPrimaryTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kBackgroundColor, kSurfaceColor],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: kGlassBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kGlassBorder, width: 0.5),
                  boxShadow: [
                    BoxShadow(
                      color: kGlassShadow,
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Icon & Title Section
                      Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: isSuccess
                                    ? [
                                        Colors.green.shade400,
                                        Colors.green.shade600,
                                      ]
                                    : [
                                        Colors.red.shade400,
                                        Colors.red.shade600,
                                      ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (isSuccess ? Colors.green : Colors.red)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              isSuccess ? Icons.check : Icons.close,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            isSuccess
                                ? 'Thanh toán thành công!'
                                : 'Thanh toán thất bại',
                            style: AppFonts.title1.copyWith(
                              color: isSuccess
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isSuccess
                                ? 'Cảm ơn bạn đã đăng ký gói Premium. Bạn đã có thể sử dụng đầy đủ các tính năng của Healink.'
                                : message ??
                                      'Giao dịch không thành công. Vui lòng thử lại sau.',
                            style: AppFonts.body.copyWith(
                              color: kSecondaryTextColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Transaction Details
                      if (orderId != null || transId != null || amount != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  color: kAccentColor,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Chi tiết giao dịch',
                                  style: AppFonts.title3.copyWith(
                                    color: kPrimaryTextColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (orderId != null)
                              _buildDetailRow('Mã đơn hàng', orderId),
                            if (transId != null)
                              _buildDetailRow('Mã giao dịch MoMo', transId),
                            if (amount != null)
                              _buildDetailRow(
                                'Số tiền thanh toán',
                                '${_formatAmount(amount)}đ',
                                valueColor: Colors.green.shade700,
                                valueStyle: AppFonts.title2.copyWith(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            if (responseTime != null)
                              _buildDetailRow(
                                'Thời gian giao dịch',
                                _formatDateTime(responseTime),
                              ),
                          ],
                        ),

                      const SizedBox(height: 32),

                      // Action Buttons
                      Column(
                        children: [
                          if (isSuccess) ...[
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Navigate to search screen
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/search',
                                    (route) => false,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kAccentColor,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Khám phá Podcast',
                                  style: AppFonts.title3.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  // Navigate to my subscription screen
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/my-subscription',
                                    (route) => false,
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: kAccentColor,
                                    width: 2,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Xem gói cước của tôi',
                                  style: AppFonts.title3.copyWith(
                                    color: kAccentColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Navigate back to subscription screen
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kAccentColor,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Thử lại',
                                  style: AppFonts.title3.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  // Navigate to home screen
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/',
                                    (route) => false,
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: kAccentColor,
                                    width: 2,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Về trang chủ',
                                  style: AppFonts.title3.copyWith(
                                    color: kAccentColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Support Link
                      Text(
                        'Cần hỗ trợ? Liên hệ chúng tôi',
                        style: AppFonts.caption1.copyWith(
                          color: kSecondaryTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // Debug: Test deep link button
                      if (widget.queryParams == null ||
                          widget.queryParams!.isEmpty)
                        ElevatedButton(
                          onPressed: () {
                            // Test with sample payment result data
                            final testParams = {
                              'resultCode': '0',
                              'orderId': 'test-order-123',
                              'transId': 'test-trans-456',
                              'amount': '50000',
                              'message': 'Success',
                              'responseTime': DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString(),
                            };

                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => PaymentResultScreen(
                                  queryParams: testParams,
                                ),
                              ),
                            );
                          },
                          child: const Text('Test Payment Result'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color? valueColor,
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppFonts.caption1.copyWith(color: kSecondaryTextColor),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style:
                  valueStyle ??
                  AppFonts.body.copyWith(
                    color: valueColor ?? kPrimaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
