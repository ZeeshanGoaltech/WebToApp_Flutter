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

  /// Brief window after AdActivity closes — swallows a trailing system back
  /// that Android sometimes delivers into Flutter. Short on purpose so back
  /// works again once the user dismisses via the ad's own close control.
  static DateTime? _blockBackUntil;

  /// Block Flutter/system-back navigation while inter/app-open load or show,
  /// plus a short post-dismiss grace (not permanent).
  static bool get shouldBlockBack {
    if (interstitialBusy || appOpenBusy) return true;
    final until = _blockBackUntil;
    if (until != null && DateTime.now().isBefore(until)) return true;
    return false;
  }

  /// Call when a fullscreen interstitial / app-open finishes (dismiss or fail).
  static void markFullscreenAdClosed() {
    _blockBackUntil = DateTime.now().add(const Duration(milliseconds: 800));
  }

  static bool get isOnIapRoute {
    final route = Get.currentRoute;
    return route == AppRoutes.iap ||
        route.startsWith('${AppRoutes.iap}?') ||
        route == AppRoutes.lifetimePremium ||
        route.startsWith('${AppRoutes.lifetimePremium}?') ||
        route == AppRoutes.downloadInApp ||
        route.startsWith('${AppRoutes.downloadInApp}?') ||
        route == AppRoutes.creditsPack ||
        route.startsWith('${AppRoutes.creditsPack}?');
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
