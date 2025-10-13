class ApiResult<T> {
  final bool isSuccess;
  final String? message;
  final T? data;
  final List<String>? errors;
  final String? errorCode;

  ApiResult({
    required this.isSuccess,
    this.message,
    this.data,
    this.errors,
    this.errorCode,
  });

  // Factory constructor để parse JSON thành một đối tượng ApiResult
  // Nó cần một hàm (fromJsonT) để biết cách parse trường 'data'
  factory ApiResult.fromJson(
      Map<String, dynamic> json,
      T Function(Object? jsonData) fromJsonT,
      ) {
    return ApiResult<T>(
      isSuccess: json['isSuccess'] as bool,
      message: json['message'] as String?,
      // Chỉ gọi fromJsonT nếu 'data' không null
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      // Chuyển đổi List<dynamic> thành List<String> một cách an toàn
      errors: (json['errors'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      errorCode: json['errorCode'] as String?,
    );
  }
}
