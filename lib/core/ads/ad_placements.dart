import 'package:web_to_app/core/ads/ads_debug_config.dart';

/// Ad formats supported by the app.
enum AdFormat { interstitial, appOpen, banner, mediumNative, smallNative }

/// Placement IDs for the ads enabled in this build.
abstract final class AdPlacements {
  static const splashInter1st = 'splash_inter_1st';
  static const splashInter2nd = 'splash_inter_2nd';
  static const languageNative = 'language_native';
  static const onboardingNative = 'onboarding_native';

  /// Home-screen first click interstitial (once per app session).
  static const firstClickInter = 'first_click_inter';

  /// App Open ad.
  static const appOpen = 'appopen';
}

/// Google official test unit IDs (used in debug builds).
abstract final class AdTestUnitIds {
  static const interstitial = 'ca-app-pub-3940256099942544/1033173712';
  static const appOpen = 'ca-app-pub-3940256099942544/9257395921';
  static const banner = 'ca-app-pub-3940256099942544/6300978111';
  static const native = 'ca-app-pub-3940256099942544/2247696110';
}

class AdPlacement {
  const AdPlacement({
    required this.id,
    required this.androidUnitId,
    required this.format,
    this.enabled = true,
  });

  final String id;
  final String androidUnitId;
  final AdFormat format;
  final bool enabled;

  /// Production unit normally; Google test unit when [AdsDebugConfig.useTestAdUnits].
  String get unitId {
    if (AdsDebugConfig.useTestAdUnits) {
      return switch (format) {
        AdFormat.interstitial => AdTestUnitIds.interstitial,
        AdFormat.appOpen => AdTestUnitIds.appOpen,
        AdFormat.banner => AdTestUnitIds.banner,
        AdFormat.mediumNative || AdFormat.smallNative => AdTestUnitIds.native,
      };
    }
    return androidUnitId;
  }
}

/// Central registry of ad placements and production unit IDs (local only).
abstract final class AdConfig {
  static const Map<String, AdPlacement> placements = {
    AdPlacements.splashInter1st: AdPlacement(
      id: AdPlacements.splashInter1st,
      androidUnitId: 'ca-app-pub-5471933816484694/1362402293',
      format: AdFormat.interstitial,
    ),
    AdPlacements.splashInter2nd: AdPlacement(
      id: AdPlacements.splashInter2nd,
      androidUnitId: 'ca-app-pub-5471933816484694/6411428856',
      format: AdFormat.interstitial,
    ),
    AdPlacements.languageNative: AdPlacement(
      id: AdPlacements.languageNative,
      androidUnitId: 'ca-app-pub-5471933816484694/8331135322',
      format: AdFormat.mediumNative,
    ),
    AdPlacements.onboardingNative: AdPlacement(
      id: AdPlacements.onboardingNative,
      androidUnitId: 'ca-app-pub-5471933816484694/6355588539',
      format: AdFormat.mediumNative,
    ),
    AdPlacements.firstClickInter: AdPlacement(
      id: AdPlacements.firstClickInter,
      androidUnitId: 'ca-app-pub-5471933816484694/9340844521',
      format: AdFormat.interstitial,
    ),
    AdPlacements.appOpen: AdPlacement(
      id: AdPlacements.appOpen,
      androidUnitId: 'ca-app-pub-5471933816484694/4391890316',
      format: AdFormat.appOpen,
    ),
  };

  static AdPlacement? of(String placementId) => placements[placementId];

  static String? unitIdFor(String placementId) => of(placementId)?.unitId;

  static bool isEnabled(String placementId) =>
      of(placementId)?.enabled ?? false;
}
