import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Per-project **per-format** unlock for APK / AAB downloads.
///
/// - First install: **one free project** (unlimited APK + AAB for that project).
/// - Later projects: buy separately —
///   - `apkdownload_inapp` → APK only for that project
///   - `bundledownload_inapp` → AAB only for that project
class DownloadTokenService {
  DownloadTokenService._();
  static final DownloadTokenService instance = DownloadTokenService._();

  /// Tokens like `appId:apk` / `appId:aab`.
  static const _unlockedFormatsKey = 'download_inapp_unlocked_formats';

  /// Legacy: project IDs unlocked for both formats (old combined unlock).
  static const _legacyUnlockedProjectsKey = 'download_inapp_unlocked_projects';

  static const _processedKey = 'download_inapp_unlock_processed';
  static const _freeClaimedKey = 'download_inapp_free_project_claimed';
  static const _freeProjectIdKey = 'download_inapp_free_project_id';

  /// Legacy global free-download counters (migrated once).
  static const _legacyApkCountKey = 'apkdownload_inapp_count';
  static const _legacyAabCountKey = 'bundledownload_inapp_count';

  /// Set before launching the download IAP so purchase success can unlock
  /// the correct project + format.
  String? pendingPurchaseAppId;
  bool? pendingPurchaseIsAab;

  final ValueNotifier<int> version = ValueNotifier<int>(0);

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  String _token(String appId, {required bool isAab}) =>
      '${appId.trim()}:${isAab ? 'aab' : 'apk'}';

  Future<Set<String>> _loadUnlocked() async {
    await _migrateIfNeeded();
    final prefs = await _prefs;
    return (prefs.getStringList(_unlockedFormatsKey) ?? const <String>[])
        .where((id) => id.trim().isNotEmpty)
        .toSet();
  }

  Future<void> _saveUnlocked(Set<String> tokens) async {
    final prefs = await _prefs;
    await prefs.setStringList(_unlockedFormatsKey, tokens.toList());
    version.value++;
  }

  Future<void> _migrateIfNeeded() async {
    final prefs = await _prefs;

    // Old combined project unlocks → both formats.
    final legacyProjects =
        prefs.getStringList(_legacyUnlockedProjectsKey) ?? const <String>[];
    if (legacyProjects.isNotEmpty) {
      final current =
          (prefs.getStringList(_unlockedFormatsKey) ?? const <String>[])
              .toSet();
      var changed = false;
      for (final raw in legacyProjects) {
        final id = raw.trim();
        if (id.isEmpty) continue;
        if (current.add(_token(id, isAab: false))) changed = true;
        if (current.add(_token(id, isAab: true))) changed = true;
      }
      if (changed) {
        await prefs.setStringList(_unlockedFormatsKey, current.toList());
      }
      await prefs.remove(_legacyUnlockedProjectsKey);
      debugPrint('[DownloadUnlock] migrated legacy project unlocks → formats');
    }

    if (prefs.containsKey(_freeClaimedKey)) return;

    final legacyApk = prefs.getInt(_legacyApkCountKey) ?? 0;
    final legacyAab = prefs.getInt(_legacyAabCountKey) ?? 0;
    if (legacyApk > 0 || legacyAab > 0) {
      await prefs.setBool(_freeClaimedKey, true);
      debugPrint(
        '[DownloadUnlock] migrated legacy free quota → free project claimed',
      );
    }
  }

  Future<bool> hasClaimedFreeProject() async {
    await _migrateIfNeeded();
    final prefs = await _prefs;
    return prefs.getBool(_freeClaimedKey) ?? false;
  }

  Future<bool> isFormatUnlocked(String? appId, {required bool isAab}) async {
    final id = appId?.trim() ?? '';
    if (id.isEmpty) return false;
    final unlocked = await _loadUnlocked();
    return unlocked.contains(_token(id, isAab: isAab));
  }

  Future<void> _unlockFormats(
    String appId, {
    required bool apk,
    required bool aab,
  }) async {
    final id = appId.trim();
    if (id.isEmpty) return;
    final unlocked = await _loadUnlocked();
    var changed = false;
    if (apk && unlocked.add(_token(id, isAab: false))) changed = true;
    if (aab && unlocked.add(_token(id, isAab: true))) changed = true;
    if (changed) {
      await _saveUnlocked(unlocked);
    } else {
      version.value++;
    }
  }

  /// Claims the one free project for [appId] (unlocks APK + AAB forever).
  /// Returns `true` if [isAab] format is now available on this free project.
  Future<bool> tryClaimFreeProject(
    String? appId, {
    required bool isAab,
  }) async {
    final id = appId?.trim() ?? '';
    if (id.isEmpty) return false;

    if (await isFormatUnlocked(id, isAab: isAab)) return true;

    await _migrateIfNeeded();
    final prefs = await _prefs;
    final claimed = prefs.getBool(_freeClaimedKey) ?? false;
    if (claimed) {
      final freeId = prefs.getString(_freeProjectIdKey)?.trim();
      if (freeId == null || freeId != id) return false;
      // Free project already claimed for this id — ensure both formats.
      await _unlockFormats(id, apk: true, aab: true);
      return true;
    }

    await prefs.setBool(_freeClaimedKey, true);
    await prefs.setString(_freeProjectIdKey, id);
    await _unlockFormats(id, apk: true, aab: true);
    debugPrint('[DownloadUnlock] free project claimed: $id (apk+aab)');
    return true;
  }

  /// Unlocks only the purchased format for [appId].
  Future<void> unlockFormatFromPurchase({
    required String appId,
    required bool isAab,
    required String purchaseKey,
  }) async {
    final id = appId.trim();
    if (id.isEmpty) return;

    final prefs = await _prefs;
    final processed = prefs.getStringList(_processedKey) ?? <String>[];
    final dedupeKey = purchaseKey.isNotEmpty
        ? purchaseKey
        : '$id:${isAab ? 'aab' : 'apk'}';

    if (processed.contains(dedupeKey)) {
      debugPrint('[DownloadUnlock] already processed: $dedupeKey');
      await _unlockFormats(id, apk: !isAab, aab: isAab);
      return;
    }
    processed.add(dedupeKey);
    await prefs.setStringList(_processedKey, processed);

    await _unlockFormats(id, apk: !isAab, aab: isAab);
    debugPrint(
      '[DownloadUnlock] ${isAab ? 'aab' : 'apk'} unlocked for project: $id',
    );
  }
}
