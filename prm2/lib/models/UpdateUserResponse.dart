// Model để chứa dữ liệu trả về sau khi cập nhật thông tin người dùng
class UpdateUserResponse {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? address;
  final int status;
  final List<String> roles;

  UpdateUserResponse({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.address,
    required this.status,
    required this.roles,
  });

  factory UpdateUserResponse.fromJson(Map<String, dynamic> json) {
    return UpdateUserResponse(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String?,
      address: json['address'] as String?,
      status: json['status'] as int? ?? 1, // Mặc định Inactive
      roles: List<String>.from(json['roles'] as List? ?? []),
    );
  }
}
