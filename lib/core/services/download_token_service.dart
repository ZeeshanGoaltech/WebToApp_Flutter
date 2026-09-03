import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Per-**package** (unique) per-format unlock for APK / AAB downloads.
///
/// Keys use Android package name (not app display name / backend appId), so
/// two projects with the same name but different packages stay separate.
///
/// No free downloads — every package/format needs a purchase:
/// - `apkdownload_inapp` → APK only for that package
/// - `bundledownload_inapp` → AAB only for that package
class DownloadTokenService {
  DownloadTokenService._();
  static final DownloadTokenService instance = DownloadTokenService._();

  /// Tokens like `pkg:com.example.app:apk` / `pkg:com.example.app:aab`.
  static const _unlockedFormatsKey = 'download_inapp_unlocked_formats_v2';

  /// Legacy unlock stores (cleared on migrate).
  static const _legacyFormatsKey = 'download_inapp_unlocked_formats';
  static const _legacyUnlockedProjectsKey = 'download_inapp_unlocked_projects';

  static const _processedKey = 'download_inapp_unlock_processed_v2';

  /// Legacy free-download flags (cleared; free path removed).
  static const _freeClaimedKey = 'download_inapp_free_package_claimed';
  static const _freePackageKey = 'download_inapp_free_package_name';
  static const _legacyFreeClaimedKey = 'download_inapp_free_project_claimed';
  static const _legacyFreeProjectIdKey = 'download_inapp_free_project_id';
  static const _legacyApkCountKey = 'apkdownload_inapp_count';
  static const _legacyAabCountKey = 'bundledownload_inapp_count';

  /// Set before launching the download IAP so purchase success unlocks
  /// the correct package + format.
  String? pendingPurchasePackageName;
  bool? pendingPurchaseIsAab;

  final ValueNotifier<int> version = ValueNotifier<int>(0);
  bool _didMigrate = false;

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  /// Normalize package for stable unlock keys.
  static String? normalizePackage(String? packageName) {
    final pkg = packageName?.trim().toLowerCase() ?? '';
    return pkg.isEmpty ? null : pkg;
  }

  String _token(String packageName, {required bool isAab}) =>
      'pkg:${normalizePackage(packageName)}:${isAab ? 'aab' : 'apk'}';

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
    if (_didMigrate) return;
    _didMigrate = true;
    final prefs = await _prefs;

    // Drop legacy appId unlock lists.
    await prefs.remove(_legacyFormatsKey);
    await prefs.remove(_legacyUnlockedProjectsKey);

    // Revoke any package that was unlocked only via the old free grant.
    final freePkg = normalizePackage(prefs.getString(_freePackageKey));
    if (freePkg != null) {
      final current =
          (prefs.getStringList(_unlockedFormatsKey) ?? const <String>[])
              .toSet();
      final before = current.length;
      current.remove(_token(freePkg, isAab: false));
      current.remove(_token(freePkg, isAab: true));
      if (current.length != before) {
        await prefs.setStringList(_unlockedFormatsKey, current.toList());
        version.value++;
        debugPrint('[DownloadUnlock] revoked free unlock for $freePkg');
      }
    }

    await prefs.remove(_freeClaimedKey);
    await prefs.remove(_freePackageKey);
    await prefs.remove(_legacyFreeClaimedKey);
    await prefs.remove(_legacyFreeProjectIdKey);
    await prefs.remove(_legacyApkCountKey);
    await prefs.remove(_legacyAabCountKey);
  }

  Future<bool> isFormatUnlocked(
    String? packageName, {
    required bool isAab,
  }) async {
    final pkg = normalizePackage(packageName);
    if (pkg == null) return false;
    final unlocked = await _loadUnlocked();
    return unlocked.contains(_token(pkg, isAab: isAab));
  }

  Future<void> _unlockFormats(
    String packageName, {
    required bool apk,
    required bool aab,
  }) async {
    final pkg = normalizePackage(packageName);
    if (pkg == null) return;
    final unlocked = await _loadUnlocked();
    var changed = false;
    if (apk && unlocked.add(_token(pkg, isAab: false))) changed = true;
    if (aab && unlocked.add(_token(pkg, isAab: true))) changed = true;
    if (changed) {
      await _saveUnlocked(unlocked);
    } else {
      version.value++;
    }
  }

  /// Unlocks only the purchased format for [packageName].
  Future<void> unlockFormatFromPurchase({
    required String packageName,
    required bool isAab,
    required String purchaseKey,
  }) async {
    final pkg = normalizePackage(packageName);
    if (pkg == null) return;

    final prefs = await _prefs;
    await _migrateIfNeeded();
    final processed = prefs.getStringList(_processedKey) ?? <String>[];
    final dedupeKey = purchaseKey.isNotEmpty
        ? purchaseKey
        : '$pkg:${isAab ? 'aab' : 'apk'}';

    if (processed.contains(dedupeKey)) {
      debugPrint('[DownloadUnlock] already processed: $dedupeKey');
      await _unlockFormats(pkg, apk: !isAab, aab: isAab);
      return;
    }
    processed.add(dedupeKey);
    await prefs.setStringList(_processedKey, processed);

    await _unlockFormats(pkg, apk: !isAab, aab: isAab);
    debugPrint(
      '[DownloadUnlock] ${isAab ? 'aab' : 'apk'} unlocked for package: $pkg',
    );
  }
}
