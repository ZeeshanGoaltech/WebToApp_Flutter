import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_to_app/app/routes/app_routes.dart';
import 'package:web_to_app/core/config/app_feature_config.dart';
import 'package:web_to_app/core/navigation/launch_flow.dart';
import 'package:web_to_app/core/services/credit_service.dart';
import 'package:web_to_app/core/services/download_token_service.dart';
import 'package:web_to_app/core/services/premium_service.dart';
import 'package:web_to_app/core/services/session_service.dart';

/// Free-use quotas for build / generate / download.
///
/// Persistent (survives restart):
/// - `buildAppSubLimit` — opening Build App flow
/// - `generateBundleApkSubLimit` — Generate Bundle & APK
/// - `buildAgainSubLimit` — Build Again button (default 3)
/// - `apkDownloadFreeQuota` — free APK downloads (`0` = none, default `1`)
/// - `bundleDownloadFreeQuota` — free AAB downloads (`0` = none, default `1`)
///
/// Buying `apkdownload_inapp` or `bundledownload_inapp` unlocks **unlimited
/// APK + AAB downloads for that project only** (not `threescan_inapp` credits).
/// Remaining `threescan_inapp` paid credits also allow downloads (1 credit each).
///
/// Weekly / monthly / yearly / lifetime subscriptions do **not** unlock
/// downloads — only credits, project unlock, or free local quota.
class BuildQuotaService {
  BuildQuotaService._();

  static final BuildQuotaService instance = BuildQuotaService._();

  static const _buildAppCountKey = 'buildapp_sub_build_count';
  static const _generateBundleApkCountKey = 'generatebundleapk_sub_count';
  static const _buildAgainCountKey = 'buildagain_sub_count';
  static const _downloadApkCountKey = 'apkdownload_inapp_count';
  static const _downloadAabCountKey = 'bundledownload_inapp_count';

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

  /// Paid `threescan_inapp` credits → can download (1 credit each).
  /// Subscriptions are intentionally ignored here.
  Future<bool> _hasThreescanCredits() async {
    await CreditService.instance.initialize();
    return CreditService.instance.paidCredits.value > 0;
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

  /// Allow download when threescan credits, this [appId] is unlocked,
  /// or free local quota remains. Else open download / credits paywall.
  /// Subscriptions (weekly/monthly/yearly/lifetime) do not grant downloads.
  Future<bool> ensureCanDownloadBundleApkOrOpenIap({
    required bool isAab,
    String? appId,
  }) async {
    if (await _hasThreescanCredits()) return true;

    if (await DownloadTokenService.instance.isProjectUnlocked(appId)) {
      return true;
    }

    final countKey = isAab ? _downloadAabCountKey : _downloadApkCountKey;
    final limit = isAab
        ? AppFeatureConfig.bundleDownloadFreeQuota
        : AppFeatureConfig.apkDownloadFreeQuota;

    final count = await _getPersistedCount(countKey);
    if (count < limit) return true;

    final bought = await Get.toNamed(
      AppRoutes.downloadInApp,
      arguments: <String, dynamic>{
        'isAab': isAab,
        'appId': appId,
      },
    );
    if (bought == true) return true;

    if (await DownloadTokenService.instance.isProjectUnlocked(appId)) {
      return true;
    }
    return _hasThreescanCredits();
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

  /// Consume order: project unlock → no count;
  /// threescan credit → free local counter.
  /// Subscriptions do not skip consumption.
  Future<void> recordSuccessfulDownload({
    required bool isAab,
    String? appId,
  }) async {
    if (await DownloadTokenService.instance.isProjectUnlocked(appId)) {
      return;
    }

    await CreditService.instance.initialize();
    if (CreditService.instance.paidCredits.value > 0) {
      await CreditService.instance.consume();
      return;
    }

    await _incrementPersisted(
      isAab ? _downloadAabCountKey : _downloadApkCountKey,
    );
  }

  @Deprecated('Use ensureCanOpenBuildFlowOrOpenIap')
  Future<bool> ensureCanBuildOrOpenIap() => ensureCanOpenBuildFlowOrOpenIap();

  @Deprecated('Use recordSuccessfulGenerate')
  Future<void> recordSuccessfulBuild() => recordSuccessfulGenerate();
}
