import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/ads/ad_placements.dart';
import 'package:web_to_app/core/ads/ad_presentation_gate.dart';
import 'package:web_to_app/core/ads/ad_remote_config_service.dart';
import 'package:web_to_app/core/ads/ad_service.dart';
import 'package:web_to_app/core/ads/interstitial_counter_service.dart';
import 'package:web_to_app/core/ads/widgets/ad_loading_dialog.dart';
import 'package:web_to_app/core/services/premium_service.dart';
import 'package:web_to_app/core/services/session_service.dart';

/// Shows interstitial ads with the same loading overlay UX as Ummah_Pro_Exis.
class InterstitialAdTrigger {
  InterstitialAdTrigger._();

  static final Set<String> _currentlyShowing = {};

  static bool get _isPremium {
    if (Get.isRegistered<SessionService>() &&
        Get.find<SessionService>().hasPremiumAccess) {
      return true;
    }
    return PremiumService.isPremiumCached;
  }

  /// Bottom-tab interstitial with RC frequency (`project_native`: `off, 1, 2, 3…`).
  static Future<void> showBottomTabInterstitial() =>
      showFrequencyInterstitial(AdPlacements.projectNative);

  /// Generate Bundle & APK interstitial (`generatebundleapk_inter`).
  static Future<void> showGenerateBundleApkInterstitial() =>
      showFrequencyInterstitial(AdPlacements.generateBundleApkInter);

  /// Build Again interstitial (`buildagain_inter`).
  static Future<void> showBuildAgainInterstitial() =>
      showFrequencyInterstitial(AdPlacements.buildAgainInter);

  /// Frequency-gated interstitial: `off` / `1` / `2` / `off, 1, 2, 3, 4`.
  static Future<void> showFrequencyInterstitial(String placementId) async {
    if (_isPremium) return;
    if (!AdPresentationGate.canShowInterstitial) {
      developer.log(
        '[InterstitialAdTrigger] skip $placementId — IAP/app-open active',
      );
      return;
    }
    if (_currentlyShowing.contains(placementId)) return;

    final thresholds =
        AdRemoteConfigService.instance.getFrequencyThresholds(placementId);
    if (thresholds.isEmpty) {
      developer.log('[InterstitialAdTrigger] $placementId frequency off');
      return;
    }

    final countAfter =
        await InterstitialCounterService.instance.increment(placementId);
    final maxFrequency = thresholds.reduce((a, b) => a > b ? a : b);

    developer.log(
      '[InterstitialAdTrigger] $placementId count=$countAfter '
      'thresholds=$thresholds',
    );

    if (countAfter > maxFrequency) {
      await InterstitialCounterService.instance.reset(placementId);
      return;
    }

    if (!thresholds.contains(countAfter)) return;

    // Re-check after async counter work — IAP may have opened.
    if (!AdPresentationGate.canShowInterstitial) return;

    final shown = await showPlacement(placementId: placementId);
    if (shown) {
      await InterstitialCounterService.instance.reset(placementId);
    }
  }

  /// Show [placementId] with a loading dialog, then the interstitial.
  /// Returns true if the ad was shown and dismissed.
  /// [showLoader] defaults to true; splash interstitials pass false
  /// (splash already discloses that ads may appear).
  /// Premium / Pro users never see the loader or the ad.
  static Future<bool> showPlacement({
    required String placementId,
    Future<void> Function()? onAdClosed,
    bool forceFetchRc = false,
    bool? showLoader,
  }) async {
    if (_isPremium) {
      developer.log('[InterstitialAdTrigger] premium — skip $placementId');
      await onAdClosed?.call();
      return false;
    }

    if (!AdPresentationGate.canShowInterstitial) {
      developer.log(
        '[InterstitialAdTrigger] skip $placementId — IAP/app-open active',
      );
      await onAdClosed?.call();
      return false;
    }

    if (_currentlyShowing.contains(placementId)) {
      developer.log(
        '[InterstitialAdTrigger] $placementId already showing — skip',
      );
      await onAdClosed?.call();
      return false;
    }

    final useLoader = showLoader ?? !_isSplashInterstitial(placementId);

    _currentlyShowing.add(placementId);
    AdPresentationGate.interstitialBusy = true;
    var success = false;

    try {
      await _enableFullScreenForAds();

      // Final gate before loader (subscription wins if opened meanwhile).
      if (!AdPresentationGate.canShowInterstitial) {
        developer.log(
          '[InterstitialAdTrigger] abort $placementId — IAP opened',
        );
        return false;
      }

      final context = Get.overlayContext ?? Get.context;
      var loaderVisible = false;

      if (useLoader && context != null && context.mounted) {
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black.withValues(alpha: 0.5),
          useRootNavigator: true,
          builder: (_) => const AdLoadingDialog(),
        );
        loaderVisible = true;
      }

      var loaderDismissed = false;

      void dismissLoader() {
        if (!loaderVisible || loaderDismissed) return;
        final ctx = Get.overlayContext ?? Get.context;
        if (ctx != null && ctx.mounted) {
          Navigator.of(ctx, rootNavigator: true).pop();
        }
        loaderDismissed = true;
        loaderVisible = false;
      }

      success = await AdService.instance.showInterstitial(
        placementId,
        forceFetchRc: forceFetchRc,
        onAdShown: dismissLoader,
      );

      dismissLoader();

      if (!success) {
        await _restoreSystemUI();
      }

      developer.log(
        '[InterstitialAdTrigger] $placementId done (shown=$success)',
      );
    } catch (e) {
      developer.log('[InterstitialAdTrigger] error: $e');
      await _restoreSystemUI();
      success = false;
    } finally {
      _currentlyShowing.remove(placementId);
      AdPresentationGate.interstitialBusy = _currentlyShowing.isNotEmpty;
      await onAdClosed?.call();
    }
    return success;
  }

  static bool _isSplashInterstitial(String placementId) =>
      placementId == AdPlacements.splashInter1st ||
      placementId == AdPlacements.splashInter2nd;

  static Future<void> _enableFullScreenForAds() async {
    try {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );
    } catch (_) {}
  }

  static Future<void> _restoreSystemUI() async {
    try {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
        ),
      );
    } catch (_) {}
  }
}
