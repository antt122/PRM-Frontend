import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/PaginatedResult.dart';
import '../models/PaymentMethod.dart';
import '../models/PaymentMethodDetail.dart';
import '../models/ApiResult.dart';
import '../services/PaymentService.dart';


// Lớp trạng thái cho bộ lọc
@immutable
class PaymentMethodFilter {
  final int page;
  final int pageSize;
  final String? search;
  final String? providerName;
  final String? status;
  final int? type;
  final String sortBy;
  final bool isAscending;

  const PaymentMethodFilter({
    this.page = 1,
    this.pageSize = 10,
    this.search,
    this.providerName,
    this.status,
    this.type,
    this.sortBy = 'createdAt',
    this.isAscending = false,
  });

  PaymentMethodFilter copyWith({
    int? page, int? pageSize, String? search, String? providerName,
    String? status, int? type, String? sortBy, bool? isAscending,
  }) {
    return PaymentMethodFilter(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
      providerName: providerName ?? this.providerName,
      status: status ?? this.status,
      type: type ?? this.type,
      sortBy: sortBy ?? this.sortBy,
      isAscending: isAscending ?? this.isAscending,
    );
  }
}

// Notifier quản lý bộ lọc
class PaymentMethodFilterNotifier extends StateNotifier<PaymentMethodFilter> {
  PaymentMethodFilterNotifier() : super(const PaymentMethodFilter());

  void setFilter(PaymentMethodFilter filter) {
    state = filter.copyWith(page: 1);
  }

  void setPage(int page) {
    state = state.copyWith(page: page);
  }
}

final paymentMethodFilterProvider = StateNotifierProvider<PaymentMethodFilterNotifier, PaymentMethodFilter>((ref) {
  return PaymentMethodFilterNotifier();
});

// Provider cung cấp service
final paymentMethodServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService();
});

// Provider chính để lấy dữ liệu
final paymentMethodsProvider = FutureProvider.autoDispose<ApiResult<PaginatedResult<PaymentMethod>>>((ref) async {
  final filter = ref.watch(paymentMethodFilterProvider);
  final service = ref.watch(paymentMethodServiceProvider);
  return service.getPaymentMethods(filter);
});

// Sử dụng .family để có thể truyền id vào
final paymentMethodDetailProvider = FutureProvider.autoDispose.family<ApiResult<PaymentMethodDetail>, String>((ref, id) {
  final service = ref.watch(paymentMethodServiceProvider);
  return service.getPaymentMethodDetail(id);
});