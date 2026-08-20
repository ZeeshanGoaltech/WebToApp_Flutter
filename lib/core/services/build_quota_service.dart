import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_to_app/core/ads/ad_remote_config_service.dart';
import 'package:web_to_app/core/navigation/launch_flow.dart';
import 'package:web_to_app/core/services/premium_service.dart';
import 'package:web_to_app/core/services/session_service.dart';

/// Free-use quotas for build / generate / download.
///
/// Persistent (survives restart until premium):
/// - RC `buildapp_sub` — opening Build App flow
/// - RC `generatebundleapk_sub` — Generate Bundle & APK
/// - RC `buildagain_sub` — Build Again button (default 3)
/// - RC `downloadbundleapk_sub` — Download APK / Bundle (default 1)
///   Limit N = N free APK downloads **and** N free AAB downloads,
///   then IAP on further downloads until premium.
///
/// Values: `off` = unlimited, `1`/`2`/… = free uses then IAP.
class BuildQuotaService {
  BuildQuotaService._();

  static final BuildQuotaService instance = BuildQuotaService._();

  static const _buildAppCountKey = 'buildapp_sub_build_count';
  static const _generateBundleApkCountKey = 'generatebundleapk_sub_count';
  static const _buildAgainCountKey = 'buildagain_sub_count';
  static const _downloadApkCountKey = 'downloadbundleapk_sub_apk_count';
  static const _downloadAabCountKey = 'downloadbundleapk_sub_aab_count';

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

  /// RC `buildapp_sub` — opening Build App / build screen.
  Future<bool> ensureCanOpenBuildFlowOrOpenIap() => _ensurePersistedOrOpenIap(
        countKey: _buildAppCountKey,
        limitReader: () => AdRemoteConfigService.instance.getQuotaLimit(
          RemoteConfigKeys.buildAppSub,
        ),
      );

  /// RC `generatebundleapk_sub` — Generate Bundle & APK button.
  Future<bool> ensureCanGenerateBundleApkOrOpenIap() =>
      _ensurePersistedOrOpenIap(
        countKey: _generateBundleApkCountKey,
        limitReader: () => AdRemoteConfigService.instance.getQuotaLimit(
          RemoteConfigKeys.generateBundleApkSub,
        ),
      );

  /// RC `downloadbundleapk_sub` — Download APK or AAB.
  ///
  /// [isAab] selects the per-format counter. Limit `N` allows `N` APKs and
  /// `N` AABs; further downloads open IAP until the user is premium.
  /// Counts persist across app restarts.
  Future<bool> ensureCanDownloadBundleApkOrOpenIap({
    required bool isAab,
  }) {
    return _ensurePersistedOrOpenIap(
      countKey: isAab ? _downloadAabCountKey : _downloadApkCountKey,
      limitReader: () => AdRemoteConfigService.instance.getQuotaLimit(
        RemoteConfigKeys.downloadBundleApkSub,
      ),
    );
  }

  /// RC `buildagain_sub` — Build Again button (persists; default 3).
  Future<bool> ensureCanBuildAgainOrOpenIap() => _ensurePersistedOrOpenIap(
        countKey: _buildAgainCountKey,
        limitReader: () => AdRemoteConfigService.instance.getQuotaLimit(
          RemoteConfigKeys.buildAgainSub,
        ),
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

  /// Record a successful APK/AAB download (persists per format).
  Future<void> recordSuccessfulDownload({required bool isAab}) async {
    await _incrementPersisted(
      isAab ? _downloadAabCountKey : _downloadApkCountKey,
    );
  }

  @Deprecated('Use ensureCanOpenBuildFlowOrOpenIap')
  Future<bool> ensureCanBuildOrOpenIap() => ensureCanOpenBuildFlowOrOpenIap();

  @Deprecated('Use recordSuccessfulGenerate')
  Future<void> recordSuccessfulBuild() => recordSuccessfulGenerate();
}
