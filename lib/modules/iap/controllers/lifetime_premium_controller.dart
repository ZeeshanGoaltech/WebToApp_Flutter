import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/app/routes/app_routes.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_to_app/core/ads/ad_presentation_gate.dart';
import 'package:web_to_app/core/ads/app_open_ad_manager.dart';
import 'package:web_to_app/core/constants/app_info.dart';
import 'package:web_to_app/core/services/analytics_service.dart';
import 'package:web_to_app/core/services/premium_service.dart';
import 'package:web_to_app/core/services/session_service.dart';
import 'package:web_to_app/core/utils/app_toast.dart';

const String kMissingStorePrice = '--';
const Duration kLifetimeCloseRevealDelay = Duration(seconds: 3);

class LifetimePremiumController extends GetxController {
  final isPurchasing = false.obs;
  final showCloseButton = false.obs;
  final lifetimePrice = kMissingStorePrice.obs;

  PremiumService? _premiumService;
  Timer? _closeRevealTimer;

  Future<PremiumService> get _service async {
    _premiumService ??= await PremiumService.getInstance();
    return _premiumService!;
  }

  @override
  void onInit() {
    super.onInit();
    AdPresentationGate.markIapOpened();
    AppOpenAdManager.instance.blockAppOpenAds = true;
    unawaited(AnalyticsService.instance.logLifetimePremiumOpen());
    _closeRevealTimer = Timer(kLifetimeCloseRevealDelay, () {
      showCloseButton.value = true;
    });
    unawaited(_initPremium());
  }

  Future<void> _initPremium() async {
    final service = await _service;
    service.addPurchaseStatusCallback(_onPurchaseStatus);
    await _initBillingAndPrices();
    await _loadPremiumStatus();
  }

  Future<void> _loadPremiumStatus() async {
    final service = await _service;
    await service.restorePurchasesAndWait();
    if (service.hasLifetimeAccess()) {
      finish();
    }
  }

  Future<void> _initBillingAndPrices() async {
    final service = await _service;
    await service.ensureProductsLoaded();
    await service.reloadProducts();
    lifetimePrice.value = service.getLifetimePrice() ?? kMissingStorePrice;
  }

  void _onPurchaseStatus(PurchaseStatus status, PurchaseDetails? purchase) {
    if (status == PurchaseStatus.pending) return;

    if (status == PurchaseStatus.purchased ||
        status == PurchaseStatus.restored) {
      isPurchasing.value = false;
      if (PremiumService.isPremiumCached) {
        Get.find<SessionService>().notifyIapPremiumChanged();
        showSuccessAndFinish();
      }
      return;
    }

    if (status == PurchaseStatus.canceled) {
      isPurchasing.value = false;
      return;
    }

    if (status == PurchaseStatus.error) {
      isPurchasing.value = false;
      final message = _premiumService?.getLastPurchaseError(purchase) ??
          'premium_purchase_failed'.tr;
      AppToast.error('premium_purchase_failed'.tr, description: message);
    }
  }

  Future<void> buyLifetime() async {
    if (isPurchasing.value) return;
    isPurchasing.value = true;

    try {
      final service = await _service;

      if (!service.isAvailable) {
        AppToast.error('premium_unavailable'.tr);
        return;
      }

      await service.ensureProductsLoaded();
      await service.reloadProducts();
      lifetimePrice.value = service.getLifetimePrice() ?? kMissingStorePrice;

      final product = service.getLifetimeProduct();
      if (product == null) {
        AppToast.error('premium_unavailable'.tr);
        return;
      }

      final launched = await service.purchaseLifetime();
      if (!launched) {
        if (service.lastPurchaseCancelledByUser) return;
        AppToast.error('premium_purchase_failed'.tr);
      }
    } finally {
      if (!PremiumService.isPremiumCached) {
        isPurchasing.value = false;
      }
    }
  }

  Future<void> showSuccessAndFinish() async {
    await Get.dialog<void>(
      AlertDialog(
        title: Text('premium_activated_title'.tr),
        content: Text('premium_activated_body'.tr),
        actions: [
          FilledButton(
            onPressed: Get.back,
            child: Text('common_ok'.tr),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    finish();
  }

  void finish() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    } else {
      Get.offAllNamed(AppRoutes.home);
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
    final opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!opened) {
      AppToast.info('request_failed'.tr, description: url);
    }
  }

  @override
  void onClose() {
    _closeRevealTimer?.cancel();
    AdPresentationGate.markIapClosed();
    AdPresentationGate.reconcileIapVisibility();
    AppOpenAdManager.instance.blockAppOpenAds =
        AdPresentationGate.isOnIapRoute;
    _premiumService?.removePurchaseStatusCallback(_onPurchaseStatus);
    super.onClose();
  }
}
