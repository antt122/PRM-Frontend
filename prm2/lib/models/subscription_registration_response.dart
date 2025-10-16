
class SubscriptionRegistrationResponse {
  final String paymentUrl;

  SubscriptionRegistrationResponse({required this.paymentUrl});

  factory SubscriptionRegistrationResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionRegistrationResponse(
      paymentUrl: json['paymentUrl'] as String,
    );
  }
}
