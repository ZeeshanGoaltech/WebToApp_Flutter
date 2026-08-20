class EntitlementDto {
  const EntitlementDto({
    required this.active,
    required this.status,
    required this.canBuildNew,
    this.provider,
    this.currentPeriodEnd,
  });

  final bool active;
  final String status;
  final bool canBuildNew;
  final String? provider;
  final DateTime? currentPeriodEnd;

  bool get isPremium => active;

  factory EntitlementDto.fromJson(Map<String, dynamic> json) => EntitlementDto(
        active: json['active'] as bool,
        status: json['status'] as String,
        canBuildNew: json['canBuildNew'] as bool,
        provider: json['provider'] as String?,
        currentPeriodEnd: json['currentPeriodEnd'] != null
            ? DateTime.tryParse(json['currentPeriodEnd'] as String)
            : null,
      );
}

class CheckoutSessionResponse {
  const CheckoutSessionResponse({
    required this.sessionId,
    this.checkoutUrl,
  });

  final String sessionId;
  final String? checkoutUrl;

  factory CheckoutSessionResponse.fromJson(Map<String, dynamic> json) =>
      CheckoutSessionResponse(
        sessionId: json['sessionId'] as String,
        checkoutUrl: json['checkoutUrl'] as String?,
      );
}
