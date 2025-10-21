import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/CmsUserProfile.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'LoginScreen.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  late Future<CmsUserProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _fetchProfile();
  }

  Future<CmsUserProfile> _fetchProfile() async {
    final result = await _apiService.getCmsUserProfile();
    if (result.isSuccess && result.data != null) {
      return result.data!;
    } else {
      throw Exception(result.message ?? 'Failed to load profile');
    }
  }

  void _handleLogout(BuildContext context) async {
    final apiService = ApiService();
    apiService.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAdminBackgroundColor,
      appBar: AppBar(
        title: const Text('Hồ sơ của tôi'),
      ),
      body: FutureBuilder<CmsUserProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Lỗi tải thông tin: ${snapshot.error}'));
          }
          final profile = snapshot.data!;
          return _buildProfileView(context, profile);
        },
      ),
    );
  }

  Widget _buildProfileView(BuildContext context, CmsUserProfile profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 60,
            child: Icon(Icons.person, size: 60),
          ),
          const SizedBox(height: 16),
          Text(profile.fullName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(profile.email, style: const TextStyle(fontSize: 16, color: kAdminSecondaryTextColor)),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.phone_outlined),
            title: const Text('Số điện thoại'),
            subtitle: Text(profile.phoneNumber ?? 'Chưa cập nhật'),
          ),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('Địa chỉ'),
            subtitle: Text(profile.address ?? 'Chưa cập nhật'),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today_outlined),
            title: const Text('Ngày tham gia'),
            subtitle: Text(profile.formattedCreatedAt),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // TODO: Điều hướng đến màn hình chỉnh sửa thông tin
            },
            child: const Text('Cập nhật thông tin'),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => _handleLogout(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: kAdminErrorColor),
            ),
            child: const Text('Đăng xuất', style: TextStyle(color: kAdminErrorColor)),
          ),
        ],
      ),
    );
  }
}

