import 'package:get/get.dart';
import 'package:web_to_app/app/routes/app_routes.dart';
import 'package:web_to_app/core/services/credit_service.dart';

/// Ensures local credits before API actions; opens pack paywall when empty.
/// Subscription paywall (`/iap`) stays separate.
class CreditGate {
  CreditGate._();

  static Future<bool> ensureOrOpenPaywall() async {
    if (await CreditService.instance.canUse()) return true;

    final bought = await Get.toNamed(AppRoutes.creditsPack);
    if (bought != true) return false;
    return CreditService.instance.canUse();
  }

  static Future<bool> consumeAfterSuccess() => CreditService.instance.consume();
}
