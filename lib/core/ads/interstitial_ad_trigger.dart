import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/ads/ad_placements.dart';
import 'package:web_to_app/core/ads/ad_presentation_gate.dart';
import 'package:web_to_app/core/ads/ad_service.dart';
import 'package:web_to_app/core/ads/widgets/ad_loading_dialog.dart';
import 'package:web_to_app/core/services/premium_service.dart';
import 'package:web_to_app/core/services/session_service.dart';

/// Shows interstitial ads with a loading overlay UX.
class InterstitialAdTrigger {
  InterstitialAdTrigger._();

  static final Set<String> _currentlyShowing = {};

  /// Session flag — resets when the process is killed.
  static bool _firstClickShownThisSession = false;
  static bool _firstClickInFlight = false;
  static DateTime? _homeProTapAt;

  static bool get _isPremium {
    if (Get.isRegistered<SessionService>() &&
        Get.find<SessionService>().hasPremiumAccess) {
      return true;
    }
    return PremiumService.isPremiumCached;
  }

  /// Call from the Home Pro button so that tap does not trigger 1st-click inter.
  static void markHomeProTap() {
    _homeProTapAt = DateTime.now();
  }

  /// Home-screen first click interstitial — once per app session.
  /// Skips when the Pro button was just tapped.
  static Future<void> showFirstClickInterstitialIfNeeded() async {
    if (_isPremium) return;
    if (_firstClickShownThisSession || _firstClickInFlight) return;

    final proTapAt = _homeProTapAt;
    if (proTapAt != null &&
        DateTime.now().difference(proTapAt) < const Duration(milliseconds: 800)) {
      return;
    }

    if (!AdPresentationGate.canShowInterstitial) {
      developer.log(
        '[InterstitialAdTrigger] skip first_click — IAP/app-open active',
      );
      return;
    }

    _firstClickInFlight = true;
    try {
      final shown = await showPlacement(
        placementId: AdPlacements.firstClickInter,
      );
      if (shown) {
        _firstClickShownThisSession = true;
      }
    } finally {
      _firstClickInFlight = false;
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
