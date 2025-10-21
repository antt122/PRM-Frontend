import 'package:flutter/material.dart';
import '../models/UserDetail.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'EditUserScreen.dart';

// --- THÊM IMPORT CHO MÀN HÌNH SUBSCRIPTION ---
import 'UserSubcriptionScreen.dart';
// ------------------------------------------

class UserDetailScreen extends StatefulWidget {
  final String userId;
  const UserDetailScreen({super.key, required this.userId});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<UserDetail> _userDetailFuture;

  @override
  void initState() {
    super.initState();
    _userDetailFuture = _fetchUserDetails();
  }

  Future<UserDetail> _fetchUserDetails() async {
    final result = await _apiService.getUserDetails(widget.userId);
    if (result.isSuccess && result.data != null) {
      return result.data!;
    } else {
      throw Exception(result.message ?? 'Failed to load user details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAdminBackgroundColor,
      appBar: AppBar(
        title: const Text('Chi tiết người dùng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              // Chờ future hoàn thành để lấy data
              // Dùng try-catch để xử lý nếu future bị lỗi
              try {
                final user = await _userDetailFuture;
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditUserScreen(user: user)),
                );
                if (result == true) {
                  setState(() {
                    _userDetailFuture = _fetchUserDetails(); // Refresh data
                  });
                }
              } catch (e) {
                // Hiển thị thông báo lỗi nếu không thể mở trang edit
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Không thể tải dữ liệu để chỉnh sửa: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<UserDetail>(
        future: _userDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Không tìm thấy người dùng.'));
          }
          final user = snapshot.data!;
          return _buildDetailView(user);
        },
      ),
    );
  }

  Widget _buildDetailView(UserDetail user) {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                // Hiển thị chữ cái đầu, kiểm tra chuỗi rỗng
                child: Text(
                  user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 40),
                ),
              ),
              const SizedBox(height: 16),
              Text(user.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(user.email, style: const TextStyle(color: kAdminSecondaryTextColor)),
            ],
          ),
        ),
        const Divider(height: 48),
        _buildInfoTile('Số điện thoại', user.phoneNumber ?? 'Chưa cập nhật'),
        _buildInfoTile('Địa chỉ', user.address ?? 'Chưa cập nhật'),
        _buildInfoTile('Ngày tham gia', user.formattedCreatedAt),
        _buildInfoTile('Đăng nhập lần cuối', user.formattedLastLoginAt),
        _buildInfoTile('Vai trò', user.roles.join(', ')),

        // --- BUTTON MỚI ĐỂ XEM SUBSCRIPTIONS ---
        const SizedBox(height: 24),
        ElevatedButton.icon(
          icon: const Icon(Icons.subscriptions_outlined),
          label: const Text('Xem Lịch sử Gói Đăng ký'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            // Điều hướng qua UserSubscriptionScreen và truyền userId
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserSubscriptionScreen(
                  userId: widget.userId,
                ),
              ),
            );
          },
        ),
        // --- KẾT THÚC BUTTON MỚI ---
      ],
    );
  }

  Widget _buildInfoTile(String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero, // Bỏ padding mặc định
      title: Text(title, style: const TextStyle(color: kAdminSecondaryTextColor)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 16, color: kAdminPrimaryTextColor)),
    );
  }
}