import 'package:get/get.dart';
import 'package:web_to_app/app/routes/app_routes.dart';

/// Ensures only one full-screen surface at a time:
/// IAP subscription > interstitial > app open.
class AdPresentationGate {
  AdPresentationGate._();

  /// True while the IAP route is active (or about to be).
  static bool iapVisible = false;

  /// True while an interstitial loader/ad is in progress.
  static bool interstitialBusy = false;

  /// True while an app-open ad is loading/showing.
  static bool appOpenBusy = false;

  static bool get isOnIapRoute {
    final route = Get.currentRoute;
    return route == AppRoutes.iap || route.startsWith('${AppRoutes.iap}?');
  }

  static bool get isIapActive => iapVisible || isOnIapRoute;

  /// Subscription screen takes priority — never stack an interstitial on it.
  static bool get canShowInterstitial => !isIapActive && !appOpenBusy;

  /// Never show app open on IAP, or while an interstitial is up.
  static bool get canShowAppOpen => !isIapActive && !interstitialBusy;

  static void markIapOpened() {
    iapVisible = true;
  }

  static void markIapClosed() {
    iapVisible = false;
  }

  /// Drop stale IAP locks when the user is no longer on the paywall.
  /// Call on resume so app-open can work again after leaving IAP.
  static void reconcileIapVisibility() {
    if (isOnIapRoute) {
      iapVisible = true;
      return;
    }
    iapVisible = false;
  }
}
