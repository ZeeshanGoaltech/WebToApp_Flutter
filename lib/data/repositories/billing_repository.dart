import 'package:get/get.dart';
import 'package:web_to_app/core/api/api_client.dart';
import 'package:web_to_app/data/models/billing_models.dart';

class BillingRepository extends GetxService {
  BillingRepository(this._client);

  final ApiClient _client;

  Future<EntitlementDto> entitlement() => _client.get<EntitlementDto>(
        '/v1/billing/entitlement',
        parser: (json) => EntitlementDto.fromJson(json as Map<String, dynamic>),
      );

  Future<CheckoutSessionResponse> createCheckoutSession() =>
      _client.post<CheckoutSessionResponse>(
        '/v1/billing/stripe/checkout-session',
        parser: (json) =>
            CheckoutSessionResponse.fromJson(json as Map<String, dynamic>),
      );
}
