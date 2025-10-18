import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/CmsUser.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'CreateUserScreen.dart';
import 'UserDetailScreen.dart';



class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  // ... (giữ nguyên tất cả các hàm và state đã có)
  final ApiService _apiService = ApiService();
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<CmsUser> _users = [];
  bool _isLoading = true;
  int _currentPage = 1;
  int _totalPages = 1;
  int? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchUsers({int page = 1}) async {
    if (!mounted) return;
    setState(() { _isLoading = true; });

    final result = await _apiService.getUsers(page: page, search: _searchController.text.trim(), status: _selectedStatus,);

    if (mounted) {
      setState(() {
        if (result.isSuccess && result.data != null) {
          _users = result.data!.items;
          _currentPage = result.data!.currentPage;
          _totalPages = result.data!.totalPages;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tải dữ liệu: ${result.message ?? "Không rõ"}'), backgroundColor: kAdminErrorColor,),);
        }
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () { _fetchUsers(); });
  }


  // --- CẬP NHẬT WIDGET NÀY ---
  Widget _buildUserCard(CmsUser user) {
    return InkWell(
      onTap: () {
        // --- SỬA LẠI Ở ĐÂY ---
        // API GET chi tiết người dùng yêu cầu 'id' (khóa chính của profile)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserDetailScreen(userId: user.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kAdminCardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kAdminInputBorderColor.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(user.fullName, style: const TextStyle(color: kAdminPrimaryTextColor, fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis,),),
                _buildStatusChip(user.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(user.email, style: const TextStyle(color: kAdminSecondaryTextColor)),
            const Divider(height: 20, color: kAdminInputBorderColor),
            _buildInfoRow(Icons.phone_outlined, user.phoneNumber ?? 'Chưa cập nhật'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.shield_outlined, user.roles.isNotEmpty ? user.roles.join(', ') : 'Chưa có vai trò'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.calendar_today_outlined, 'Ngày tạo: ${DateFormat('dd/MM/yyyy').format(user.createdAt)}'),
          ],
        ),
      ),
    );
  }

  // ... (tất cả các hàm build và widget khác giữ nguyên)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAdminBackgroundColor,
      appBar: AppBar(
        title: const Text('Quản lý Người dùng', style: TextStyle(color: kAdminPrimaryTextColor)),
        backgroundColor: kAdminBackgroundColor,
        iconTheme: const IconThemeData(color: kAdminPrimaryTextColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: kAdminAccentColor),
            tooltip: 'Tạo người dùng mới',
            onPressed: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateUserScreen()),);
              if (result == true) { _fetchUsers(); }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: kAdminAccentColor))
                : _users.isEmpty
                ? const Center(child: Text('Không tìm thấy người dùng nào.', style: TextStyle(color: kAdminSecondaryTextColor)))
                : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _users.length,
              itemBuilder: (context, index) => _buildUserCard(_users[index]),
              separatorBuilder: (context, index) => const SizedBox(height: 12),
            ),
          ),
          if (!_isLoading && _totalPages > 1) _buildPaginationControls(),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          TextFormField(
            controller: _searchController,
            style: const TextStyle(color: kAdminPrimaryTextColor),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm theo tên hoặc email...',
              hintStyle: const TextStyle(color: kAdminSecondaryTextColor),
              prefixIcon: const Icon(Icons.search, color: kAdminSecondaryTextColor),
              filled: true,
              fillColor: kAdminCardColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int?>(
            value: _selectedStatus,
            decoration: InputDecoration(
              filled: true,
              fillColor: kAdminCardColor,
              labelText: 'Lọc theo trạng thái',
              labelStyle: const TextStyle(color: kAdminSecondaryTextColor),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            ),
            dropdownColor: kAdminCardColor,
            style: const TextStyle(color: kAdminPrimaryTextColor),
            items: const [
              DropdownMenuItem(value: null, child: Text('Tất cả trạng thái')),
              DropdownMenuItem(value: 0, child: Text('Hoạt động')),
              DropdownMenuItem(value: 1, child: Text('Vô hiệu hóa')),
              DropdownMenuItem(value: 2, child: Text('Chờ xử lý')),
            ],
            onChanged: (value) {
              setState(() { _selectedStatus = value; });
              _fetchUsers();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: kAdminSecondaryTextColor),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: kAdminSecondaryTextColor)),
      ],
    );
  }

  Widget _buildStatusChip(int status) {
    String label;
    Color color;
    switch (status) {
      case 0:
        label = 'Hoạt động'; color = Colors.green; break;
      case 1:
        label = 'Vô hiệu'; color = kAdminErrorColor; break;
      case 2:
        label = 'Chờ xử lý'; color = Colors.orange; break;
      default:
        label = 'Không rõ'; color = kAdminSecondaryTextColor;
    }
    return Chip(
      label: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
      backgroundColor: color.withOpacity(0.15),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      side: BorderSide.none,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildPaginationControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: kAdminCardColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: kAdminSecondaryTextColor),
            onPressed: _currentPage > 1 ? () => _fetchUsers(page: _currentPage - 1) : null,
          ),
          Text('Trang $_currentPage / $_totalPages', style: const TextStyle(color: kAdminSecondaryTextColor),),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: kAdminSecondaryTextColor),
            onPressed: _currentPage < _totalPages ? () => _fetchUsers(page: _currentPage + 1) : null,
          ),
        ],
      ),
    );
  }
}

