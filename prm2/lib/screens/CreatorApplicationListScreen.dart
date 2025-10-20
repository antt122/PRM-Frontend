import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/CreatorApplicationProvider.dart';
import '../utils/app_colors.dart';
import 'CreatorApplicationDetailScreen.dart';

class CreatorApplicationListScreen extends ConsumerWidget {
  const CreatorApplicationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsync = ref.watch(pendingApplicationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Đơn đăng ký Creator')),
      body: applicationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: kAdminAccentColor)),
        error: (err, st) => Center(child: Text('Lỗi tải dữ liệu: $err')),
        data: (apiResult) {
          if (!apiResult.isSuccess || apiResult.data == null) {
            return Center(child: Text(apiResult.message ?? 'Đã có lỗi xảy ra.'));
          }
          final applications = apiResult.data!;
          if (applications.isEmpty) {
            return const Center(child: Text('Không có đơn đăng ký nào đang chờ duyệt.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(pendingApplicationsProvider.future),
            child: ListView.separated(
              itemCount: applications.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: kAdminInputBorderColor),
              itemBuilder: (context, index) {
                final app = applications[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                  title: Text(app.userFullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(app.userEmail),
                  trailing: Text(DateFormat('dd/MM/yyyy').format(app.submittedAt), style: const TextStyle(color: kAdminSecondaryTextColor, fontSize: 12)),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreatorApplicationDetailScreen(applicationId: app.id)),
                    );
                    if (result == true) {
                      ref.refresh(pendingApplicationsProvider);
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
