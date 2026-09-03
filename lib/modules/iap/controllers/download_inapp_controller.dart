import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_to_app/core/ads/ad_presentation_gate.dart';
import 'package:web_to_app/core/ads/app_open_ad_manager.dart';
import 'package:web_to_app/core/constants/app_info.dart';
import 'package:web_to_app/core/services/analytics_service.dart';
import 'package:web_to_app/core/services/download_token_service.dart';
import 'package:web_to_app/core/services/iap_product_id_resolver.dart';
import 'package:web_to_app/core/services/premium_service.dart';
import 'package:web_to_app/core/utils/app_toast.dart';

const String kDownloadInappMissingPrice = '--';
const Duration kDownloadInappCloseRevealDelay = Duration(seconds: 2);

/// Lifetime-style paywall for Download APK / AAB.
///
/// Each product unlocks **only that format** for this project:
/// - APK button → `apkdownload_inapp` (APK only)
/// - AAB button → `bundledownload_inapp` (AAB only)
class DownloadInappController extends GetxController {
  final isPurchasing = false.obs;
  final showCloseButton = false.obs;
  final packPrice = kDownloadInappMissingPrice.obs;
  final isAab = false.obs;
  final appId = ''.obs;

  PremiumService? _premiumService;
  Timer? _closeRevealTimer;
  bool _wasUnlockedWhenOpened = false;
  bool _finishing = false;

  String get productId =>
      IapProductIdResolver.instance.getDownloadInappProductId(
        isAab: isAab.value,
      );

  Future<PremiumService> get _service async {
    _premiumService ??= await PremiumService.getInstance();
    return _premiumService!;
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      isAab.value = args['isAab'] == true;
      appId.value = (args['appId'] as String?)?.trim() ?? '';
    } else {
      isAab.value = args == true;
    }

    DownloadTokenService.instance.pendingPurchaseAppId =
        appId.value.isEmpty ? null : appId.value;
    DownloadTokenService.instance.pendingPurchaseIsAab = isAab.value;

    AdPresentationGate.markIapOpened();
    AppOpenAdManager.instance.blockAppOpenAds = true;
    unawaited(
      AnalyticsService.instance.logDownloadInappOpen(isAab: isAab.value),
    );

    DownloadTokenService.instance.version.addListener(_onUnlockChanged);

    _closeRevealTimer = Timer(kDownloadInappCloseRevealDelay, () {
      showCloseButton.value = true;
    });
    unawaited(_initAndMaybeSkip());
  }

  Future<void> _initAndMaybeSkip() async {
    // Subscriptions do not unlock downloads — only per-format unlock.
    _wasUnlockedWhenOpened = await DownloadTokenService.instance
        .isFormatUnlocked(appId.value, isAab: isAab.value);

    if (_wasUnlockedWhenOpened) {
      finish(purchased: true);
      return;
    }
    await _initBillingAndPrices();
  }

  void _onUnlockChanged() {
    unawaited(_checkFormatUnlocked());
  }

  Future<void> _checkFormatUnlocked() async {
    if (_wasUnlockedWhenOpened) return;
    final unlocked = await DownloadTokenService.instance
        .isFormatUnlocked(appId.value, isAab: isAab.value);
    if (!unlocked) return;
    unawaited(showSuccessAndFinish());
  }

  Future<void> _initBillingAndPrices() async {
    final service = await _service;
    await service.ensureProductsLoaded();
    await service.reloadProducts();
    _refreshPrice();
  }

  void _refreshPrice() {
    final price = _premiumService?.getDownloadInappPrice(isAab: isAab.value);
    packPrice.value =
        (price != null && price.trim().isNotEmpty)
            ? price
            : kDownloadInappMissingPrice;
  }

  Future<void> buyDownloadPack() async {
    if (isPurchasing.value || _finishing) return;
    if (appId.value.isEmpty) {
      AppToast.error('credits_pack_purchase_failed'.tr);
      return;
    }

    isPurchasing.value = true;
    DownloadTokenService.instance.pendingPurchaseAppId = appId.value;
    DownloadTokenService.instance.pendingPurchaseIsAab = isAab.value;

    try {
      final service = await _service;

      if (!service.isAvailable) {
        AppToast.error('premium_unavailable'.tr);
        return;
      }

      await service.ensureProductsLoaded();
      await service.reloadProducts();
      _refreshPrice();

      if (packPrice.value == kDownloadInappMissingPrice) {
        AppToast.error('credits_pack_purchase_failed'.tr);
        return;
      }

      final launched = await service.purchaseDownloadInapp(isAab: isAab.value);
      if (!launched) {
        if (service.lastPurchaseCancelledByUser) return;
        AppToast.error('credits_pack_purchase_failed'.tr);
      }
    } finally {
      isPurchasing.value = false;
    }
  }

  Future<void> showSuccessAndFinish() async {
    if (_finishing) return;
    _finishing = true;
    await Get.dialog<void>(
      AlertDialog(
        title: Text('common_success'.tr),
        content: Text('download_inapp_purchase_success'.tr),
        actions: [
          FilledButton(
            onPressed: Get.back,
            child: Text('common_ok'.tr),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    finish(purchased: true);
  }

  void finish({bool purchased = false}) {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back(result: purchased);
    }
  }

  Future<void> openTerms() => _openExternalUrl(AppInfo.termsAndConditionsUrl);

  Future<void> openPrivacy() => _openExternalUrl(AppInfo.privacyPolicyUrl);

  Future<void> openManageSubscriptions() async {
    final url = switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.macOS =>
        AppInfo.appStoreSubscriptionsUrl,
      _ => AppInfo.playStoreSubscriptionsUrl,
    };
    await _openExternalUrl(url);
  }

  Future<void> _openExternalUrl(String url) async {
    AppOpenAdManager.instance.blockNextResume();
    final opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    AppOpenAdManager.instance.blockNextResume();
    if (!opened) {
      AppToast.info('request_failed'.tr, description: url);
    }
  }

  @override
  void onClose() {
    _closeRevealTimer?.cancel();
    DownloadTokenService.instance.version.removeListener(_onUnlockChanged);
    if (DownloadTokenService.instance.pendingPurchaseAppId == appId.value) {
      DownloadTokenService.instance.pendingPurchaseAppId = null;
      DownloadTokenService.instance.pendingPurchaseIsAab = null;
    }
    AdPresentationGate.markIapClosed();
    AdPresentationGate.reconcileIapVisibility();
    AppOpenAdManager.instance.blockNextResume();
    AppOpenAdManager.instance.blockAppOpenAds =
        AdPresentationGate.isOnIapRoute;
    super.onClose();
  }
}
