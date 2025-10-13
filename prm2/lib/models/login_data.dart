class LoginData {
  final String accessToken;
  final String expiresAt;
  final List<String> roles;

  LoginData({
    required this.accessToken,
    required this.expiresAt,
    required this.roles,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      accessToken: json['accessToken'] as String,
      expiresAt: json['expiresAt'] as String,
      // Chuyển đổi List<dynamic> thành List<String> một cách an toàn
      roles: List<String>.from(json['roles'] as List),
    );
  }
}