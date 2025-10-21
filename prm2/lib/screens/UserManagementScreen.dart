
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/CmsUser.dart';
import '../models/PaginatedResult.dart';
import '../providers/UserFilter.dart';
import '../utils/app_colors.dart';
import 'CreateUserScreen.dart';
import 'UserDetailScreen.dart';


class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

class _UserManagementScreenState
    extends ConsumerState<UserManagementScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  int? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () {
      ref.read(userFilterProvider.notifier).applyFilters(
        search: _searchController.text,
        status: _selectedStatus,
      );
    });
  }

  void _onStatusChanged(int? value) {
    setState(() {
      _selectedStatus = value;
    });
    ref.read(userFilterProvider.notifier).applyFilters(
      search: _searchController.text,
      status: _selectedStatus,
    );
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersProvider);
    final filterNotifier = ref.read(userFilterProvider.notifier);

    return Scaffold(
      backgroundColor: kAdminBackgroundColor,
      appBar: AppBar(
        title: const Text('Quản lý Người dùng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: kAdminAccentColor),
            tooltip: 'Tạo người dùng mới',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateUserScreen()),
              );
              if (result == true) {
                ref.refresh(usersProvider);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(usersProvider),
          )
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: usersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: kAdminAccentColor)),
              error: (err, st) => Center(child: Text('Lỗi tải dữ liệu: $err')),
              data: (apiResult) {
                if (!apiResult.isSuccess || apiResult.data == null) {
                  return Center(child: Text(apiResult.message ?? 'Đã có lỗi xảy ra.'));
                }
                final response = apiResult.data!;
                if (response.items.isEmpty) {
                  return const Center(child: Text('Không tìm thấy người dùng nào.'));
                }

                // --- SỬA LỖI: Di chuyển toàn bộ giao diện vào trong khối 'data' ---
                return Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => ref.refresh(usersProvider.future),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: response.items.length,
                          itemBuilder: (context, index) => _buildUserCard(response.items[index]),
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                        ),
                      ),
                    ),
                    // Phân trang giờ đã an toàn vì 'response' đã được định nghĩa
                    _buildPaginationControls(
                      response,
                          (page) => filterNotifier.setPage(page),
                    )
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<int?>(
            value: _selectedStatus,
            hint: const Text('Trạng thái'),
            items: const [
              DropdownMenuItem(value: null, child: Text('Tất cả')),
              DropdownMenuItem(value: 0, child: Text('Hoạt động')),
              DropdownMenuItem(value: 1, child: Text('Vô hiệu hóa')),
              DropdownMenuItem(value: 2, child: Text('Chờ xử lý')),
            ],
            onChanged: _onStatusChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(CmsUser user) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserDetailScreen(userId: user.id),
          ),
        );
        if (result == true) {
          ref.refresh(usersProvider);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(user.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  _buildStatusChip(user.status),
                ],
              ),
              const SizedBox(height: 4),
              Text(user.email, style: const TextStyle(color: kAdminSecondaryTextColor)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationControls(
      PaginatedResult<CmsUser> response, ValueChanged<int> onPageChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: kAdminCardColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: response.hasPrevious ? () => onPageChanged(1) : null,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: response.hasPrevious ? () => onPageChanged(response.currentPage - 1) : null,
          ),
          Text('Trang ${response.currentPage} / ${response.totalPages}', style: const TextStyle(color: kAdminSecondaryTextColor)),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: response.hasNext ? () => onPageChanged(response.currentPage + 1) : null,
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: response.hasNext ? () => onPageChanged(response.totalPages) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(int status) {
    String label;
    Color color;
    switch (status) {
      case 0: label = 'Hoạt động'; color = Colors.green; break;
      case 1: label = 'Vô hiệu hóa'; color = Colors.red; break;
      case 2: label = 'Chờ xử lý'; color = Colors.orange; break;
      default: label = 'Không rõ'; color = Colors.grey;
    }
    return Chip(label: Text(label), backgroundColor: color.withOpacity(0.2));
  }
}

