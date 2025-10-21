import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/PaymentMethodCard.dart';
import '../models/PaginatedResult.dart';
import '../providers/PaymentMethodFilter.dart';
import '../utils/app_colors.dart';
import 'PaymentMethodCreateScreen.dart';
import 'PaymentMethodDetailScreen.dart';



class PaymentMethodListScreen extends ConsumerWidget {
  const PaymentMethodListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final methodsAsync = ref.watch(paymentMethodsProvider);
    final filterNotifier = ref.read(paymentMethodFilterProvider.notifier);
    final currentFilter = ref.watch(paymentMethodFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phương thức thanh toán'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Thêm mới',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PaymentMethodCreateScreen()),
              );
              if (result == true) {
                ref.refresh(paymentMethodsProvider);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại',
            onPressed: () => ref.refresh(paymentMethodsProvider),
          ),
        ],
      ),
      body: methodsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: kAdminAccentColor)),
        error: (err, st) => Center(child: Text('Lỗi tải dữ liệu: $err', style: const TextStyle(color: kAdminSecondaryTextColor))),
        data: (apiResult) {
          if (!apiResult.isSuccess || apiResult.data == null) {
            return Center(child: Text(apiResult.message ?? 'Đã có lỗi xảy ra.', style: const TextStyle(color: kAdminSecondaryTextColor)));
          }

          final response = apiResult.data!;
          if (response.items.isEmpty) {
            return const Center(child: Text('Không tìm thấy phương thức nào.', style: const TextStyle(color: kAdminSecondaryTextColor)));
          }

          return Column(
            children: [
              _buildFilterBar(context, currentFilter, filterNotifier),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = (constraints.maxWidth / 350).floor().clamp(1, 3);
                    return RefreshIndicator(
                      onRefresh: () => ref.refresh(paymentMethodsProvider.future),
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.1,
                        ),
                        itemCount: response.items.length,
                        itemBuilder: (context, index) {
                          final method = response.items[index];
                          // --- CẬP NHẬT LOGIC KHI NHẤN VÀO ---
                          return InkWell(
                            onTap: () async {
                              // Chờ kết quả trả về từ màn hình chi tiết
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PaymentMethodDetailScreen(methodId: method.id),
                                ),
                              );
                              // Nếu màn hình chi tiết trả về true (có nghĩa là đã có cập nhật)
                              // thì làm mới lại danh sách
                              if (result == true) {
                                ref.refresh(paymentMethodsProvider);
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: PaymentMethodCard(method: method),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              _buildPaginationControls(
                response: response,
                onPageChanged: (page) => filterNotifier.setPage(page),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, PaymentMethodFilter currentFilter, PaymentMethodFilterNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: kAdminCardColor.withOpacity(0.5),
      child: Row(
        children: const [
          Icon(Icons.filter_list, color: kAdminSecondaryTextColor),
          SizedBox(width: 8),
          Text("Bộ lọc sẽ được triển khai ở đây", style: TextStyle(color: kAdminSecondaryTextColor)),
        ],
      ),
    );
  }

  Widget _buildPaginationControls({
    required PaginatedResult response,
    required ValueChanged<int> onPageChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: kAdminCardColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: kAdminSecondaryTextColor),
            onPressed: response.hasPrevious ? () => onPageChanged(response.currentPage - 1) : null,
          ),
          Text('Trang ${response.currentPage} / ${response.totalPages}', style: const TextStyle(color: kAdminSecondaryTextColor)),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: kAdminSecondaryTextColor),
            onPressed: response.hasNext ? () => onPageChanged(response.currentPage + 1) : null,
          ),
        ],
      ),
    );
  }
}

