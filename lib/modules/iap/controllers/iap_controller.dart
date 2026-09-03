import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_to_app/core/ads/ad_presentation_gate.dart';
import 'package:web_to_app/core/ads/app_open_ad_manager.dart';
import 'package:web_to_app/core/constants/app_assets.dart';
import 'package:web_to_app/core/constants/app_feature_flags.dart';
import 'package:web_to_app/core/constants/app_info.dart';
import 'package:web_to_app/core/navigation/launch_flow.dart';
import 'package:web_to_app/core/services/analytics_service.dart';
import 'package:web_to_app/core/services/premium_service.dart';
import 'package:web_to_app/core/services/session_service.dart';
import 'package:web_to_app/core/utils/app_toast.dart';
import 'package:web_to_app/core/widgets/figma_svg_icon.dart';

/// Diginotes Android order: yearly (trial CTA) → monthly → weekly.
/// iOS fallback (no monthly): weekly (trial CTA) → yearly → lifetime.
enum IapPlan { yearly, monthly, weekly, lifetime }

/// Close delay only when IAP opens from splash / first-launch flow.
const Duration kIapCloseRevealDelayFromLaunch = Duration(milliseconds: 3500);

class IapController extends GetxController {
  final isPurchasing = false.obs;
  final isRestoring = false.obs;
  final isLoadingProducts = true.obs;
  final selectedPlan = IapPlan.yearly.obs;
  final showCloseButton = false.obs;

  final weeklyPrice = RxnString();
  final monthlyPrice = RxnString();
  final yearlyPrice = RxnString();
  final lifetimePrice = RxnString();

  final yearlyHasTrial = false.obs;
  final weeklyHasTrial = false.obs;

  PremiumService? _premiumService;
  Timer? _closeRevealTimer;

  /// True from buy tap until a terminal purchase status (or failed launch).
  /// Kept separate from [isPurchasing] because Android clears the spinner when
  /// the Play sheet opens, before the purchase stream completes.
  bool _awaitingPurchaseResult = false;

  bool get useMonthlyLayout => AppFeatureFlags.monthlyPlanEnabled;

  Future<PremiumService> get _service async {
    _premiumService ??= await PremiumService.getInstance();
    return _premiumService!;
  }

  void _onPurchaseStatus(PurchaseStatus status, PurchaseDetails? purchase) {
    if (status == PurchaseStatus.pending) return;

    if (status == PurchaseStatus.purchased ||
        status == PurchaseStatus.restored) {
      final fromUserBuy = _awaitingPurchaseResult;
      _awaitingPurchaseResult = false;
      isPurchasing.value = false;
      // Restore button flow handles its own toast + dismiss.
      if (!fromUserBuy || isRestoring.value) return;
      AppToast.success('purchase_success'.tr);
      if (PremiumService.isPremiumCached) {
        Get.find<SessionService>().notifyIapPremiumChanged();
        LaunchFlow.completeIap();
      }
      return;
    }

    if (status == PurchaseStatus.canceled) {
      _awaitingPurchaseResult = false;
      isPurchasing.value = false;
      return;
    }

    if (status == PurchaseStatus.error) {
      _awaitingPurchaseResult = false;
      isPurchasing.value = false;
      final message = _premiumService?.getLastPurchaseError(purchase) ??
          'purchase_failed'.tr;
      AppToast.error('purchase_failed'.tr, description: message);
    }
  }

  @override
  void onInit() {
    super.onInit();
    AdPresentationGate.markIapOpened();
    AppOpenAdManager.instance.blockAppOpenAds = true;
    selectedPlan.value =
        useMonthlyLayout ? IapPlan.yearly : IapPlan.weekly;
    AnalyticsService.instance.logIapScreen(
      fromLaunch: LaunchFlow.iapOpenedFromLaunch,
      fromSettings: !LaunchFlow.iapOpenedFromLaunch,
    );
    // Warm close SVG during the delay so circle bg + X paint together.
    unawaited(FigmaSvgIcon.preload(AppAssets.iapCloseIcon));
    if (LaunchFlow.iapOpenedFromLaunch) {
      _closeRevealTimer = Timer(kIapCloseRevealDelayFromLaunch, () {
        showCloseButton.value = true;
      });
    } else {
      showCloseButton.value = true;
    }
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
    monthlyPrice.value = service.getMonthlyPrice();
    yearlyPrice.value = service.getYearlyPrice();
    lifetimePrice.value = service.getLifetimePrice();
    yearlyHasTrial.value = service.hasYearlyFreeTrial();
    weeklyHasTrial.value = service.hasWeeklyFreeTrial();
  }

  String displayPrice(IapPlan plan) {
    if (isLoadingProducts.value) {
      return 'iap_price_loading'.tr;
    }

    final price = switch (plan) {
      IapPlan.yearly => yearlyPrice.value,
      IapPlan.monthly => monthlyPrice.value,
      IapPlan.weekly => weeklyPrice.value,
      IapPlan.lifetime => lifetimePrice.value,
    };

    return price ?? '—';
  }

  /// Top CTA title: free trial when store offers one on the primary plan.
  String displayPrimaryCtaTitle() {
    if (useMonthlyLayout) {
      return yearlyHasTrial.value
          ? 'iap_start_free_trial'.tr
          : 'iap_continue'.tr;
    }
    return weeklyHasTrial.value
        ? 'iap_start_free_trial'.tr
        : 'iap_continue'.tr;
  }

  /// Top CTA subtitle with localized recurring price.
  String displayPrimaryCtaSubtitle() {
    if (isLoadingProducts.value) {
      return 'iap_price_loading'.tr;
    }

    if (useMonthlyLayout) {
      final price = yearlyPrice.value ?? '—';
      return yearlyHasTrial.value
          ? 'iap_trial_then_year'.trParams({'price': price})
          : 'iap_price_year'.trParams({'price': price});
    }

    final price = weeklyPrice.value ?? '—';
    return weeklyHasTrial.value
        ? 'iap_trial_subtitle_dynamic'.trParams({'price': price})
        : 'iap_price_week'.trParams({'price': price});
  }

  IapPlan get primaryPlan =>
      useMonthlyLayout ? IapPlan.yearly : IapPlan.weekly;

  Future<void> purchase(IapPlan plan) async {
    if (isPurchasing.value || isRestoring.value || _awaitingPurchaseResult) {
      return;
    }

    selectedPlan.value = plan;
    isPurchasing.value = true;
    _awaitingPurchaseResult = true;

    try {
      final service = await _service;

      if (!service.isAvailable) {
        AppToast.error(
          'purchase_failed'.tr,
          description: 'iap_billing_unavailable'.tr,
        );
        _awaitingPurchaseResult = false;
        return;
      }

      await service.ensureProductsLoaded();
      await service.reloadProducts();
      _applyStorePrices(service);

      final launched = await switch (plan) {
        IapPlan.yearly => service.purchaseYearlySubscription(),
        IapPlan.monthly => service.purchaseMonthlySubscription(),
        IapPlan.weekly => service.purchaseWeeklySubscription(),
        IapPlan.lifetime => service.purchaseLifetime(),
      };

      if (!launched) {
        _awaitingPurchaseResult = false;
        if (service.lastPurchaseCancelledByUser) return;
        AppToast.error(
          'purchase_failed'.tr,
          description: 'iap_product_unavailable'.tr,
        );
      }
      // On successful launch, [_onPurchaseStatus] clears the flag and dismisses.
    } catch (_) {
      _awaitingPurchaseResult = false;
    } finally {
      // Android: clear spinner when Play sheet opens; keep awaiting flag.
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
    AdPresentationGate.markIapClosed();
    AdPresentationGate.reconcileIapVisibility();
    AppOpenAdManager.instance.blockNextResume();
    AppOpenAdManager.instance.blockAppOpenAds =
        AdPresentationGate.isOnIapRoute;
    _premiumService?.removePurchaseStatusCallback(_onPurchaseStatus);
    super.onClose();
  }
}
