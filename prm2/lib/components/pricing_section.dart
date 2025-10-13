import 'package:flutter/material.dart';
import '../models/api_result.dart';
import '../models/subscription_plan.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'pricing_card.dart';

class PricingSection extends StatefulWidget {
  const PricingSection({super.key});

  @override
  State<PricingSection> createState() => _PricingSectionState();
}

class _PricingSectionState extends State<PricingSection> {
  // Sử dụng Future để lưu trữ kết quả gọi API
  late Future<ApiResult<List<SubscriptionPlan>>> _plansFuture;
  bool _showAll = false; // Trạng thái để kiểm soát việc hiển thị tất cả các gói

  @override
  void initState() {
    super.initState();
    // Gọi API ngay khi widget được tạo
    _fetchPlans();
  }

  void _fetchPlans() {
    setState(() {
      _plansFuture = ApiService.getSubscriptionPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      color: kHighlightColor,
      child: Column(
        children: [
          const Text(
            'Chọn gói đăng ký của bạn',
            style: TextStyle(
              color: kPrimaryTextColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),

          // Sử dụng FutureBuilder để hiển thị UI dựa trên trạng thái của Future
          FutureBuilder<ApiResult<List<SubscriptionPlan>>>(
            future: _plansFuture,
            builder: (context, snapshot) {
              // --- TRẠNG THÁI 1: ĐANG TẢI DỮ LIỆU ---
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: kPrimaryTextColor),
                );
              }

              // --- TRẠNG THÁI 2: CÓ LỖI XẢY RA ---
              if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.isSuccess) {
                final errorMessage = snapshot.data?.message ??
                    snapshot.data?.errors?.join(', ') ??
                    snapshot.error?.toString() ??
                    'Đã có lỗi xảy ra.';
                return Center(
                  child: Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              // --- TRẠNG THÁI 3: TẢI DỮ LIỆU THÀNH CÔNG ---
              final allPlans = snapshot.data!.data ?? [];

              if (allPlans.isEmpty) {
                return const Center(child: Text('Hiện không có gói đăng ký nào.'));
              }

              // Xác định danh sách gói sẽ hiển thị
              final displayedPlans = _showAll || allPlans.length <= 3
                  ? allPlans
                  : allPlans.sublist(0, 3);

              return Column(
                children: [
                  // Dùng ListView.separated để tự động thêm SizedBox giữa các card
                  ListView.separated(
                    itemCount: displayedPlans.length,
                    shrinkWrap: true, // Cần thiết khi lồng ListView trong Column
                    physics: const NeverScrollableScrollPhysics(), // Tắt cuộn của ListView
                    separatorBuilder: (context, index) => const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      final plan = displayedPlans[index];
                      // TODO: Xác định gói nào là isRecommended dựa trên logic của bạn
                      // Ví dụ: final isRecommended = plan.name == 'premium_individual';
                      return PricingCard(plan: plan, isRecommended: false);
                    },
                  ),

                  // Hiển thị nút "Khám phá thêm" nếu cần
                  if (!_showAll && allPlans.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _showAll = true;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                            foregroundColor: kPrimaryTextColor,
                            side: const BorderSide(color: kAccentColor),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
                        ),
                        child: const Text('Khám phá thêm'),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

