import 'dart:developer' as developer;

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:web_to_app/core/ads/ad_placements.dart';

/// Non-ad Remote Config feature keys (Android base names).
/// iOS uses the same name with `_ios` suffix, e.g. `splash_sub_ios`.
abstract final class RemoteConfigKeys {
  /// Show IAP paywall before auth (new users) or before home (logged-in).
  static const splashSub = 'splash_sub';

  /// Free build quota: `off` = unlimited, `1`/`2`/… = free builds then IAP.
  static const buildAppSub = 'buildapp_sub';

  /// Generate Bundle & APK quota: `off` = unlimited, `1`/`2`/… = then IAP.
  /// Persists across restarts (not reset).
  static const generateBundleApkSub = 'generatebundleapk_sub';

  /// Download APK & Bundle quota: `off` = unlimited, `1`/`2`/… = free downloads
  /// per format (APK and AAB counted separately), then IAP until premium.
  /// Persists across restarts. Default: `1` (1 free APK + 1 free AAB).
  static const downloadBundleApkSub = 'downloadbundleapk_sub';

  /// Build Again quota: `off` = unlimited, `1`/`2`/… = then IAP.
  /// Persists across restarts. Default: `3`.
  static const buildAgainSub = 'buildagain_sub';

  /// Free credits before pack paywall (Diginotes-compatible). Default: `3`.
  static const aiModuleFreeCredits = 'ai_module_free_credits';

  /// Credits granted per `threescan_inapp` purchase. Default: `3`.
  static const aiModulePackCredits = 'ai_module_pack_credits';
}

/// Placements whose RC value is a frequency string: `off, 1, 2, 3, 4`.
const Set<String> frequencyRemoteConfigKeys = {
  AdPlacements.projectNative,
  AdPlacements.generateBundleApkInter,
  AdPlacements.buildAgainInter,
};

/// Base Remote Config defaults (Android key names).
const Map<String, dynamic> _adRemoteConfigBaseDefaults = {
  AdPlacements.splashInter1st: true,
  AdPlacements.splashInter2nd: true,
  AdPlacements.languageNative: true,
  AdPlacements.onboardingNative: true,
  AdPlacements.homeNative: true,
  AdPlacements.projectNative: '3',
  AdPlacements.createAppInter: true,
  AdPlacements.creationScreenNative: true,
  AdPlacements.generateBundleApkInter: 'off, 1, 2, 3, 4',
  AdPlacements.buildAgainInter: 'off, 1, 2, 3, 4',
  AdPlacements.goToHomeInter: true,
  AdPlacements.myProjNative: true,
  AdPlacements.helpScreenNative: true,
  AdPlacements.appOpen: true,
  RemoteConfigKeys.splashSub: true,
  RemoteConfigKeys.buildAppSub: 'off',
  RemoteConfigKeys.generateBundleApkSub: 'off',
  RemoteConfigKeys.downloadBundleApkSub: '1',
  RemoteConfigKeys.buildAgainSub: '3',
  RemoteConfigKeys.aiModuleFreeCredits: 3,
  RemoteConfigKeys.aiModulePackCredits: 3,
};

/// Firebase defaults for Android keys + matching `*_ios` keys.
final Map<String, dynamic> adRemoteConfigDefaults = {
  for (final entry in _adRemoteConfigBaseDefaults.entries) ...{
    entry.key: entry.value,
    '${entry.key}_ios': entry.value,
  },
};

/// Resolves platform-specific RC key.
/// Android: `splash_inter_1st` · iOS: `splash_inter_1st_ios`
String platformRemoteConfigKey(String baseKey) {
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    return '${baseKey}_ios';
  }
  return baseKey;
}

/// Thin Remote Config wrapper for ad / feature flags.
class AdRemoteConfigService {
  AdRemoteConfigService._();

  static final AdRemoteConfigService instance = AdRemoteConfigService._();

  FirebaseRemoteConfig? _remoteConfig;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: kDebugMode
              ? Duration.zero
              : const Duration(hours: 1),
        ),
      );
      await remoteConfig.setDefaults(adRemoteConfigDefaults);

      try {
        await remoteConfig.fetchAndActivate();
      } catch (e) {
        developer.log(
          '[AdRemoteConfig] fetchAndActivate failed (using defaults): $e',
        );
      }

      _remoteConfig = remoteConfig;
      _initialized = true;
      developer.log(
        '[AdRemoteConfig] initialized '
        '(platform keys: ${defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android'})',
      );
    } catch (e) {
      developer.log('[AdRemoteConfig] initialize failed: $e');
      _initialized = true;
    }
  }

  Future<void> fetchNow() async {
    final remoteConfig = _remoteConfig;
    if (remoteConfig == null) {
      await initialize();
    }
    final config = _remoteConfig;
    if (config == null) return;

    try {
      await config.fetchAndActivate();
    } catch (e) {
      developer.log('[AdRemoteConfig] fetchNow failed: $e');
    }
  }

  dynamic _defaultFor(String baseKey) =>
      adRemoteConfigDefaults[platformRemoteConfigKey(baseKey)] ??
      adRemoteConfigDefaults[baseKey];

  /// Frequency string for [baseKey], e.g. `off, 1, 2, 3, 4`.
  /// Reads Android key or `*_ios` depending on platform.
  String getFrequency(String baseKey) {
    final key = platformRemoteConfigKey(baseKey);
    final defaultValue = _defaultFor(baseKey);
    final fallback = defaultValue is String ? defaultValue : 'off';

    final remoteConfig = _remoteConfig;
    if (remoteConfig == null) return fallback;

    try {
      final value = remoteConfig.getString(key);
      if (value.isEmpty) return fallback;
      return value;
    } catch (e) {
      developer.log('[AdRemoteConfig] getString($key) failed: $e');
      return fallback;
    }
  }

  /// Parsed positive frequency thresholds (ignores `off`).
  List<int> getFrequencyThresholds(String baseKey) {
    final trimmed = getFrequency(baseKey).trim().toLowerCase();
    if (trimmed.isEmpty || trimmed == 'off') return const [];

    final values = <int>[];
    for (final part in trimmed.split(',')) {
      final token = part.trim();
      if (token.isEmpty || token == 'off') continue;
      final n = int.tryParse(token);
      if (n != null && n > 0) values.add(n);
    }
    return values;
  }

  /// Quota limit for keys like `buildapp_sub` / `generatebundleapk_sub`.
  /// Returns `null` when unlimited (`off` / empty / invalid).
  /// Returns `N` when RC is `N` (or max if a comma list is used).
  int? getQuotaLimit(String baseKey) {
    final trimmed = getFrequency(baseKey).trim().toLowerCase();
    if (trimmed.isEmpty || trimmed == 'off') return null;

    final single = int.tryParse(trimmed);
    if (single != null && single > 0) return single;

    final thresholds = getFrequencyThresholds(baseKey);
    if (thresholds.isEmpty) return null;
    return thresholds.reduce((a, b) => a > b ? a : b);
  }

  /// Free-build limit for `buildapp_sub`.
  int? getBuildAppSubLimit() => getQuotaLimit(RemoteConfigKeys.buildAppSub);

  /// Integer Remote Config value with [fallback] when missing/invalid.
  int getInt(String baseKey, int fallback) {
    final key = platformRemoteConfigKey(baseKey);
    final remoteConfig = _remoteConfig;
    if (remoteConfig == null) {
      final defaultValue = _defaultFor(baseKey);
      if (defaultValue is int) return defaultValue;
      return fallback;
    }

    try {
      final value = remoteConfig.getInt(key);
      if (value > 0) return value;
      final defaultValue = _defaultFor(baseKey);
      if (defaultValue is int && defaultValue > 0) return defaultValue;
      return fallback;
    } catch (e) {
      developer.log('[AdRemoteConfig] getInt($key) failed: $e');
      return fallback;
    }
  }

  /// Whether [placementId] is enabled in Remote Config for this platform.
  /// Bool keys: standard true/false.
  /// Frequency keys: enabled when at least one positive threshold exists.
  bool isPlacementEnabled(String placementId) {
    final key = platformRemoteConfigKey(placementId);

    if (frequencyRemoteConfigKeys.contains(placementId) ||
        _defaultFor(placementId) is String) {
      return getFrequencyThresholds(placementId).isNotEmpty;
    }

    final defaultValue = (_defaultFor(placementId) as bool?) ?? true;

    final remoteConfig = _remoteConfig;
    if (remoteConfig == null) return defaultValue;

    try {
      return remoteConfig.getBool(key);
    } catch (e) {
      developer.log(
        '[AdRemoteConfig] getBool($key) failed: $e → default $defaultValue',
      );
      return defaultValue;
    }
  }
}
