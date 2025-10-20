import 'package:flutter/material.dart';

import '../components/CustomButton.dart';
import '../components/CustomTextField.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final ApiService _apiService = ApiService();

  int _selectedRole = 2; // Mặc định là User (ID=2)
  bool _isLoading = false;

  Future<void> _createUser() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _fullNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email, Mật khẩu và Họ tên là bắt buộc.'),
          backgroundColor: kAdminErrorColor,
        ),
      );
      return;
    }

    setState(() { _isLoading = true; });

    final result = await _apiService.createUser(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      fullName: _fullNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      role: _selectedRole,
    );

    if (mounted) {
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tạo người dùng "${result.data?.fullName}" thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${result.message ?? "Không thể tạo người dùng."}'),
            backgroundColor: kAdminErrorColor,
          ),
        );
      }
    }

    setState(() { _isLoading = false; });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAdminBackgroundColor,
      appBar: AppBar(
        title: const Text('Tạo người dùng mới'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(controller: _emailController, labelText: 'Email', icon: Icons.email_outlined),
            const SizedBox(height: 20),
            CustomTextField(controller: _passwordController, labelText: 'Mật khẩu', icon: Icons.lock_outline, isPassword: true),
            const SizedBox(height: 20),
            CustomTextField(controller: _fullNameController, labelText: 'Họ và tên', icon: Icons.person_outline),
            const SizedBox(height: 20),
            CustomTextField(controller: _phoneController, labelText: 'Số điện thoại', icon: Icons.phone_outlined),
            const SizedBox(height: 20),
            CustomTextField(controller: _addressController, labelText: 'Địa chỉ', icon: Icons.location_on_outlined),
            const SizedBox(height: 20),
            _buildRoleDropdown(),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Tạo người dùng',
              onPressed: _createUser,
              isLoading: _isLoading,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedRole,
      decoration: const InputDecoration(
        labelText: 'Vai trò',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 0, child: Text('Admin')),
        DropdownMenuItem(value: 1, child: Text('Staff')),
        DropdownMenuItem(value: 2, child: Text('User')),
        DropdownMenuItem(value: 3, child: Text('Content Creator')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedRole = value;
          });
        }
      },
    );
  }
}

