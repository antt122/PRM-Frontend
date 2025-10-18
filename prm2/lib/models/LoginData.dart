class LoginData {
  final String accessToken;
  final DateTime accessTokenExpiresAt;

  LoginData({
    required this.accessToken,
    required this.accessTokenExpiresAt,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      accessToken: json['accessToken'] as String? ?? '',
      accessTokenExpiresAt:
      DateTime.tryParse(json['accessTokenExpiresAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

