import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import '../models/payment_method.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/api_result.dart';
import '../models/subscription_plan.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_fonts.dart';

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

  /// ✅ Clean MoMo URL to extract valid HTTPS URL for web browser
  String _cleanMomoUrl(String url) {
    try {
      print('🔍 Original URL: $url');

      // Check if URL contains both momo:// and https://
      if (url.contains('momo://') && url.contains('https://')) {
        // Extract the HTTPS part - find the first occurrence of https://
        final httpsIndex = url.indexOf('https://');
        if (httpsIndex != -1) {
          final httpsUrl = url.substring(httpsIndex);
          print('✅ Extracted HTTPS URL: $httpsUrl');

          // ✅ Additional validation: ensure it's a proper URL
          try {
            final uri = Uri.parse(httpsUrl);
            if (uri.scheme == 'https' && uri.host.isNotEmpty) {
              print('✅ Valid HTTPS URL parsed successfully');
              return httpsUrl;
            }
          } catch (e) {
            print('❌ Invalid HTTPS URL format: $e');
          }
        }
      }

      // ✅ Handle case where URL is malformed (momo://...https://...)
      if (url.startsWith('momo://') && url.contains('https://')) {
        // Find the first https:// after momo://
        final httpsIndex = url.indexOf('https://');
        if (httpsIndex != -1) {
          final httpsUrl = url.substring(httpsIndex);
          print('✅ Extracted HTTPS from malformed URL: $httpsUrl');

          try {
            final uri = Uri.parse(httpsUrl);
            if (uri.scheme == 'https' && uri.host.isNotEmpty) {
              print('✅ Valid HTTPS URL from malformed URL');
              return httpsUrl;
            }
          } catch (e) {
            print('❌ Invalid HTTPS URL from malformed URL: $e');
          }
        }
      }

      // If it's a pure momo:// URL, we can't use it in web browser
      if (url.startsWith('momo://')) {
        print('❌ Pure momo:// URL detected, cannot use in web browser');
        return '';
      }

      // If it's already a valid HTTPS URL, return as is
      if (url.startsWith('https://')) {
        print('✅ Valid HTTPS URL: $url');
        return url;
      }

      print('❌ Unknown URL format: $url');
      return '';
    } catch (e) {
      print('❌ Error cleaning URL: $e');
      return '';
    }
  }

  /// ✅ Open payment URL in custom WebView with momo:// scheme handling
  Future<void> _openPaymentInWebView(String paymentUrl) async {
    print('🌐 Opening payment in custom WebView: $paymentUrl');

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _PaymentWebView(
          paymentUrl: paymentUrl,
          onPaymentComplete: () {
            // Handle payment completion
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thanh toán đã hoàn thành!'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handlePayment() async {
    if (_selectedPaymentMethodId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn một phương thức thanh toán.'),
        ),
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
      final paymentUrl = result.data!.paymentUrl;
      final appLink =
          result.data!.appLink; // ✅ MoMo DeepLinkWebInApp for in-app browser
      final redirectUrl = result.data!.redirectUrl; // ✅ Custom redirect URL

      print('🔗 Payment URL: $paymentUrl');
      print('📱 App Link: $appLink');
      print('🔄 Redirect URL: $redirectUrl');

      try {
        // ✅ PRIORITY: Try AppLink first (MoMo DeepLinkWebInApp for in-app browser)
        if (appLink != null && appLink.isNotEmpty) {
          // ✅ Clean and validate AppLink URL
          String cleanAppLink = _cleanMomoUrl(appLink);
          print('🧹 Cleaned AppLink: $cleanAppLink');

          if (cleanAppLink.isNotEmpty) {
            print('🚀 Attempting to launch cleaned AppLink: $cleanAppLink');
            final appUrl = Uri.parse(cleanAppLink);

            // ✅ Additional validation before launching
            if (appUrl.scheme == 'https' && appUrl.host.isNotEmpty) {
              if (await canLaunchUrl(appUrl)) {
                final launched = await launchUrl(
                  appUrl,
                  mode: LaunchMode.inAppWebView, // ✅ Force in-app browser
                );
                print('✅ Launched AppLink in web view: $launched');
                if (launched) return; // Success, exit early
              } else {
                print('❌ Cannot launch cleaned AppLink: $cleanAppLink');
              }
            } else {
              print(
                '❌ Cleaned AppLink is not a valid HTTPS URL: $cleanAppLink',
              );
            }
          } else {
            print('❌ AppLink cleaning failed, falling back to PaymentUrl');
          }
        } else {
          print('❌ AppLink is null or empty, falling back to PaymentUrl');
        }

        // ✅ FALLBACK: Use regular PaymentUrl with in-app browser
        print('🔄 Falling back to PaymentUrl: $paymentUrl');

        // ✅ Validate PaymentUrl before parsing
        if (!paymentUrl.startsWith('https://')) {
          print('❌ PaymentUrl is not HTTPS: $paymentUrl');
          throw Exception('Invalid PaymentUrl format');
        }

        print('✅ PaymentUrl validation passed: $paymentUrl');
        final url = Uri.parse(paymentUrl);
        print('✅ Parsed URL - Scheme: ${url.scheme}, Host: ${url.host}');
        // ✅ PRIORITY: Custom WebView with momo:// scheme handling
        print('🌐 Opening payment in custom WebView with scheme handling');
        await _openPaymentInWebView(paymentUrl);
        return; // Success, exit early
      } catch (e) {
        print('❌ Error launching payment URL: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Không thể mở link thanh toán. Vui lòng copy link này: $paymentUrl',
            ),
            duration: const Duration(seconds: 10),
            action: SnackBarAction(
              label: 'Copy',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: paymentUrl));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Link đã được copy vào clipboard'),
                  ),
                );
              },
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lỗi: ${result.message ?? "Không thể tạo thanh toán."}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            icon: const Icon(Icons.arrow_back, color: kPrimaryTextColor),
            onPressed: () => Navigator.pop(context),
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
            'Xác nhận đăng ký',
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildPlanSummary(),
                    const SizedBox(height: 24),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          padding: const EdgeInsets.all(24),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chọn phương thức thanh toán',
                                style: AppFonts.title3.copyWith(
                                  color: kPrimaryTextColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildPaymentMethodsList(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanSummary() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.plan.displayName,
                style: AppFonts.title1.copyWith(
                  color: kPrimaryTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.plan.description,
                style: AppFonts.body.copyWith(color: kSecondaryTextColor),
              ),
              const SizedBox(height: 20),
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      kAccentColor,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tổng cộng',
                    style: AppFonts.title3.copyWith(
                      color: kPrimaryTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _formatPrice(widget.plan.amount, widget.plan.currency),
                    style: AppFonts.title2.copyWith(
                      color: kAccentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsList() {
    return FutureBuilder<ApiResult<List<PaymentMethod>>>(
      future: _paymentMethodsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: kPrimaryTextColor),
          );
        }
        if (!snapshot.hasData ||
            snapshot.data?.data == null ||
            !snapshot.data!.isSuccess) {
          return Center(
            child: Text(
              'Lỗi tải phương thức thanh toán: ${snapshot.data?.message ?? ""}',
            ),
          );
        }

        // SỬA LỖI Ở ĐÂY: Lọc danh sách để chỉ giữ lại các phương thức 'Active'
        final allMethods = snapshot.data!.data!;
        final activeMethods = allMethods
            .where((method) => method.status == 'Active')
            .toList();

        if (activeMethods.isEmpty) {
          return const Center(
            child: Text('Không có phương thức thanh toán nào hoạt động.'),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activeMethods.length, // Dùng danh sách đã lọc
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final method = activeMethods[index]; // Dùng danh sách đã lọc
            return RadioListTile<String>(
              title: Text(
                method.name,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              tileColor: _selectedPaymentMethodId == method.id
                  ? kAccentColor.withValues(alpha: 0.1)
                  : Colors.white,
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
    return Container(
      padding: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kAccentColor, kAccentColor.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: kAccentColor.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handlePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : Text(
                      'Thanh toán',
                      style: AppFonts.title3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ✅ Custom WebView widget for handling payment URLs with momo:// scheme
class _PaymentWebView extends StatefulWidget {
  final String paymentUrl;
  final VoidCallback onPaymentComplete;

  const _PaymentWebView({
    required this.paymentUrl,
    required this.onPaymentComplete,
  });

  @override
  State<_PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<_PaymentWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('🌐 Page started loading: $url');
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            print('✅ Page finished loading: $url');
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            print('🔗 Navigation request: ${request.url}');

            // ✅ Handle custom scheme deep links (healink://)
            if (request.url.startsWith('healink://')) {
              print('📱 Custom scheme deep link detected: ${request.url}');
              _handleCustomScheme(request.url);
              return NavigationDecision.prevent;
            }

            // ✅ Handle momo:// scheme
            if (request.url.startsWith('momo://')) {
              print('📱 MoMo scheme detected: ${request.url}');
              _handleMomoScheme(request.url);
              return NavigationDecision.prevent;
            }

            // ✅ Handle payment completion URLs
            if (request.url.contains('payment/result') ||
                request.url.contains('success') ||
                request.url.contains('complete')) {
              print('✅ Payment completion detected: ${request.url}');
              widget.onPaymentComplete();
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  /// ✅ Clean MoMo URL to extract valid HTTPS URL for web browser
  String _cleanMomoUrl(String url) {
    try {
      print('🔍 Original URL: $url');

      // Check if URL contains both momo:// and https://
      if (url.contains('momo://') && url.contains('https://')) {
        // Extract the HTTPS part - find the first occurrence of https://
        final httpsIndex = url.indexOf('https://');
        if (httpsIndex != -1) {
          final httpsUrl = url.substring(httpsIndex);
          print('✅ Extracted HTTPS URL: $httpsUrl');

          // ✅ Additional validation: ensure it's a proper URL
          try {
            final uri = Uri.parse(httpsUrl);
            if (uri.scheme == 'https' && uri.host.isNotEmpty) {
              print('✅ Valid HTTPS URL parsed successfully');
              return httpsUrl;
            }
          } catch (e) {
            print('❌ Invalid HTTPS URL format: $e');
          }
        }
      }

      // ✅ Handle case where URL is malformed (momo://...https://...)
      if (url.startsWith('momo://') && url.contains('https://')) {
        // Find the first https:// after momo://
        final httpsIndex = url.indexOf('https://');
        if (httpsIndex != -1) {
          final httpsUrl = url.substring(httpsIndex);
          print('✅ Extracted HTTPS from malformed URL: $httpsUrl');

          try {
            final uri = Uri.parse(httpsUrl);
            if (uri.scheme == 'https' && uri.host.isNotEmpty) {
              print('✅ Valid HTTPS URL from malformed URL');
              return httpsUrl;
            }
          } catch (e) {
            print('❌ Invalid HTTPS URL from malformed URL: $e');
          }
        }
      }

      // If it's a pure momo:// URL, we can't use it in web browser
      if (url.startsWith('momo://')) {
        print('❌ Pure momo:// URL detected, cannot use in web browser');
        return '';
      }

      // If it's already a valid HTTPS URL, return as is
      if (url.startsWith('https://')) {
        print('✅ Valid HTTPS URL: $url');
        return url;
      }

      print('❌ Unknown URL format: $url');
      return '';
    } catch (e) {
      print('❌ Error cleaning URL: $e');
      return '';
    }
  }

  /// ✅ Handle momo:// scheme by launching external app
  Future<void> _handleMomoScheme(String momoUrl) async {
    try {
      print('🚀 Attempting to launch MoMo app: $momoUrl');

      // ✅ Clean MoMo URL to extract HTTPS part
      String cleanUrl = _cleanMomoUrl(momoUrl);
      print('🧹 Cleaned MoMo URL: $cleanUrl');

      if (cleanUrl.isNotEmpty) {
        // ✅ Try to launch cleaned HTTPS URL in external browser
        final uri = Uri.parse(cleanUrl);
        bool launched = false;

        if (await canLaunchUrl(uri)) {
          launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
          print('✅ Cleaned URL launched in external browser: $launched');
        }

        if (launched) return; // Success, exit early
      }

      // ✅ Fallback: Try original momo:// URL
      final originalUri = Uri.parse(momoUrl);
      bool launched = false;

      if (await canLaunchUrl(originalUri)) {
        launched = await launchUrl(
          originalUri,
          mode: LaunchMode.externalApplication,
        );
        print('✅ Original MoMo URL launched: $launched');
      }

      // If MoMo app not available, show QR code or fallback
      if (!launched) {
        print('❌ MoMo app not available, showing fallback');
        _showMomoFallback(cleanUrl.isNotEmpty ? cleanUrl : momoUrl);
      }
    } catch (e) {
      print('❌ Error handling MoMo scheme: $e');
      _showMomoFallback(momoUrl);
    }
  }

  /// ✅ Handle custom scheme deep links (healink://)
  Future<void> _handleCustomScheme(String customUrl) async {
    try {
      print('🔗 Handling custom scheme: $customUrl');

      // Close WebView immediately
      Navigator.of(context).pop();

      // The deep link will be handled by main.dart automatically
      // No need to launch it manually
      print('✅ WebView closed, deep link will be handled by main.dart');
    } catch (e) {
      print('❌ Error handling custom scheme: $e');
    }
  }

  /// ✅ Show fallback when MoMo app is not available
  void _showMomoFallback(String momoUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mở ứng dụng MoMo'),
        content: const Text(
          'Vui lòng mở ứng dụng MoMo để thanh toán hoặc quét QR code.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Copy URL to clipboard
              Clipboard.setData(ClipboardData(text: momoUrl));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Link MoMo đã được copy vào clipboard'),
                ),
              );
            },
            child: const Text('Copy Link'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
        backgroundColor: kBackgroundColor,
        foregroundColor: kPrimaryTextColor,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
