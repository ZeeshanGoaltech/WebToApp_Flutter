import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:web_to_app/core/ads/ad_placements.dart';
import 'package:web_to_app/core/ads/ad_presentation_gate.dart';
import 'package:web_to_app/core/ads/ads_consent_gate.dart';
import 'package:web_to_app/core/ads/app_open_ad_manager.dart';
import 'package:web_to_app/core/services/premium_service.dart';
import 'package:web_to_app/core/services/session_service.dart';
import 'package:get/get.dart';

/// Loads and shows AdMob interstitial (and future) ads.
class AdService {
  AdService._();

  static final AdService instance = AdService._();

  bool _initialized = false;
  final Set<String> _showing = {};

  bool get isInitialized => _initialized;

  bool isShowing(String placementId) => _showing.contains(placementId);

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Ummah order: MobileAds init → GDPR form → mayRequestAds
      await AdsConsentGate.runSplashConsentAndMobileAdsSetup();
      _initialized = AdsConsentGate.mobileAdsInitialized;
      developer.log(
        '[AdService] init done; mayRequestAds=${AdsConsentGate.mayRequestAds}',
      );
    } catch (e) {
      developer.log('[AdService] Mobile Ads init failed: $e');
    }
  }

  bool get _isPremium {
    if (Get.isRegistered<SessionService>() &&
        Get.find<SessionService>().hasPremiumAccess) {
      return true;
    }
    return PremiumService.isPremiumCached;
  }

  /// Load + show interstitial. Returns true if ad was shown and dismissed.
  /// [onAdShown] fires when the full-screen ad appears (dismiss loader here).
  Future<bool> showInterstitial(
    String placementId, {
    VoidCallback? onAdShown,
  }) async {
    if (_showing.contains(placementId)) {
      developer.log('[AdService] already showing $placementId');
      return false;
    }

    if (_isPremium) {
      developer.log('[AdService] premium — skip $placementId');
      return false;
    }

    if (!_initialized) {
      await initialize();
    }

    if (!AdsConsentGate.mayRequestAds) {
      developer.log('[AdService] UMP blocked — skip $placementId');
      return false;
    }

    if (!AdConfig.isEnabled(placementId)) {
      developer.log('[AdService] local config disabled: $placementId');
      return false;
    }

    final adUnitId = AdConfig.unitIdFor(placementId);
    if (adUnitId == null || adUnitId.isEmpty) {
      developer.log('[AdService] no unit id for $placementId');
      return false;
    }

    developer.log(
      '[AdService] loading interstitial $placementId → $adUnitId '
      '(debug=$kDebugMode)',
    );

    final ad = await _loadInterstitial(adUnitId, placementId);
    if (ad == null) return false;

    _showing.add(placementId);
    final completer = Completer<bool>();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        developer.log('[AdService] showed $placementId');
        onAdShown?.call();
      },
      onAdDismissedFullScreenContent: (InterstitialAd dismissed) {
        developer.log('[AdService] dismissed $placementId');
        _showing.remove(placementId);
        AdPresentationGate.markFullscreenAdClosed();
        AppOpenAdManager.instance.onInterstitialDismissed();
        Future.microtask(() async {
          try {
            await Future<void>.delayed(const Duration(milliseconds: 100));
            SystemChrome.setEnabledSystemUIMode(
              SystemUiMode.edgeToEdge,
              overlays: SystemUiOverlay.values,
            );
          } catch (_) {}
          if (!completer.isCompleted) completer.complete(true);
        });
        Future<void>.delayed(const Duration(milliseconds: 50), () {
          try {
            dismissed.dispose();
          } catch (_) {}
        });
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd failed, AdError error) {
        developer.log(
          '[AdService] failed to show $placementId: ${error.message}',
        );
        _showing.remove(placementId);
        AdPresentationGate.markFullscreenAdClosed();
        try {
          failed.dispose();
        } catch (_) {}
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    try {
      // Android only; never block show if the channel call fails.
      try {
        await ad.setImmersiveMode(true);
      } catch (_) {}
      await ad.show();
      return await completer.future.timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          _showing.remove(placementId);
          AdPresentationGate.markFullscreenAdClosed();
          return false;
        },
      );
    } catch (e) {
      developer.log('[AdService] show() error $placementId: $e');
      _showing.remove(placementId);
      AdPresentationGate.markFullscreenAdClosed();
      try {
        ad.dispose();
      } catch (_) {}
      return false;
    }
  }

  Future<InterstitialAd?> _loadInterstitial(
    String adUnitId,
    String placementId,
  ) async {
    final completer = Completer<InterstitialAd?>();

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          developer.log('[AdService] loaded $placementId');
          if (!completer.isCompleted) completer.complete(ad);
        },
        onAdFailedToLoad: (error) {
          developer.log(
            '[AdService] load failed $placementId: '
            '${error.code} ${error.message}',
          );
          if (!completer.isCompleted) completer.complete(null);
        },
      ),
    );

    final timeout = kReleaseMode ? 12 : 8;
    return completer.future.timeout(
      Duration(seconds: timeout),
      onTimeout: () {
        developer.log('[AdService] load timeout $placementId');
        return null;
      },
    );
  }
}
