import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:web_to_app/app/routes/app_routes.dart';
import 'package:web_to_app/core/ads/ad_placements.dart';
import 'package:web_to_app/core/ads/ad_presentation_gate.dart';
import 'package:web_to_app/core/ads/ad_remote_config_service.dart';
import 'package:web_to_app/core/ads/ad_service.dart';
import 'package:web_to_app/core/ads/ads_consent_gate.dart';
import 'package:web_to_app/core/ads/widgets/ad_loading_dialog.dart';
import 'package:web_to_app/core/services/premium_service.dart';
import 'package:web_to_app/core/services/session_service.dart';

/// App Open ads on resume (same pattern as Ummah_Pro_Exis, GetX-friendly).
/// RC key: [AdPlacements.appOpen] (`appopen`).
class AppOpenAdManager {
  AppOpenAdManager._();

  static final AppOpenAdManager instance = AppOpenAdManager._();

  static const _placementId = AdPlacements.appOpen;

  DateTime? _lastDismissTime;
  DateTime? _lastShownTime;
  DateTime? _lastInterstitialDismissTime;
  DateTime? _lastExternalActionTime;

  bool _isShowing = false;
  bool _isResuming = false;
  bool blockAppOpenAds = false;

  /// One-shot: skip the next real background→resume open-ad attempt.
  /// Used for rate-us, terms, privacy, share, store / external links.
  bool _skipNextResume = false;

  /// While true (e.g. rate-us dialog), never show an app-open ad.
  bool suppressWhileOverlay = false;

  /// Block app open ad on the next resume after external actions
  /// (rate us → store, privacy, terms, share app, leave IAP, etc.).
  /// One-shot + cooldown so a long Play Store / browser visit still skips.
  void blockNextResume() {
    _skipNextResume = true;
    _lastExternalActionTime = DateTime.now();
  }

  /// Set only on real [AppLifecycleState.paused] (Home / app switch).
  bool _wasBackgrounded = false;

  bool get _isPremium {
    if (Get.isRegistered<SessionService>() &&
        Get.find<SessionService>().hasPremiumAccess) {
      return true;
    }
    return PremiumService.isPremiumCached;
  }

  /// Call from lifecycle [paused] only — not inactive/hidden.
  void pause() {
    // Keep IAP block in sync with the real route (avoids sticky lock).
    _reconcileIapBlock();

    if (_isShowing || AdPresentationGate.appOpenBusy) {
      developer.log('[AppOpen] pause ignored — ad already showing');
      return;
    }
    if (AdPresentationGate.interstitialBusy) {
      developer.log('[AppOpen] pause ignored — interstitial busy');
      return;
    }
    // Only skip while the paywall is actually on screen (not a stale flag).
    if (_isBlockedSubscriptionRoute) {
      developer.log('[AppOpen] pause ignored — on IAP route');
      return;
    }
    _wasBackgrounded = true;
    developer.log('[AppOpen] backgrounded');
  }

  void onInterstitialDismissed() {
    _lastInterstitialDismissTime = DateTime.now();
    _wasBackgrounded = false;
  }

  /// Clear sticky IAP blocks when no longer on a paywall.
  /// Keeps a pre-navigation lock ([AdPresentationGate.iapVisible]) so open ads
  /// cannot fire during Get.toNamed → /iap.
  void _reconcileIapBlock() {
    if (AdPresentationGate.isOnIapRoute) {
      AdPresentationGate.iapVisible = true;
      blockAppOpenAds = true;
      return;
    }
    if (AdPresentationGate.iapVisible) {
      blockAppOpenAds = true;
      return;
    }
    if (blockAppOpenAds) {
      developer.log(
        '[AppOpen] clearing stale IAP block (route=${Get.currentRoute})',
      );
    }
    blockAppOpenAds = false;
  }

  bool get _hasBlockingOverlay {
    if (suppressWhileOverlay) return true;
    if (Get.isDialogOpen == true) return true;
    if (Get.isBottomSheetOpen == true) return true;
    return false;
  }

  bool get _isBlockedSubscriptionRoute {
    final route = Get.currentRoute;
    return route == AppRoutes.iap ||
        route.startsWith('${AppRoutes.iap}?') ||
        route == AppRoutes.lifetimePremium ||
        route.startsWith('${AppRoutes.lifetimePremium}?') ||
        route == AppRoutes.downloadInApp ||
        route.startsWith('${AppRoutes.downloadInApp}?') ||
        route == AppRoutes.creditsPack ||
        route.startsWith('${AppRoutes.creditsPack}?') ||
        AdPresentationGate.isIapActive;
  }

  /// Call from app lifecycle `resumed` (skip cold start / splash).
  Future<void> resume() async {
    _reconcileIapBlock();

    if (!_wasBackgrounded) {
      developer.log('[AppOpen] resume skip — not backgrounded');
      return;
    }
    _wasBackgrounded = false;

    // Consume one-shot skip from rate-us / terms / privacy / share / store.
    if (_skipNextResume) {
      _skipNextResume = false;
      developer.log('[AppOpen] resume skip — external action (one-shot)');
      return;
    }

    if (_isResuming || _isShowing || blockAppOpenAds) {
      developer.log(
        '[AppOpen] resume skip — busy '
        '(resuming=$_isResuming showing=$_isShowing block=$blockAppOpenAds)',
      );
      return;
    }
    if (_hasBlockingOverlay) {
      developer.log('[AppOpen] resume skip — dialog/overlay open');
      return;
    }
    if (_isPremium) {
      developer.log('[AppOpen] resume skip — premium');
      return;
    }
    if (!AdPresentationGate.canShowAppOpen || _isBlockedSubscriptionRoute) {
      developer.log('[AppOpen] skip — IAP or interstitial active');
      return;
    }

    final route = Get.currentRoute;
    if (route == AppRoutes.splash ||
        route == AppRoutes.iap ||
        route == AppRoutes.lifetimePremium ||
        route == AppRoutes.downloadInApp ||
        route == AppRoutes.creditsPack ||
        route == AppRoutes.intro ||
        route == AppRoutes.language ||
        route == AppRoutes.auth ||
        route == AppRoutes.createApp ||
        route == AppRoutes.buildApp) {
      developer.log('[AppOpen] skip — route=$route');
      return;
    }

    if (AdService.instance.isShowing(AdPlacements.splashInter1st) ||
        AdService.instance.isShowing(AdPlacements.splashInter2nd) ||
        AdService.instance.isShowing(AdPlacements.createAppInter) ||
        AdService.instance.isShowing(AdPlacements.generateBundleApkInter) ||
        AdService.instance.isShowing(AdPlacements.buildAgainInter) ||
        AdService.instance.isShowing(AdPlacements.goToHomeInter) ||
        AdService.instance.isShowing(AdPlacements.projectNative)) {
      developer.log('[AppOpen] skip — interstitial showing');
      return;
    }

    final now = DateTime.now();

    if (_lastDismissTime != null &&
        now.difference(_lastDismissTime!) < const Duration(seconds: 30)) {
      developer.log('[AppOpen] skip — dismiss cooldown');
      return;
    }

    if (_lastShownTime != null &&
        now.difference(_lastShownTime!) < const Duration(seconds: 5)) {
      developer.log('[AppOpen] skip — show cooldown');
      return;
    }

    if (_lastInterstitialDismissTime != null &&
        now.difference(_lastInterstitialDismissTime!) <
            const Duration(seconds: 5)) {
      developer.log('[AppOpen] skip — post-interstitial cooldown');
      return;
    }

    // Long visits to Play Store / browser (rate, terms, privacy, share).
    if (_lastExternalActionTime != null &&
        now.difference(_lastExternalActionTime!) <
            const Duration(minutes: 5)) {
      developer.log('[AppOpen] skip — post-external-action cooldown');
      return;
    }

    if (!AdRemoteConfigService.instance.isPlacementEnabled(_placementId)) {
      developer.log('[AppOpen] RC disabled: $_placementId');
      return;
    }

    if (!AdConfig.isEnabled(_placementId)) return;

    final adUnitId = AdConfig.unitIdFor(_placementId);
    if (adUnitId == null || adUnitId.isEmpty) return;

    _isResuming = true;
    try {
      await Future<void>.delayed(
        Duration(milliseconds: kReleaseMode ? 300 : 100),
      );

      if (blockAppOpenAds ||
          _skipNextResume ||
          _hasBlockingOverlay ||
          !AdPresentationGate.canShowAppOpen ||
          _isBlockedSubscriptionRoute) {
        developer.log('[AppOpen] abort after delay — IAP/overlay/interstitial');
        return;
      }

      await _loadAndShow(adUnitId);
    } finally {
      _isResuming = false;
    }
  }

  Future<void> _loadAndShow(String adUnitId) async {
    if (_isShowing) return;
    if (_isPremium) {
      developer.log('[AppOpen] load skip — premium');
      return;
    }
    if (!AdPresentationGate.canShowAppOpen ||
        _isBlockedSubscriptionRoute ||
        _hasBlockingOverlay ||
        _skipNextResume) {
      return;
    }

    _isShowing = true;
    AdPresentationGate.appOpenBusy = true;

    final context = Get.overlayContext ?? Get.context;
    var loaderVisible = false;

    void dismissLoader() {
      if (!loaderVisible) return;
      final ctx = Get.overlayContext ?? Get.context;
      if (ctx != null && ctx.mounted) {
        try {
          Navigator.of(ctx, rootNavigator: true).pop();
        } catch (_) {}
      }
      loaderVisible = false;
    }

    void releaseBusy() {
      _isShowing = false;
      AdPresentationGate.appOpenBusy = false;
    }

    try {
      if (context != null && context.mounted) {
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black.withValues(alpha: 0.5),
          useRootNavigator: true,
          builder: (_) => const AdLoadingDialog(),
        );
        loaderVisible = true;
      }

      if (!AdService.instance.isInitialized) {
        await AdService.instance.initialize();
      }

      if (!AdsConsentGate.mayRequestAds) {
        developer.log('[AppOpen] UMP blocked');
        dismissLoader();
        releaseBusy();
        return;
      }

      developer.log(
        '[AppOpen] loading $_placementId → $adUnitId (debug=$kDebugMode)',
      );

      final completer = Completer<AppOpenAd?>();
      AppOpenAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            developer.log('[AppOpen] loaded');
            if (!completer.isCompleted) completer.complete(ad);
          },
          onAdFailedToLoad: (error) {
            developer.log(
              '[AppOpen] load failed: ${error.code} ${error.message}',
            );
            if (!completer.isCompleted) completer.complete(null);
          },
        ),
      );

      final ad = await completer.future.timeout(
        Duration(seconds: kReleaseMode ? 12 : 8),
        onTimeout: () {
          developer.log('[AppOpen] load timeout');
          return null;
        },
      );

      dismissLoader();

      if (ad == null) {
        releaseBusy();
        return;
      }

      if (!AdPresentationGate.canShowAppOpen ||
          _isBlockedSubscriptionRoute ||
          blockAppOpenAds ||
          _hasBlockingOverlay ||
          _skipNextResume) {
        developer.log('[AppOpen] discard loaded ad — IAP/overlay active');
        try {
          ad.dispose();
        } catch (_) {}
        releaseBusy();
        return;
      }

      final shown = Completer<void>();
      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (_) {
          _lastShownTime = DateTime.now();
          developer.log('[AppOpen] showed');
        },
        onAdDismissedFullScreenContent: (dismissed) {
          developer.log('[AppOpen] dismissed');
          _lastDismissTime = DateTime.now();
          releaseBusy();
          AdPresentationGate.markFullscreenAdClosed();
          try {
            dismissed.dispose();
          } catch (_) {}
          if (!shown.isCompleted) shown.complete();
        },
        onAdFailedToShowFullScreenContent: (failed, error) {
          developer.log('[AppOpen] failed to show: ${error.message}');
          releaseBusy();
          AdPresentationGate.markFullscreenAdClosed();
          try {
            failed.dispose();
          } catch (_) {}
          if (!shown.isCompleted) shown.complete();
        },
      );

      // Android only; never block show if the channel call fails.
      try {
        await ad.setImmersiveMode(true);
      } catch (_) {}
      await ad.show();
      await shown.future.timeout(
        const Duration(seconds: 60),
        onTimeout: () {},
      );
    } catch (e) {
      developer.log('[AppOpen] error: $e');
      dismissLoader();
      releaseBusy();
    }
  }

  void dispose() {
    _isShowing = false;
    _isResuming = false;
    _wasBackgrounded = false;
    _skipNextResume = false;
    suppressWhileOverlay = false;
    AdPresentationGate.appOpenBusy = false;
  }
}
