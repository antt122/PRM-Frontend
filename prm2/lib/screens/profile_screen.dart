import 'package:flutter/material.dart';
import 'package:prm2/models/user_profile.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserProfile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<UserProfile?> _loadProfile() async {
    final result = await ApiService.getUserProfile();
    if (result.isSuccess && result.data != null) {
      return result.data;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin cá nhân'),
      ),
      body: FutureBuilder<UserProfile?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final profile = snapshot.data;
          if (profile == null) {
            return const Center(child: Text('Không thể tải thông tin cá nhân.'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.brown.shade200,
                  child: Icon(Icons.person, size: 48, color: Colors.brown.shade700),
                ),
                const SizedBox(height: 16),
                _buildInfoField('Họ và tên', profile.fullName, Icons.person),
                _buildInfoField('Email', profile.email, Icons.email),
                _buildInfoField('Số điện thoại', profile.phoneNumber.isNotEmpty ? profile.phoneNumber : 'Chưa cập nhật', Icons.phone),
                _buildInfoField('Địa chỉ nhà', profile.address.isNotEmpty ? profile.address : 'Chưa cập nhật', Icons.home),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit),
                  label: const Text('Chỉnh sửa'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown.shade400,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoField(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.brown.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
