import 'package:web_to_app/core/ads/ads_debug_config.dart';

/// Ad formats supported by the app.
enum AdFormat { interstitial, appOpen, banner, mediumNative, smallNative }

/// Placement IDs — keep in sync with Firebase Remote Config keys.
abstract final class AdPlacements {
  static const splashInter1st = 'splash_inter_1st';
  static const splashInter2nd = 'splash_inter_2nd';
  static const languageNative = 'language_native';
  static const onboardingNative = 'onboarding_native';
  static const homeNative = 'home_native';

  /// Bottom-tab interstitial (frequency RC: default `3` = every 3rd tab click).
  static const projectNative = 'project_native';

  /// Create App card "Get Started" interstitial.
  static const createAppInter = 'createapp_inter';

  /// Create-app wizard / build screen small native (after first 2 cards).
  static const creationScreenNative = 'creationscreen_native';

  /// Generate Bundle & APK button interstitial (frequency RC).
  static const generateBundleApkInter = 'generatebundleapk_inter';

  /// Build Again button interstitial (frequency RC).
  static const buildAgainInter = 'buildagain_inter';

  /// Go to Home button after generate (boolean RC).
  static const goToHomeInter = 'gotohome_inter';

  /// My Projects / My Apps tab medium native.
  static const myProjNative = 'myproj_native';

  /// Help & Guide screen medium native.
  static const helpScreenNative = 'helpscreen_native';

  /// App Open ad (RC: appopen).
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

/// Central registry of ad placements and production unit IDs.
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
    AdPlacements.homeNative: AdPlacement(
      id: AdPlacements.homeNative,
      androidUnitId: 'ca-app-pub-5471933816484694/2212449530',
      format: AdFormat.mediumNative,
    ),
    AdPlacements.projectNative: AdPlacement(
      id: AdPlacements.projectNative,
      androidUnitId: 'ca-app-pub-5471933816484694/9340844521',
      format: AdFormat.interstitial,
    ),
    AdPlacements.createAppInter: AdPlacement(
      id: AdPlacements.createAppInter,
      androidUnitId: 'ca-app-pub-5471933816484694/5042506867',
      format: AdFormat.interstitial,
    ),
    AdPlacements.creationScreenNative: AdPlacement(
      id: AdPlacements.creationScreenNative,
      androidUnitId: 'ca-app-pub-5471933816484694/2416343522',
      format: AdFormat.smallNative,
    ),
    AdPlacements.generateBundleApkInter: AdPlacement(
      id: AdPlacements.generateBundleApkInter,
      androidUnitId: 'ca-app-pub-5471933816484694/1163091748',
      format: AdFormat.interstitial,
    ),
    AdPlacements.buildAgainInter: AdPlacement(
      id: AdPlacements.buildAgainInter,
      androidUnitId: 'ca-app-pub-5471933816484694/9911690161',
      format: AdFormat.interstitial,
    ),
    AdPlacements.goToHomeInter: AdPlacement(
      id: AdPlacements.goToHomeInter,
      androidUnitId: 'ca-app-pub-5471933816484694/8394714503',
      format: AdFormat.interstitial,
    ),
    AdPlacements.myProjNative: AdPlacement(
      id: AdPlacements.myProjNative,
      androidUnitId: 'ca-app-pub-5471933816484694/6794004019',
      format: AdFormat.mediumNative,
    ),
    AdPlacements.helpScreenNative: AdPlacement(
      id: AdPlacements.helpScreenNative,
      androidUnitId: 'ca-app-pub-5471933816484694/7919383426',
      format: AdFormat.mediumNative,
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
