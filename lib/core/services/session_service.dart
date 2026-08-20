import 'package:get/get.dart';
import 'package:web_to_app/core/services/token_storage.dart';
import 'package:web_to_app/data/models/auth_models.dart';
import 'package:web_to_app/data/models/billing_models.dart';
import 'package:web_to_app/data/repositories/auth_repository.dart';
import 'package:web_to_app/data/repositories/billing_repository.dart';
import 'package:web_to_app/core/services/premium_service.dart';

class SessionService extends GetxService {
  final Rxn<AuthUser> user = Rxn<AuthUser>();
  final Rxn<EntitlementDto> entitlement = Rxn<EntitlementDto>();
  final RxBool isGuest = false.obs;
  final RxBool isLoading = false.obs;
  final RxInt _iapPremiumTick = 0.obs;

  bool get isAuthenticated => !isGuest.value && user.value != null;

  void notifyIapPremiumChanged() => _iapPremiumTick.value++;

  bool get hasPremiumAccess {
    _iapPremiumTick.value;
    if (entitlement.value?.isPremium == true) return true;
    return PremiumService.isPremiumCached;
  }

  Future<void> setAuthResult(
    AuthResult result, {
    String? displayName,
  }) async {
    isGuest.value = false;
    await Get.find<TokenStorage>().setGuestMode(false);
    final enriched = _enrichUser(
      result.user,
      displayName: displayName,
    );
    user.value = enriched;
    await Get.find<AuthRepository>().persistTokens(result.tokens);
    await _persistProfile(enriched);
  }

  Future<void> setGuest() async {
    isGuest.value = true;
    user.value = null;
    entitlement.value = null;
    final storage = Get.find<TokenStorage>();
    await storage.clearAuth();
    await storage.setGuestMode(true);
  }

  void restoreGuestSession() {
    isGuest.value = true;
    user.value = null;
    entitlement.value = null;
  }

  bool get hasActiveSession => isGuest.value || isAuthenticated;

  Future<void> clearSession() async {
    isGuest.value = false;
    user.value = null;
    entitlement.value = null;
    await Get.find<AuthRepository>().logout();
  }

  Future<bool> restoreSession() async {
    final storage = Get.find<TokenStorage>();
    if (!storage.hasTokens) return false;

    isLoading.value = true;
    try {
      final me = await _loadMe();
      isGuest.value = false;
      user.value = me.user;
      entitlement.value = me.entitlement;
      return true;
    } catch (_) {
      try {
        await Get.find<AuthRepository>().refresh();
        final me = await _loadMe();
        isGuest.value = false;
        user.value = me.user;
        entitlement.value = me.entitlement;
        return true;
      } catch (_) {
        await storage.clear();
        return false;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshEntitlement() async {
    if (!isAuthenticated) return;
    entitlement.value = await Get.find<BillingRepository>().entitlement();
  }

  Future<void> refreshProfile() async {
    if (!isAuthenticated) return;
    final me = await _loadMe();
    user.value = me.user;
    entitlement.value = me.entitlement;
    await _persistProfile(me.user);
  }

  Future<MeResult> _loadMe() async {
    final me = await Get.find<AuthRepository>().me();
    return MeResult(
      user: _enrichUser(me.user),
      entitlement: me.entitlement,
    );
  }

  AuthUser _enrichUser(AuthUser apiUser, {String? displayName}) {
    final storage = Get.find<TokenStorage>();
    return apiUser.mergeProfile(
      email: apiUser.email ?? user.value?.email ?? storage.savedEmail,
      displayName:
          displayName ?? apiUser.displayName ?? user.value?.displayName ?? storage.savedDisplayName,
    );
  }

  Future<void> _persistProfile(AuthUser profile) async {
    await Get.find<TokenStorage>().saveProfile(
      email: profile.email,
      displayName: profile.displayName,
    );
  }
}
