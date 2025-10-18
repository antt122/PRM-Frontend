import 'package:flutter/material.dart';
import '../models/UserDetail.dart';
import '../models/api_result.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'EditUserScreen.dart';
import 'UserSubcriptionScreen.dart';
class UserDetailScreen extends StatefulWidget {
  final String userId;
  const UserDetailScreen({super.key, required this.userId});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<ApiResult<UserDetail>> _userDetailFuture;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      _userDetailFuture = _apiService.getUserDetails(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAdminBackgroundColor,
      appBar: AppBar(
        title: const Text('Chi tiết người dùng', style: TextStyle(color: kAdminPrimaryTextColor)),
        backgroundColor: kAdminBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: kAdminPrimaryTextColor),
        // --- THÊM NÚT CHỈNH SỬA Ở ĐÂY ---
        actions: [
          FutureBuilder<ApiResult<UserDetail>>(
            future: _userDetailFuture,
            builder: (context, snapshot) {
              // Chỉ hiển thị nút khi đã có dữ liệu
              if (snapshot.hasData && snapshot.data!.isSuccess && snapshot.data!.data != null) {
                return IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Chỉnh sửa người dùng',
                  onPressed: () async {
                    final bool? result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditUserScreen(user: snapshot.data!.data!),
                      ),
                    );
                    // Nếu sau khi chỉnh sửa trả về true, tải lại dữ liệu
                    if (result == true) {
                      _fetchData();
                    }
                  },
                );
              }
              return const SizedBox.shrink(); // Ẩn nút nếu chưa có data
            },
          ),
        ],
      ),
      body: FutureBuilder<ApiResult<UserDetail>>(
        future: _userDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kAdminAccentColor));
          }
          if (!snapshot.hasData || !snapshot.data!.isSuccess || snapshot.data!.data == null) {
            return Center(child: Text('Lỗi tải thông tin: ${snapshot.data?.message ?? "Vui lòng thử lại."}', style: const TextStyle(color: kAdminSecondaryTextColor)));
          }
          final user = snapshot.data!.data!;
          return _buildDetailView(user);
        },
      ),
    );
  }

  // ... (các hàm build UI khác giữ nguyên)
  Widget _buildDetailView(UserDetail user) {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        Center(
          child: Column(
            children: [
              CircleAvatar(radius: 50, backgroundColor: kAdminCardColor, backgroundImage: user.avatarPath != null ? NetworkImage(user.avatarPath!) : null, child: user.avatarPath == null ? const Icon(Icons.person_outline, size: 50, color: kAdminSecondaryTextColor) : null,),
              const SizedBox(height: 16),
              Text(user.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kAdminPrimaryTextColor)),
              const SizedBox(height: 8),
              Text(user.email, style: const TextStyle(fontSize: 16, color: kAdminSecondaryTextColor)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatusChip(user.status),
                  const SizedBox(width: 8),
                  Chip(label: Text(user.roles.isNotEmpty ? user.roles.join(', ') : 'No Role'), backgroundColor: kAdminCardColor),
                ],
              )
            ],
          ),
        ),
        const Divider(height: 48, color: kAdminInputBorderColor),
        _buildInfoCard(
          title: 'Thông tin liên hệ',
          children: [
            _buildInfoTile(Icons.phone_outlined, 'Số điện thoại', user.phoneNumber ?? 'Chưa cập nhật'),
            _buildInfoTile(Icons.location_on_outlined, 'Địa chỉ', user.address ?? 'Chưa cập nhật'),
          ],
        ),
        const SizedBox(height: 24),
        _buildInfoCard(
          title: 'Thông tin hệ thống',
          children: [
            _buildInfoTile(Icons.history_toggle_off, 'Đăng nhập gần nhất', user.formattedLastLoginAt),
            _buildInfoTile(Icons.calendar_today_outlined, 'Ngày tham gia', user.formattedCreatedAt),
          ],
        ),
        const SizedBox(height: 24),
        _buildInfoCard(
          title: 'Quản lý gói',
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history_edu_outlined, color: kAdminSecondaryTextColor),
              title: const Text('Xem danh sách gói đăng ký của người dùng', style: TextStyle(color: kAdminPrimaryTextColor)),
              trailing: const Icon(Icons.arrow_forward_ios, color: kAdminSecondaryTextColor, size: 16),
              onTap: () {
                // Điều hướng đến màn hình danh sách gói đăng ký khi bấm vào
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserSubscriptionScreen(
                      userId: user.id,        // Truyền ID người dùng
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
  Widget _buildInfoCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: kAdminCardColor, borderRadius: BorderRadius.circular(12),),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: kAdminPrimaryTextColor, fontWeight: FontWeight.bold, fontSize: 18)),
          const Divider(height: 20, color: kAdminInputBorderColor),
          ...children,
        ],
      ),
    );
  }
  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: kAdminSecondaryTextColor),
      title: Text(title, style: const TextStyle(color: kAdminSecondaryTextColor)),
      subtitle: Text(subtitle, style: const TextStyle(color: kAdminPrimaryTextColor, fontSize: 16, fontWeight: FontWeight.w500),),
    );
  }
  Widget _buildStatusChip(int status) {
    String label; Color color; IconData icon;
    switch (status) {
      case 0: label = 'Hoạt động'; color = Colors.green; icon = Icons.check_circle; break;
      case 1: label = 'Vô hiệu hóa'; color = kAdminErrorColor; icon = Icons.cancel; break;
      case 2: label = 'Chờ xử lý'; color = Colors.orange; icon = Icons.hourglass_empty; break;
      default: label = 'Không rõ'; color = kAdminSecondaryTextColor; icon = Icons.help_outline;
    }
    return Chip(avatar: Icon(icon, color: color, size: 18), label: Text(label), backgroundColor: color.withOpacity(0.15), labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),);
  }
}

