import 'package:flutter/material.dart';
import '../components/CustomButton.dart';
import '../components/CustomTextField.dart';
import '../models/UserDetail.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';

class EditUserScreen extends StatefulWidget {
  final UserDetail user;

  const EditUserScreen({super.key, required this.user});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAdminBackgroundColor,
      appBar: AppBar(
        title: Text('Chỉnh sửa: ${widget.user.fullName}', style: const TextStyle(color: kAdminPrimaryTextColor)),
        backgroundColor: kAdminBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: kAdminPrimaryTextColor),
        bottom: TabBar(
          controller: _tabController,
          labelColor: kAdminAccentColor,
          unselectedLabelColor: kAdminSecondaryTextColor,
          indicatorColor: kAdminAccentColor,
          tabs: const [
            Tab(icon: Icon(Icons.person_outline), text: 'Thông tin'),
            Tab(icon: Icon(Icons.shield_outlined), text: 'Vai trò'),
            Tab(icon: Icon(Icons.toggle_on_outlined), text: 'Trạng thái'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _UpdateInfoTab(user: widget.user),
          _UpdateRolesTab(user: widget.user),
          _UpdateStatusTab(user: widget.user),
        ],
      ),
    );
  }
}

// --- TAB 1: CẬP NHẬT THÔNG TIN ---
class _UpdateInfoTab extends StatefulWidget {
  final UserDetail user;
  const _UpdateInfoTab({required this.user});

  @override
  State<_UpdateInfoTab> createState() => _UpdateInfoTabState();
}

class _UpdateInfoTabState extends State<_UpdateInfoTab> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.user.fullName);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
    _addressController = TextEditingController(text: widget.user.address);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; });

    final result = await _apiService.updateUserInfo(
      userId: widget.user.userId,
      fullName: _fullNameController.text,
      email: _emailController.text,
      phoneNumber: _phoneController.text,
      address: _addressController.text,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? (result.isSuccess ? 'Cập nhật thành công!' : 'Đã có lỗi xảy ra.')),
          backgroundColor: result.isSuccess ? Colors.green : kAdminErrorColor,
        ),
      );
      if (result.isSuccess) Navigator.pop(context, true);
    }
    setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            CustomTextField(controller: _fullNameController, labelText: 'Họ và tên', icon: Icons.person_outline),
            const SizedBox(height: 20),
            CustomTextField(controller: _emailController, labelText: 'Email', icon: Icons.email_outlined),
            const SizedBox(height: 20),
            CustomTextField(controller: _phoneController, labelText: 'Số điện thoại', icon: Icons.phone_outlined),
            const SizedBox(height: 20),
            CustomTextField(controller: _addressController, labelText: 'Địa chỉ', icon: Icons.location_on_outlined),
            const SizedBox(height: 32),
            CustomButton(text: 'Lưu thay đổi', onPressed: _submit, isLoading: _isLoading),
          ],
        ),
      ),
    );
  }
}

// --- TAB 2: CẬP NHẬT VAI TRÒ ---
class _UpdateRolesTab extends StatefulWidget {
  final UserDetail user;
  const _UpdateRolesTab({required this.user});

  @override
  State<_UpdateRolesTab> createState() => _UpdateRolesTabState();
}

class _UpdateRolesTabState extends State<_UpdateRolesTab> {
  static const Map<String, int> _allRoles = {
    'Admin': 0, 'Staff': 1, 'User': 2, 'ContentCreator': 3,
  };

  late Set<String> _initialRoles;
  late Set<String> _selectedRoles;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _initialRoles = Set.from(widget.user.roles);
    _selectedRoles = Set.from(widget.user.roles);
  }

  Future<void> _submit() async {
    setState(() { _isLoading = true; });

    final rolesToAdd = _selectedRoles.difference(_initialRoles).map((roleName) => _allRoles[roleName]!).toList();
    final rolesToRemove = _initialRoles.difference(_selectedRoles).map((roleName) => _allRoles[roleName]!).toList();

    final result = await _apiService.updateUserRoles(
      userId: widget.user.userId,
      rolesToAdd: rolesToAdd,
      rolesToRemove: rolesToRemove,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message ?? (result.isSuccess ? 'Cập nhật thành công!' : 'Lỗi')), backgroundColor: result.isSuccess ? Colors.green : kAdminErrorColor));
      if (result.isSuccess) Navigator.pop(context, true);
    }
    setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        ..._allRoles.keys.map((roleName) {
          return CheckboxListTile(
            title: Text(roleName, style: const TextStyle(color: kAdminPrimaryTextColor)),
            value: _selectedRoles.contains(roleName),
            onChanged: (bool? selected) {
              setState(() {
                if (selected == true) {
                  _selectedRoles.add(roleName);
                } else {
                  _selectedRoles.remove(roleName);
                }
              });
            },
            activeColor: kAdminAccentColor,
            checkColor: kAdminPrimaryTextColor,
            tileColor: kAdminCardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          );
        }).toList(),
        const SizedBox(height: 32),
        CustomButton(text: 'Lưu vai trò', onPressed: _submit, isLoading: _isLoading),
      ],
    );
  }
}

// --- TAB 3: CẬP NHẬT TRẠNG THÁI ---
class _UpdateStatusTab extends StatefulWidget {
  final UserDetail user;
  const _UpdateStatusTab({required this.user});

  @override
  State<_UpdateStatusTab> createState() => _UpdateStatusTabState();
}

class _UpdateStatusTabState extends State<_UpdateStatusTab> {
  static const Map<String, int> _allStatuses = {
    'Active': 0, 'Inactive': 1, 'Deleted': 2, 'Pending': 3,
  };

  late int _selectedStatus;
  final _reasonController = TextEditingController();
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.user.status;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() { _isLoading = true; });
    final result = await _apiService.updateUserStatus(
      userId: widget.user.userId,
      status: _selectedStatus,
      reason: _reasonController.text.isNotEmpty ? _reasonController.text : null,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message ?? (result.isSuccess ? 'Cập nhật thành công!' : 'Lỗi')), backgroundColor: result.isSuccess ? Colors.green : kAdminErrorColor));
      if (result.isSuccess) Navigator.pop(context, true);
    }
    setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          DropdownButtonFormField<int>(
            value: _selectedStatus,
            decoration: InputDecoration(
              filled: true,
              fillColor: kAdminCardColor,
              labelText: 'Chọn trạng thái',
              labelStyle: const TextStyle(color: kAdminSecondaryTextColor),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kAdminInputBorderColor)),
            ),
            dropdownColor: kAdminCardColor,
            style: const TextStyle(color: kAdminPrimaryTextColor),
            items: _allStatuses.entries.map((entry) {
              return DropdownMenuItem(value: entry.value, child: Text(entry.key));
            }).toList(),
            onChanged: (value) {
              if (value != null) setState(() { _selectedStatus = value; });
            },
          ),
          const SizedBox(height: 20),
          CustomTextField(controller: _reasonController, labelText: 'Lý do (tùy chọn)', icon: Icons.edit_note),
          const SizedBox(height: 32),
          CustomButton(text: 'Cập nhật trạng thái', onPressed: _submit, isLoading: _isLoading),
        ],
      ),
    );
  }
}

