import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/CreatorApplicationDetail.dart';
import '../models/CreatorApplicationListItem.dart';
import '../models/ApiResult.dart';

import '../services/api_service.dart';

// Cung cấp một instance của ApiService
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Lấy danh sách các đơn đang chờ
final pendingApplicationsProvider = FutureProvider.autoDispose<ApiResult<List<CreatorApplicationListItem>>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getPendingApplications();
});

// Lấy chi tiết một đơn theo ID
final applicationDetailProvider = FutureProvider.autoDispose.family<ApiResult<CreatorApplicationDetail>, String>((ref, applicationId) {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getApplicationDetails(applicationId);
});
