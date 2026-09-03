import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/ads/ad_placements.dart';
import 'package:web_to_app/core/ads/ad_presentation_gate.dart';
import 'package:web_to_app/core/ads/ad_service.dart';
import 'package:web_to_app/core/ads/widgets/ad_loading_overlay.dart';
import 'package:web_to_app/core/services/premium_service.dart';
import 'package:web_to_app/core/services/session_service.dart';

/// Shows interstitial ads with a loading overlay UX.
class InterstitialAdTrigger {
  InterstitialAdTrigger._();

  static final Set<String> _currentlyShowing = {};

  /// Session flag — resets when the process is killed.
  static bool _buildAppShownThisSession = false;
  static Future<void>? _buildAppFuture;

  static bool get _isPremium {
    if (Get.isRegistered<SessionService>() &&
        Get.find<SessionService>().hasPremiumAccess) {
      return true;
    }
    return PremiumService.isPremiumCached;
  }

  /// True while the once-per-session Build App interstitial is loading/showing.
  static bool get isBuildAppInterInFlight => _buildAppFuture != null;

  /// Live Preview "Build App" interstitial — once per app session.
  /// Concurrent callers share the same in-flight Future (so navigation can wait).
  static Future<void> showBuildAppInterstitialIfNeeded() async {
    if (_isPremium) return;
    if (_buildAppShownThisSession) return;

    final inFlight = _buildAppFuture;
    if (inFlight != null) {
      await inFlight;
      return;
    }

    if (!AdPresentationGate.canShowInterstitial) {
      developer.log(
        '[InterstitialAdTrigger] skip build_app_inter — IAP/app-open active',
      );
      return;
    }

    final future = _runBuildAppInterstitial();
    _buildAppFuture = future;
    try {
      await future;
    } finally {
      if (identical(_buildAppFuture, future)) {
        _buildAppFuture = null;
      }
    }
  }

  static Future<void> _runBuildAppInterstitial() async {
    final shown = await showPlacement(
      placementId: AdPlacements.firstClickInter,
    );
    if (shown) {
      _buildAppShownThisSession = true;
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
    var loaderShown = false;

    void dismissLoader() {
      if (!loaderShown) return;
      loaderShown = false;
      AdLoadingOverlay.hide();
    }

    try {
      await _enableFullScreenForAds();

      // Final gate before loader (subscription wins if opened meanwhile).
      if (!AdPresentationGate.canShowInterstitial) {
        developer.log(
          '[InterstitialAdTrigger] abort $placementId — IAP opened',
        );
        return false;
      }

      if (useLoader) {
        // OverlayEntry — not a route — so Create App / back never orphans it.
        AdLoadingOverlay.show();
        loaderShown = AdLoadingOverlay.isShowing;
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
      dismissLoader();
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
