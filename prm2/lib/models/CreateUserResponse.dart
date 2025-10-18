class CreateUserResponse {
  final String userProfileId;
  final String email;
  final String fullName;

  CreateUserResponse({
    required this.userProfileId,
    required this.email,
    required this.fullName,
  });

  factory CreateUserResponse.fromJson(Map<String, dynamic> json) {
    return CreateUserResponse(
      userProfileId: json['userProfileId'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
    );
  }
}
