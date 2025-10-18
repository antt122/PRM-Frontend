import 'package:flutter/material.dart';
import '../models/UserDetail.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'EditUserScreen.dart';


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
                child: Text(user.fullName[0], style: const TextStyle(fontSize: 40)),
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
      ],
    );
  }

  Widget _buildInfoTile(String title, String subtitle) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: kAdminSecondaryTextColor)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 16, color: kAdminPrimaryTextColor)),
    );
  }
}

