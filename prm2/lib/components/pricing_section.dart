import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'pricing_card.dart'; // Import PricingCard

class PricingSection extends StatelessWidget {
  const PricingSection({super.key});

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
          const PricingCard(
            title: 'FREEMIUM',
            subtitle: 'Truy cập cảm hứng',
            features: [
              'Nghe podcast',
              'Không quảng cáo',
              'Playlist và My podcast',
              'Viết thư - nhật kí cảm xúc',
            ],
            isEnabled: [true, false, false, false],
          ),
          const SizedBox(height: 20),
          const PricingCard(
            title: 'PREMIUM INDIVIDUAL',
            price: '59.000 VND/Tháng',
            features: [
              'Nghe podcast',
              'Không quảng cáo',
              'Playlist và My podcast',
              'Viết thư - nhật kí cảm xúc',
              'Đăng tải podcast cá nhân'
            ],
            isRecommended: true,
          ),
          const SizedBox(height: 20),
          const PricingCard(
            title: 'PREMIUM CHANNEL',
            price: '89.000 VND/Tháng',
            features: [
              'Nghe podcast',
              'Không quảng cáo',
              'Playlist và My podcast',
              'Viết thư - nhật kí cảm xúc',
              'Đăng tải podcast cá nhân'
            ],
          ),
        ],
      ),
    );
  }
}
