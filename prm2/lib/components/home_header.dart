import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback onLogout;

  const HomeHeader({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    // Màu sắc
    final Color primaryColor = const Color(0xFF6A4E42); // Màu nâu đậm
    final Color accentColor = const Color(0xFFC0A080); // Màu nâu vàng

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // LOGO (Mô phỏng)
          Row(
            children: [
              Icon(Icons.spa, color: primaryColor, size: 24),
              const SizedBox(width: 4),
              Text(
                'Healink',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),

          // Thanh Menu giữa (Chỉ hiển thị trên tablet/desktop, ẩn trên mobile)
          const Spacer(), // Đẩy các icon sang phải

          // Menu Icons (Giỏ hàng, Đặt hàng, Tài khoản)
          Row(
            children: [
              _buildMenuItem(Icons.shopping_bag_outlined, 'Giỏ hàng', primaryColor),
              _buildMenuItem(Icons.event_note_outlined, 'Đặt hàng', primaryColor),
              _buildMenuItem(Icons.person_outline, 'Tài khoản', primaryColor, onTap: onLogout), // Gán Logout vào Tài khoản
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String text, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            Text(
              text,
              style: TextStyle(fontSize: 9, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
