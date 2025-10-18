import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/CmsUserProfile.dart';
import '../models/api_result.dart';
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
  late Future<ApiResult<CmsUserProfile>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _apiService.getCmsUserProfile();
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
        title: const Text('Hồ sơ của tôi', style: TextStyle(color: kAdminPrimaryTextColor)),
        backgroundColor: kAdminBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: kAdminPrimaryTextColor),
      ),
      body: FutureBuilder<ApiResult<CmsUserProfile>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kAdminAccentColor));
          }
          if (!snapshot.hasData || !snapshot.data!.isSuccess || snapshot.data!.data == null) {
            return Center(
              child: Text(
                'Lỗi tải thông tin: ${snapshot.data?.message ?? "Vui lòng thử lại."}',
                style: const TextStyle(color: kAdminSecondaryTextColor),
              ),
            );
          }

          final userProfile = snapshot.data!.data!;
          return _buildProfileView(context, userProfile);
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
          // Avatar
          CircleAvatar(
            radius: 60,
            backgroundColor: kAdminCardColor,
            backgroundImage: profile.avatarPath != null ? NetworkImage(profile.avatarPath!) : null,
            child: profile.avatarPath == null
                ? const Icon(Icons.person_outline, size: 60, color: kAdminSecondaryTextColor)
                : null,
          ),
          const SizedBox(height: 16),
          // Full Name
          Text(
            profile.fullName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kAdminPrimaryTextColor),
          ),
          const SizedBox(height: 8),
          // Email
          Text(
            profile.email,
            style: const TextStyle(fontSize: 16, color: kAdminSecondaryTextColor),
          ),
          const SizedBox(height: 32),
          // Information Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kAdminCardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildInfoTile(Icons.phone_outlined, 'Số điện thoại', profile.phoneNumber ?? 'Chưa cập nhật'),
                const Divider(color: kAdminInputBorderColor),
                _buildInfoTile(Icons.location_on_outlined, 'Địa chỉ', profile.address ?? 'Chưa cập nhật'),
                const Divider(color: kAdminInputBorderColor),
                _buildInfoTile(Icons.calendar_today_outlined, 'Ngày tham gia', profile.formattedCreatedAt),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Buttons
          ElevatedButton(
            onPressed: () {
              // TODO: Điều hướng đến màn hình chỉnh sửa thông tin
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: kAdminAccentColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Cập nhật thông tin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => _handleLogout(context),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              side: const BorderSide(color: kAdminErrorColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Đăng xuất', style: TextStyle(color: kAdminErrorColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: kAdminSecondaryTextColor),
      title: Text(title, style: const TextStyle(color: kAdminSecondaryTextColor)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: kAdminPrimaryTextColor, fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }
}
