class UserStateResponse {
  final String userId;
  final String userProfileId;
  final String email;
  final List<String> roles;
  final String status;
  final DateTime lastLoginAt;
  final DateTime cacheUpdatedAt;
  final UserSubscriptionResponse? subscription;
  final bool isActive;
  final bool hasActiveSubscription;
  final bool isContentCreator;

  UserStateResponse({
    required this.userId,
    required this.userProfileId,
    required this.email,
    required this.roles,
    required this.status,
    required this.lastLoginAt,
    required this.cacheUpdatedAt,
    this.subscription,
    required this.isActive,
    required this.hasActiveSubscription,
    required this.isContentCreator,
  });

  factory UserStateResponse.fromJson(Map<String, dynamic> json) {
    return UserStateResponse(
      userId: json['userId'] as String,
      userProfileId: json['userProfileId'] as String,
      email: json['email'] as String,
      roles: List<String>.from(json['roles'] as List),
      status: json['status'] as String,
      lastLoginAt: DateTime.parse(json['lastLoginAt'] as String),
      cacheUpdatedAt: DateTime.parse(json['cacheUpdatedAt'] as String),
      subscription: json['subscription'] != null
          ? UserSubscriptionResponse.fromJson(
              json['subscription'] as Map<String, dynamic>,
            )
          : null,
      isActive: json['isActive'] as bool,
      hasActiveSubscription: json['hasActiveSubscription'] as bool,
      isContentCreator: json['isContentCreator'] as bool,
    );
  }
}

class UserSubscriptionResponse {
  final String subscriptionId;
  final String subscriptionPlanId;
  final String subscriptionPlanName;
  final String subscriptionPlanDisplayName;
  final int subscriptionStatus;
  final String subscriptionStatusName;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final DateTime? activatedAt;
  final DateTime? canceledAt;
  final bool isActive;
  final bool isExpired;

  UserSubscriptionResponse({
    required this.subscriptionId,
    required this.subscriptionPlanId,
    required this.subscriptionPlanName,
    required this.subscriptionPlanDisplayName,
    required this.subscriptionStatus,
    required this.subscriptionStatusName,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.activatedAt,
    this.canceledAt,
    required this.isActive,
    required this.isExpired,
  });

  factory UserSubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return UserSubscriptionResponse(
      subscriptionId: json['subscriptionId'] as String,
      subscriptionPlanId: json['subscriptionPlanId'] as String,
      subscriptionPlanName: json['subscriptionPlanName'] as String,
      subscriptionPlanDisplayName:
          json['subscriptionPlanDisplayName'] as String,
      subscriptionStatus: json['subscriptionStatus'] as int,
      subscriptionStatusName: json['subscriptionStatusName'] as String,
      currentPeriodStart: json['currentPeriodStart'] != null
          ? DateTime.parse(json['currentPeriodStart'] as String)
          : null,
      currentPeriodEnd: json['currentPeriodEnd'] != null
          ? DateTime.parse(json['currentPeriodEnd'] as String)
          : null,
      activatedAt: json['activatedAt'] != null
          ? DateTime.parse(json['activatedAt'] as String)
          : null,
      canceledAt: json['canceledAt'] != null
          ? DateTime.parse(json['canceledAt'] as String)
          : null,
      isActive: json['isActive'] as bool,
      isExpired: json['isExpired'] as bool,
    );
  }
}

class ContentCreatorStatusResponse {
  final bool isContentCreator;
  final String? reason;
  final DateTime checkedAt;
  final String source;

  ContentCreatorStatusResponse({
    required this.isContentCreator,
    this.reason,
    required this.checkedAt,
    required this.source,
  });

  factory ContentCreatorStatusResponse.fromJson(Map<String, dynamic> json) {
    return ContentCreatorStatusResponse(
      isContentCreator: json['isContentCreator'] as bool,
      reason: json['reason'] as String?,
      checkedAt: DateTime.parse(json['checkedAt'] as String),
      source: json['source'] as String,
    );
  }
}
