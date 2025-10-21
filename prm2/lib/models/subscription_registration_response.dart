class SubscriptionRegistrationResponse {
  final String paymentUrl;
  final String? appLink; // ✅ MoMo DeepLinkWebInApp for in-app browser
  final String? deepLink; // ✅ MoMo DeepLink for external app
  final String? redirectUrl; // ✅ Custom redirect URL based on client type
  final String? qrCodeBase64; // ✅ QR Code for display

  SubscriptionRegistrationResponse({
    required this.paymentUrl,
    this.appLink,
    this.deepLink,
    this.redirectUrl,
    this.qrCodeBase64,
  });

  factory SubscriptionRegistrationResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionRegistrationResponse(
      paymentUrl: json['paymentUrl'] as String,
      appLink: json['appLink'] as String?, // ✅ For in-app browser
      deepLink: json['deepLink'] as String?, // ✅ For external app
      redirectUrl: json['redirectUrl'] as String?, // ✅ Custom redirect URL
      qrCodeBase64: json['qrCodeBase64'] as String?, // ✅ QR Code
    );
  }
}
