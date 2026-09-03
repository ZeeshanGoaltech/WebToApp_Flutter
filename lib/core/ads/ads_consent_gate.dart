import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:web_to_app/core/ads/ads_debug_config.dart';
import 'package:web_to_app/core/ads/gdpr_consent_service.dart';
import 'package:web_to_app/core/ads/webview_warmup.dart';

/// Splash gate matching Ummah_Pro_Exis [AdsConsentGate]:
/// 1) configure test devices + [MobileAds.initialize]
/// 2) GDPR / UMP form
/// 3) [mayRequestAds] from [ConsentInformation.canRequestAds]
abstract final class AdsConsentGate {
  static bool _splashConsentCompleted = false;
  static bool _canRequestAds = false;
  static bool _mobileAdsInitialized = false;

  static bool get splashConsentCompleted => _splashConsentCompleted;

  static bool get canRequestAdsPerUmp => _canRequestAds;

  static bool get mobileAdsInitialized => _mobileAdsInitialized;

  /// False until splash consent finishes; then true only if UMP allows ads.
  static bool get mayRequestAds =>
      _splashConsentCompleted && (!_isMobileAdsHost || _canRequestAds);

  static bool get _isMobileAdsHost => Platform.isAndroid || Platform.isIOS;

  /// Call once from splash (via [AdService.initialize]) before any ad loads.
  static Future<void> runSplashConsentAndMobileAdsSetup() async {
    if (_splashConsentCompleted) return;

    if (!_isMobileAdsHost) {
      _canRequestAds = true;
      _splashConsentCompleted = true;
      _mobileAdsInitialized = true;
      return;
    }

    try {
      await _configureAndInitializeMobileAds();
    } catch (e, st) {
      developer.log(
        '[AdsConsentGate] Mobile Ads init failed: $e',
        error: e,
        stackTrace: st,
      );
    }

    try {
      await GdprConsentService.instance.gatherConsent();
    } catch (e, st) {
      developer.log(
        '[AdsConsentGate] GDPR / UMP failed: $e',
        error: e,
        stackTrace: st,
      );
    }

    try {
      _canRequestAds = await ConsentInformation.instance.canRequestAds();
    } catch (e, st) {
      developer.log(
        '[AdsConsentGate] canRequestAds failed: $e',
        error: e,
        stackTrace: st,
      );
      _canRequestAds = false;
    }

    _splashConsentCompleted = true;
    developer.log(
      '[AdsConsentGate] done; mayRequestAds=$mayRequestAds, '
      'canRequestAdsPerUmp=$_canRequestAds',
    );
  }

  static Future<void> _configureAndInitializeMobileAds() async {
    if (_mobileAdsInitialized) return;

    if (AdsDebugConfig.useTestAdUnits) {
      try {
        await MobileAds.instance
            .updateRequestConfiguration(
              RequestConfiguration(
                testDeviceIds: AdsDebugConfig.adMobTestDeviceIds,
                tagForChildDirectedTreatment:
                    TagForChildDirectedTreatment.unspecified,
                tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.unspecified,
              ),
            )
            .timeout(const Duration(seconds: 5));
        developer.log(
          '[AdsConsentGate] test ads '
          '(debug=$kDebugMode releaseFlag=${AdsDebugConfig.useTestAdsInRelease}) '
          'testDeviceIds=${AdsDebugConfig.adMobTestDeviceIds}',
        );
      } catch (e) {
        developer.log('[AdsConsentGate] test device config failed: $e');
      }
    }

    // Android: load System WebView before GMA so AdMob's ads.internal.js
    // WebView does not hit nativeLoadWithRelroFile on first ad init (ANR).
    // Timeout / failure inside ensureReady — never blocks GDPR or ads forever.
    await WebViewWarmup.ensureReady();

    await MobileAds.instance.initialize();
    _mobileAdsInitialized = true;
    developer.log('[AdsConsentGate] MobileAds.initialize() completed');
  }
}
