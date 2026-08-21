import 'package:get/get.dart';
import 'package:web_to_app/app/routes/app_routes.dart';
import 'package:web_to_app/core/ads/ad_presentation_gate.dart';
import 'package:web_to_app/core/ads/ad_remote_config_service.dart';
import 'package:web_to_app/core/ads/app_open_ad_manager.dart';
import 'package:web_to_app/core/services/session_service.dart';

/// Centralizes cold-start and post-auth navigation into the paywall/home.
class LaunchFlow {
  LaunchFlow._();

  static bool _iapFromLaunch = false;

  /// True while the subscription screen was opened from cold-start / splash.
  static bool get iapOpenedFromLaunch => _iapFromLaunch;

  /// IAP when RC `splash_sub` is true and user is not premium.
  static bool shouldShowIap() {
    if (Get.find<SessionService>().hasPremiumAccess) return false;
    return AdRemoteConfigService.instance.isPlacementEnabled(
      RemoteConfigKeys.splashSub,
    );
  }

  static void _enterIap() {
    AdPresentationGate.markIapOpened();
    AppOpenAdManager.instance.blockAppOpenAds = true;
  }

  static void _leaveIap() {
    AdPresentationGate.markIapClosed();
    AdPresentationGate.reconcileIapVisibility();
    AppOpenAdManager.instance.blockAppOpenAds = false;
  }

  static void openIapFromLaunch() {
    if (!shouldShowIap()) {
      goHome();
      return;
    }
    _iapFromLaunch = true;
    _enterIap();
    Get.offAllNamed(AppRoutes.iap);
  }

  static void openIapFromSettings() {
    // Prefer subscription over any interstitial / app-open.
    _enterIap();
    Get.toNamed(AppRoutes.iap);
  }

  static void completeIap() {
    _leaveIap();
    if (_iapFromLaunch) {
      _iapFromLaunch = false;
      final hasSession = Get.find<SessionService>().hasActiveSession;
      Get.offAllNamed(hasSession ? AppRoutes.home : AppRoutes.auth);
      // Ensure locks are cleared after route swap.
      AdPresentationGate.reconcileIapVisibility();
      AppOpenAdManager.instance.blockAppOpenAds = false;
      return;
    }
    Get.back();
    // After pop, route may update on next frame.
    Future<void>.microtask(() {
      AdPresentationGate.reconcileIapVisibility();
      AppOpenAdManager.instance.blockAppOpenAds =
          AdPresentationGate.isOnIapRoute;
    });
  }

  /// Logged-in cold start: paywall then home.
  static void goHomeOrIap() {
    if (shouldShowIap()) {
      openIapFromLaunch();
    } else {
      goHome();
    }
  }

  /// No session: paywall then auth (before login).
  static void goAuthOrIap() {
    if (shouldShowIap()) {
      _iapFromLaunch = true;
      _enterIap();
      Get.offAllNamed(AppRoutes.iap);
    } else {
      goAuth();
    }
  }

  static void goHome() => Get.offAllNamed(AppRoutes.home);

  static void goAuth() => Get.offAllNamed(AppRoutes.auth);
}
