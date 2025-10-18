// File: lib/models/update_subscription_request.dart

class UpdateSubscriptionRequest {
  final int? subscriptionStatus;
  final int? renewalBehavior;
  final bool? cancelAtPeriodEnd;
  final String? currentPeriodEnd; // Gửi dưới dạng chuỗi ISO 8601

  UpdateSubscriptionRequest({
    this.subscriptionStatus,
    this.renewalBehavior,
    this.cancelAtPeriodEnd,
    this.currentPeriodEnd,
  });

  /// Chuyển đổi object thành một Map<String, dynamic> để gửi đi dưới dạng JSON.
  /// Chỉ những trường không null mới được thêm vào map (hỗ trợ partial update).
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (subscriptionStatus != null) {
      data['subscriptionStatus'] = subscriptionStatus;
    }
    if (renewalBehavior != null) {
      data['renewalBehavior'] = renewalBehavior;
    }
    if (cancelAtPeriodEnd != null) {
      data['cancelAtPeriodEnd'] = cancelAtPeriodEnd;
    }
    if (currentPeriodEnd != null) {
      data['currentPeriodEnd'] = currentPeriodEnd;
    }
    return data;
  }
}
