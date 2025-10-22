import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import '../models/my_subscription.dart';
import '../models/api_result.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_fonts.dart';

class MySubscriptionScreen extends StatefulWidget {
  const MySubscriptionScreen({super.key});

  @override
  State<MySubscriptionScreen> createState() => _MySubscriptionScreenState();
}

class _MySubscriptionScreenState extends State<MySubscriptionScreen> {
  late Future<ApiResult<MySubscription>> _subscriptionFuture;

  @override
  void initState() {
    super.initState();
    _subscriptionFuture = ApiService.getMySubscription();
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
            'Gói cước của tôi',
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
      child: FutureBuilder<ApiResult<MySubscription>>(
        future: _subscriptionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: kGlassBackground,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: kGlassBorder, width: 0.5),
                      ),
                      child: const CircularProgressIndicator(
                        color: kAccentColor,
                      ),
                    ),
                  ),
                ),
              );
            }
            if (!snapshot.hasData ||
                !snapshot.data!.isSuccess ||
                snapshot.data!.data == null) {
            return Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: kGlassBackground,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: kGlassBorder, width: 0.5),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.subscriptions_outlined,
                            size: 64,
                            color: kSecondaryTextColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            snapshot.data?.message ??
                                'Bạn chưa đăng ký gói cước nào.',
                            style: AppFonts.body.copyWith(
                              color: kPrimaryTextColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            );
          }

          final sub = snapshot.data!.data!;
            return SingleChildScrollView(
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header với tên gói và trạng thái
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sub.planDisplayName,
                                      style: AppFonts.title1.copyWith(
                                        color: kPrimaryTextColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      sub.planName,
                                      style: AppFonts.body.copyWith(
                                        color: kSecondaryTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: sub.subscriptionStatusName == 'Active'
                                      ? Colors.green.withValues(alpha: 0.2)
                                      : Colors.orange.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color:
                                        sub.subscriptionStatusName == 'Active'
                                        ? Colors.green
                                        : Colors.orange,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  sub.subscriptionStatusName,
                                  style: AppFonts.caption1.copyWith(
                                    color:
                                        sub.subscriptionStatusName == 'Active'
                                        ? Colors.green
                                        : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Giá và chu kỳ thanh toán
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: kSurfaceColor.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: kGlassBorder,
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Giá',
                                      style: AppFonts.caption1.copyWith(
                                        color: kSecondaryTextColor,
                                      ),
                                    ),
                                    Text(
                                      NumberFormat.currency(
                                        locale: 'vi_VN',
                                        symbol: '₫',
                                      ).format(sub.amount),
                                      style: AppFonts.title2.copyWith(
                                        color: kAccentColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Chu kỳ',
                                      style: AppFonts.caption1.copyWith(
                                        color: kSecondaryTextColor,
                                      ),
                                    ),
                                    Text(
                                      sub.billingPeriodUnit,
                                      style: AppFonts.title2.copyWith(
                                        color: kPrimaryTextColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Thông tin chi tiết
                          Text(
                            'Thông tin chi tiết',
                            style: AppFonts.title3.copyWith(
                              color: kPrimaryTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildInfoRow(
                            'Ngày bắt đầu',
                            DateFormat(
                              'dd/MM/yyyy HH:mm',
                            ).format(sub.currentPeriodStart),
                            Icons.calendar_today,
                          ),
                          _buildInfoRow(
                            'Ngày kết thúc',
                            DateFormat(
                              'dd/MM/yyyy HH:mm',
                            ).format(sub.currentPeriodEnd),
                            Icons.event,
                          ),
                          _buildInfoRow(
                            'Gia hạn',
                            sub.renewalBehaviorName,
                            Icons.autorenew,
                          ),
                          _buildInfoRow(
                            'ID đăng ký',
                            sub.id,
                            Icons.fingerprint,
                          ),
                          _buildInfoRow(
                            'ID gói',
                            sub.subscriptionPlanId,
                            Icons.card_membership,
                          ),
                          _buildInfoRow(
                            'Ngày tạo',
                            DateFormat(
                              'dd/MM/yyyy HH:mm',
                            ).format(sub.createdAt),
                            Icons.schedule,
                          ),
                          _buildInfoRow(
                            'Ngày cập nhật',
                            DateFormat(
                              'dd/MM/yyyy HH:mm',
                            ).format(sub.updatedAt),
                            Icons.update,
                          ),

                          const SizedBox(height: 24),

                          // Thông tin hủy đăng ký
                          if (sub.cancelAt != null || sub.canceledAt != null)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.red.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                                  Text(
                                    'Thông tin hủy đăng ký',
                                    style: AppFonts.title3.copyWith(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                    const SizedBox(height: 8),
                                  if (sub.cancelAt != null)
                                    _buildInfoRow(
                                      'Hủy vào',
                                      DateFormat(
                                        'dd/MM/yyyy HH:mm',
                                      ).format(sub.cancelAt!),
                                      Icons.cancel,
                                    ),
                                  if (sub.canceledAt != null)
                                    _buildInfoRow(
                                      'Đã hủy',
                                      DateFormat(
                                        'dd/MM/yyyy HH:mm',
                                      ).format(sub.canceledAt!),
                                      Icons.cancel_outlined,
                                    ),
                                  _buildInfoRow(
                                    'Hủy khi hết hạn',
                                    sub.cancelAtPeriodEnd ? 'Có' : 'Không',
                                    Icons.timer_off,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                ),
              ),
            ),
          );
        },
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: kAccentColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                Text(
                  label,
                  style: AppFonts.caption1.copyWith(color: kSecondaryTextColor),
                ),
                Text(
                  value,
                  style: AppFonts.body.copyWith(
                    color: kPrimaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
