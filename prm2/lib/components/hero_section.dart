import 'package:flutter/material.dart';
import '../models/api_result.dart';
import '../models/creator_application_status.dart';
import '../screens/application_status_screen.dart';
import '../screens/creator_application_screen.dart';
import '../screens/creator_dashboard_screen.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';

class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  bool _isLoading = false;
  CreatorApplicationStatus? _creatorStatus;

  @override
  void initState() {
    super.initState();
    _loadCreatorStatus();
  }

  Future<void> _loadCreatorStatus() async {
    final result = await ApiService.getMyCreatorApplicationStatus();
    if (mounted && result.isSuccess && result.data != null) {
      setState(() {
        _creatorStatus = result.data;
      });
    }
  }

  Future<void> _handleCreatorButtonTap() async {
    setState(() => _isLoading = true);

    final ApiResult<CreatorApplicationStatus> result =
    await ApiService.getMyCreatorApplicationStatus();

    if (!mounted) return;
    setState(() => _isLoading = false);

    // --- LOGIC ĐIỀU HƯỚNG MỚI ---
    if (result.isSuccess && result.data != null) {
      final status = result.data!;
      final statusLower = status.status.toLowerCase();

      // TRƯỜNG HỢP 1: Đơn đã được duyệt -> Đi thẳng đến trang sáng tạo
      if (statusLower == 'approved') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreatorDashboardScreen()),
        );
      }
      // TRƯỜNG HỢP 2: Các trạng thái khác (Pending, Rejected) -> Xem chi tiết
      else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ApplicationStatusScreen(status: status)),
        );
      }
    } else {
      // TRƯỜNG HỢP 3: Lỗi 404 -> Chưa có đơn -> Mở form đăng ký
      if (result.errorCode == '404') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreatorApplicationScreen()),
        );
      } else {
        // TRƯỜNG HỢP 4: Các lỗi khác (mạng, 401, ...) -> Hiển thị thông báo
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Đã có lỗi xảy ra. Vui lòng thử lại.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          // <<< GIỮ NGUYÊN HÌNH ẢNH NETWORK CỦA BẠN
          image: NetworkImage(
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQUh1Df3ybMQ3DSBRLD_PKhSE5f0SHFq4w00U5Wk8KcPqUr8N2poXG0fmyuQqZO3rXJXEQ&usqp=CAU'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '“Nuôi dưỡng tâm hồn bằng cảm hứng mỗi ngày”',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    shadows: [Shadow(blurRadius: 10.0, color: Colors.black54)],
                  ),
                ),
                const SizedBox(height: 20),
                // Hiển thị thông báo đã là Creator hoặc nút đăng ký
                if (_creatorStatus != null && _creatorStatus!.status.toLowerCase() == 'approved')
                  _buildApprovedCreatorCard()
                else
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleCreatorButtonTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                        : const Text('Trở thành content creator'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildApprovedCreatorCard() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.verified, color: Colors.green, size: 22),
              SizedBox(width: 8),
              Text(
                '🎉 Bạn đã là Content Creator',
                style: TextStyle(
                  color: kPrimaryTextColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreatorDashboardScreen()),
            );
          },
          icon: const Icon(Icons.dashboard, size: 18),
          label: const Text('Quản lý Podcast của tôi'),
          style: ElevatedButton.styleFrom(
            backgroundColor: kAccentColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ],
    );
  }
}

