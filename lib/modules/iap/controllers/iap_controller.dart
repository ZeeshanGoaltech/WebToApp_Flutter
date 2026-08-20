import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_to_app/core/ads/ad_presentation_gate.dart';
import 'package:web_to_app/core/ads/app_open_ad_manager.dart';
import 'package:web_to_app/core/constants/app_info.dart';
import 'package:web_to_app/core/navigation/launch_flow.dart';
import 'package:web_to_app/core/services/premium_service.dart';
import 'package:web_to_app/core/services/session_service.dart';
import 'package:web_to_app/core/utils/app_toast.dart';
import 'package:web_to_app/modules/iap/utils/iap_price_formatter.dart';

enum IapPlan { freeTrial, yearly, lifetime }

class IapController extends GetxController {
  final isPurchasing = false.obs;
  final isRestoring = false.obs;
  final isLoadingProducts = true.obs;
  final selectedPlan = IapPlan.freeTrial.obs;

  final weeklyPrice = RxnString();
  final yearlyPrice = RxnString();
  final lifetimePrice = RxnString();
  final trialSubtitle = RxnString();
  final yearlyPerWeekSubtitle = RxnString();

  PremiumService? _premiumService;

  Future<PremiumService> get _service async {
    _premiumService ??= await PremiumService.getInstance();
    return _premiumService!;
  }

  void _onPurchaseStatus(PurchaseStatus status, PurchaseDetails? purchase) {
    if (status == PurchaseStatus.pending) return;

    if (status == PurchaseStatus.purchased ||
        status == PurchaseStatus.restored) {
      isPurchasing.value = false;
      AppToast.success('purchase_success'.tr);
      if (PremiumService.isPremiumCached) {
        Get.find<SessionService>().notifyIapPremiumChanged();
        LaunchFlow.completeIap();
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
          'purchase_failed'.tr;
      AppToast.error('purchase_failed'.tr, description: message);
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Hide app-open + block interstitials while paywall is visible.
    AdPresentationGate.markIapOpened();
    AppOpenAdManager.instance.blockAppOpenAds = true;
    _initPremium();
  }

  Future<void> _initPremium() async {
    final service = await _service;
    service.addPurchaseStatusCallback(_onPurchaseStatus);
    await _loadStoreProducts();
  }

  Future<void> _loadStoreProducts() async {
    isLoadingProducts.value = true;
    try {
      final service = await _service;
      await service.ensureProductsLoaded();
      await service.reloadProducts();
      _applyStorePrices(service);
    } finally {
      isLoadingProducts.value = false;
    }
  }

  void _applyStorePrices(PremiumService service) {
    weeklyPrice.value = service.getWeeklyPrice();
    yearlyPrice.value = service.getYearlyPrice();
    lifetimePrice.value = service.getLifetimePrice();

    final weekly = service.getWeeklySubscription();
    trialSubtitle.value = weekly == null
        ? null
        : 'iap_trial_subtitle_dynamic'.trParams({'price': weekly.price});

    final yearly = service.getYearlySubscription();
    yearlyPerWeekSubtitle.value = yearly == null
        ? null
        : 'iap_yearly_per_week_dynamic'.trParams({
            'price': IapPriceFormatter.formatPerWeek(yearly),
          });
  }

  String displayPrice(IapPlan plan) {
    if (isLoadingProducts.value) {
      return 'iap_price_loading'.tr;
    }

    final price = switch (plan) {
      IapPlan.freeTrial => weeklyPrice.value,
      IapPlan.yearly => yearlyPrice.value,
      IapPlan.lifetime => lifetimePrice.value,
    };

    return price ?? '—';
  }

  String? displayYearlyPerWeekSubtitle() {
    if (isLoadingProducts.value) {
      return 'iap_price_loading'.tr;
    }
    return yearlyPerWeekSubtitle.value;
  }

  String? displayTrialSubtitle() {
    if (isLoadingProducts.value) {
      return 'iap_price_loading'.tr;
    }
    return trialSubtitle.value;
  }

  Future<void> purchase(IapPlan plan) async {
    if (isPurchasing.value || isRestoring.value) return;

    selectedPlan.value = plan;
    isPurchasing.value = true;

    try {
      final service = await _service;

      if (!service.isAvailable) {
        AppToast.error(
          'purchase_failed'.tr,
          description: 'iap_billing_unavailable'.tr,
        );
        return;
      }

      await service.ensureProductsLoaded();
      await service.reloadProducts();
      _applyStorePrices(service);

      final launched = switch (plan) {
        IapPlan.freeTrial => service.purchaseWeeklySubscription(),
        IapPlan.yearly => service.purchaseYearlySubscription(),
        IapPlan.lifetime => service.purchaseLifetime(),
      };

      final success = await launched;
      if (!success) {
        if (service.lastPurchaseCancelledByUser) return;
        AppToast.error(
          'purchase_failed'.tr,
          description: 'iap_product_unavailable'.tr,
        );
      }
    } finally {
      if (!PremiumService.isPremiumCached) {
        isPurchasing.value = false;
      }
    }
  }

  Future<void> restorePurchases() async {
    if (isPurchasing.value || isRestoring.value) return;

    isRestoring.value = true;
    try {
      final service = await _service;
      final restored = await service.restorePurchasesAndWait();
      if (restored) {
        AppToast.success('restore_success'.tr);
        Get.find<SessionService>().notifyIapPremiumChanged();
        LaunchFlow.completeIap();
      } else {
        AppToast.info('restore_no_purchases'.tr);
      }
    } finally {
      isRestoring.value = false;
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
    AdPresentationGate.markIapClosed();
    AdPresentationGate.reconcileIapVisibility();
    AppOpenAdManager.instance.blockAppOpenAds =
        AdPresentationGate.isOnIapRoute;
    _premiumService?.removePurchaseStatusCallback(_onPurchaseStatus);
    super.onClose();
  }
}
