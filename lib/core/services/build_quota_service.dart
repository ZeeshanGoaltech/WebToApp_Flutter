import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_to_app/app/routes/app_routes.dart';
import 'package:web_to_app/core/config/app_feature_config.dart';
import 'package:web_to_app/core/navigation/launch_flow.dart';
import 'package:web_to_app/core/services/download_token_service.dart';
import 'package:web_to_app/core/services/premium_service.dart';
import 'package:web_to_app/core/services/session_service.dart';

/// Free-use quotas for build / generate / download.
///
/// Persistent (survives restart):
/// - `buildAppSubLimit` — opening Build App flow
/// - `generateBundleApkSubLimit` — Generate Bundle & APK
/// - `buildAgainSubLimit` — Build Again button (default 3)
///
/// Downloads:
/// - **One free project** on first install (unlimited APK + AAB).
/// - Later projects: `apkdownload_inapp` unlocks APK only;
///   `bundledownload_inapp` unlocks AAB only (same project, separate buys).
///
/// Weekly / monthly / yearly / lifetime subscriptions do **not** unlock
/// downloads.
class BuildQuotaService {
  BuildQuotaService._();

  static final BuildQuotaService instance = BuildQuotaService._();

  static const _buildAppCountKey = 'buildapp_sub_build_count';
  static const _generateBundleApkCountKey = 'generatebundleapk_sub_count';
  static const _buildAgainCountKey = 'buildagain_sub_count';

  bool get _isPremium {
    if (Get.isRegistered<SessionService>() &&
        Get.find<SessionService>().hasPremiumAccess) {
      return true;
    }
    return PremiumService.isPremiumCached;
  }

  Future<int> _getPersistedCount(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key) ?? 0;
  }

  Future<void> _incrementPersisted(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final next = (prefs.getInt(key) ?? 0) + 1;
    await prefs.setInt(key, next);
  }

  Future<bool> _canUsePersisted({
    required String countKey,
    required int? Function() limitReader,
  }) async {
    if (_isPremium) return true;
    final limit = limitReader();
    if (limit == null) return true;
    final count = await _getPersistedCount(countKey);
    return count < limit;
  }

  Future<bool> _ensurePersistedOrOpenIap({
    required String countKey,
    required int? Function() limitReader,
  }) async {
    if (await _canUsePersisted(countKey: countKey, limitReader: limitReader)) {
      return true;
    }
    LaunchFlow.openIapFromSettings();
    return false;
  }

  /// Opening Build App / build screen.
  Future<bool> ensureCanOpenBuildFlowOrOpenIap() => _ensurePersistedOrOpenIap(
        countKey: _buildAppCountKey,
        limitReader: () => AppFeatureConfig.buildAppSubLimit,
      );

  /// Generate Bundle & APK button.
  Future<bool> ensureCanGenerateBundleApkOrOpenIap() =>
      _ensurePersistedOrOpenIap(
        countKey: _generateBundleApkCountKey,
        limitReader: () => AppFeatureConfig.generateBundleApkSubLimit,
      );

  /// Allow download when this format is unlocked for [appId], or when the
  /// one free project can still be claimed. Else open the matching paywall.
  Future<bool> ensureCanDownloadBundleApkOrOpenIap({
    required bool isAab,
    String? appId,
  }) async {
    final tokens = DownloadTokenService.instance;

    if (await tokens.isFormatUnlocked(appId, isAab: isAab)) {
      return true;
    }

    if (await tokens.tryClaimFreeProject(appId, isAab: isAab)) {
      return true;
    }

    final bought = await Get.toNamed(
      AppRoutes.downloadInApp,
      arguments: <String, dynamic>{
        'isAab': isAab,
        'appId': appId,
      },
    );
    if (bought == true) return true;

    return tokens.isFormatUnlocked(appId, isAab: isAab);
  }

  /// Build Again button (persists; default 3).
  Future<bool> ensureCanBuildAgainOrOpenIap() => _ensurePersistedOrOpenIap(
        countKey: _buildAgainCountKey,
        limitReader: () => AppFeatureConfig.buildAgainSubLimit,
      );

  /// Record a successful generate (persists; never reset on restart).
  Future<void> recordSuccessfulGenerate() async {
    await _incrementPersisted(_buildAppCountKey);
    await _incrementPersisted(_generateBundleApkCountKey);
  }

  /// Record a successful Build Again tap (persists).
  Future<void> recordSuccessfulBuildAgain() async {
    await _incrementPersisted(_buildAgainCountKey);
  }

  /// Format unlock already covers unlimited downloads — nothing to consume.
  Future<void> recordSuccessfulDownload({
    required bool isAab,
    String? appId,
  }) async {
    // Free claim / paid unlock happen in [ensureCanDownloadBundleApkOrOpenIap]
    // and purchase handlers. No per-download counters.
  }

  @Deprecated('Use ensureCanOpenBuildFlowOrOpenIap')
  Future<bool> ensureCanBuildOrOpenIap() => ensureCanOpenBuildFlowOrOpenIap();

  @Deprecated('Use recordSuccessfulGenerate')
  Future<void> recordSuccessfulBuild() => recordSuccessfulGenerate();
}
