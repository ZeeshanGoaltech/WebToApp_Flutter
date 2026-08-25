import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_to_app/core/ads/ad_remote_config_service.dart';
import 'package:web_to_app/core/services/iap_product_id_resolver.dart';

/// Diginotes-style local credits for API actions (build / download).
/// Subscription IAP stays separate and does not grant these credits.
class CreditService {
  CreditService._();
  static final CreditService instance = CreditService._();

  /// Consumable credit pack (+3 builds). Separate from subscription SKUs.
  /// Also recognizes Download APK/AAB consumables that grant the same credits.
  static const String packProductId = 'threescan_inapp';
  static const String packFallbackPrice = r'$1.99';
  static const int defaultFreeLimit = 3;
  static const int defaultPackCredits = 3;

  static const _freeKey = 'webtoapp.credits.free_used';
  static const _paidKey = 'webtoapp.credits.paid';
  static const _purchasedKey = 'webtoapp.credits.has_purchased';
  static const _processedKey = 'webtoapp.credits.processed';

  final ValueNotifier<int> paidCredits = ValueNotifier<int>(0);
  final ValueNotifier<int> stateVersion = ValueNotifier<int>(0);

  int _freeUsed = 0;
  bool _hasPurchased = false;
  final Set<String> _processedKeys = <String>{};
  bool _initialized = false;

  /// Free uses before paywall — Firebase RC `ai_module_free_credits`.
  int get freeLimit => AdRemoteConfigService.instance
      .getInt(RemoteConfigKeys.aiModuleFreeCredits, defaultFreeLimit)
      .clamp(1, 99);

  /// Credits per pack purchase — Firebase RC `ai_module_pack_credits`.
  int get packCredits => AdRemoteConfigService.instance
      .getInt(RemoteConfigKeys.aiModulePackCredits, defaultPackCredits)
      .clamp(1, 99);

  bool get hasPurchasedPackBefore =>
      _hasPurchased || paidCredits.value > 0;

  int get remaining {
    if (paidCredits.value > 0 || _hasPurchased) {
      return paidCredits.value.clamp(0, 999);
    }
    final left = freeLimit - _freeUsed;
    return left > 0 ? left.clamp(0, freeLimit) : 0;
  }

  /// Denominator for badge label (`remaining/total`).
  int get displayTotal {
    if (paidCredits.value > 0 || _hasPurchased) {
      if (paidCredits.value <= 0) return packCredits;
      return paidCredits.value >= packCredits
          ? paidCredits.value
          : packCredits;
    }
    return freeLimit;
  }

  String get displayLabel => '$remaining/$displayTotal';

  bool get isExhausted => remaining <= 0;

  Future<void> initialize() async {
    if (_initialized) return;
    await _loadLocal();
    _initialized = true;
  }

  Future<void> _loadLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _freeUsed = prefs.getInt(_freeKey) ?? 0;
      paidCredits.value = prefs.getInt(_paidKey) ?? 0;
      _hasPurchased = prefs.getBool(_purchasedKey) ?? false;
      _processedKeys
        ..clear()
        ..addAll(prefs.getStringList(_processedKey) ?? const []);
      stateVersion.value++;
    } catch (e) {
      debugPrint('[Credits] load failed: $e');
    }
  }

  Future<void> _saveLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_freeKey, _freeUsed);
      await prefs.setInt(_paidKey, paidCredits.value);
      await prefs.setBool(_purchasedKey, _hasPurchased);
      await prefs.setStringList(_processedKey, _processedKeys.toList());
    } catch (e) {
      debugPrint('[Credits] save failed: $e');
    }
  }

  Future<bool> canUse() async {
    await initialize();
    return remaining > 0;
  }

  Future<bool> consume() async {
    await initialize();

    if (paidCredits.value > 0) {
      paidCredits.value--;
      await _saveLocal();
      stateVersion.value++;
      return true;
    }

    if (_freeUsed < freeLimit) {
      _freeUsed++;
      await _saveLocal();
      stateVersion.value++;
      return true;
    }

    stateVersion.value++;
    return false;
  }

  Future<void> refund() async {
    await initialize();

    if (_hasPurchased) {
      paidCredits.value++;
      await _saveLocal();
      stateVersion.value++;
      return;
    }

    if (_freeUsed > 0) {
      _freeUsed--;
      await _saveLocal();
      stateVersion.value++;
    }
  }

  Future<bool> addPurchasedPack(String purchaseKey) async {
    await initialize();

    if (purchaseKey.isNotEmpty && _processedKeys.contains(purchaseKey)) {
      debugPrint('[Credits] already processed: $purchaseKey');
      return false;
    }
    if (purchaseKey.isNotEmpty) {
      _processedKeys.add(purchaseKey);
    }

    paidCredits.value += packCredits;
    _freeUsed = 0;
    _hasPurchased = true;
    await _saveLocal();
    stateVersion.value++;
    return true;
  }

  static bool isPackProductId(String productId) =>
      IapProductIdResolver.instance.isCreditsGrantingProductId(productId);
}
