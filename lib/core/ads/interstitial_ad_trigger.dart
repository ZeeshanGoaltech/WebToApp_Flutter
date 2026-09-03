import 'dart:async';
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
  static bool _firstClickShownThisSession = false;
  static Future<void>? _firstClickFuture;
  static DateTime? _homeProTapAt;

  static bool get _isPremium {
    if (Get.isRegistered<SessionService>() &&
        Get.find<SessionService>().hasPremiumAccess) {
      return true;
    }
    return PremiumService.isPremiumCached;
  }

  /// True while the once-per-session first-click interstitial is loading/showing.
  static bool get isFirstClickInFlight => _firstClickFuture != null;

  /// Call from the Home Pro button so that tap does not trigger 1st-click inter.
  static void markHomeProTap() {
    _homeProTapAt = DateTime.now();
  }

  /// Run [action] only after the first-click interstitial is done (or skipped).
  /// Use for any Home navigation so the next screen opens after ad dismiss.
  static Future<T> afterFirstClick<T>(FutureOr<T> Function() action) async {
    await showFirstClickInterstitialIfNeeded();
    return await action();
  }

  /// Home-screen first click interstitial — once per app session.
  /// Skips when the Pro button was just tapped.
  /// Concurrent callers share the same in-flight Future (so navigation can wait).
  static Future<void> showFirstClickInterstitialIfNeeded() async {
    if (_isPremium) return;
    if (_firstClickShownThisSession) return;

    final inFlight = _firstClickFuture;
    if (inFlight != null) {
      await inFlight;
      return;
    }

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

    final future = _runFirstClickInterstitial();
    _firstClickFuture = future;
    try {
      await future;
    } finally {
      if (identical(_firstClickFuture, future)) {
        _firstClickFuture = null;
      }
    }
  }

  static Future<void> _runFirstClickInterstitial() async {
    final shown = await showPlacement(
      placementId: AdPlacements.firstClickInter,
    );
    if (shown) {
      _firstClickShownThisSession = true;
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
