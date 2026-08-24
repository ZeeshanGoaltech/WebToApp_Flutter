import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Per-project unlock from `apkdownload_inapp` / `bundledownload_inapp`.
///
/// Buying either product while on a project unlocks **unlimited APK + AAB**
/// downloads for that project only. Independent of `threescan_inapp` credits.
class DownloadTokenService {
  DownloadTokenService._();
  static final DownloadTokenService instance = DownloadTokenService._();

  static const _unlockedProjectsKey = 'download_inapp_unlocked_projects';
  static const _processedKey = 'download_inapp_unlock_processed';

  /// Set before launching the download IAP so purchase success can unlock
  /// the correct project.
  String? pendingPurchaseAppId;

  final ValueNotifier<int> version = ValueNotifier<int>(0);

  Future<Set<String>> _loadUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_unlockedProjectsKey) ?? const <String>[])
        .where((id) => id.trim().isNotEmpty)
        .toSet();
  }

  Future<void> _saveUnlocked(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_unlockedProjectsKey, ids.toList());
    version.value++;
  }

  Future<bool> isProjectUnlocked(String? appId) async {
    if (appId == null || appId.trim().isEmpty) return false;
    final unlocked = await _loadUnlocked();
    return unlocked.contains(appId.trim());
  }

  /// Unlocks unlimited APK + AAB downloads for [appId] after a successful buy.
  Future<void> unlockProjectFromPurchase({
    required String appId,
    required String purchaseKey,
  }) async {
    final id = appId.trim();
    if (id.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final processed = prefs.getStringList(_processedKey) ?? <String>[];
    if (purchaseKey.isNotEmpty && processed.contains(purchaseKey)) {
      debugPrint('[DownloadUnlock] already processed: $purchaseKey');
      // Still ensure project is unlocked if a prior write failed mid-way.
      final unlocked = await _loadUnlocked();
      if (!unlocked.contains(id)) {
        unlocked.add(id);
        await _saveUnlocked(unlocked);
      }
      return;
    }
    if (purchaseKey.isNotEmpty) {
      processed.add(purchaseKey);
      await prefs.setStringList(_processedKey, processed);
    }

    final unlocked = await _loadUnlocked();
    if (unlocked.add(id)) {
      await _saveUnlocked(unlocked);
      debugPrint('[DownloadUnlock] project unlocked: $id');
    } else {
      version.value++;
      debugPrint('[DownloadUnlock] project already unlocked: $id');
    }
  }
}
