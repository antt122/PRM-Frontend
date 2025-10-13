class UserProfile {
  // --- CÁC TRƯỜNG ĐÃ KHỚP VỚI API THẬT ---
  final String fullName;
  final String email;
  final String phoneNumber; // API có thể trả về null
  final String address;     // API có thể trả về null


  UserProfile({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.address,

  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // Trích xuất dữ liệu từ trường 'data' bên trong response
    final data = json['data'] as Map<String, dynamic>? ?? {};

    return UserProfile(
      fullName: data['fullName'] as String? ?? 'Chưa có tên',
      email: data['email'] as String? ?? 'Chưa có email',
      phoneNumber: data['phoneNumber'] as String? ?? '', // Giữ nguyên null nếu không có
      address: data['address'] as String? ?? '',
    );
  }
}

