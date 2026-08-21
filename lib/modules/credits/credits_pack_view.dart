import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_to_app/core/ads/ad_presentation_gate.dart';
import 'package:web_to_app/core/ads/app_open_ad_manager.dart';
import 'package:web_to_app/core/services/analytics_service.dart';
import 'package:web_to_app/core/services/credit_service.dart';
import 'package:web_to_app/core/services/premium_service.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/utils/app_toast.dart';
import 'package:web_to_app/core/utils/responsive.dart';
import 'package:web_to_app/core/widgets/button_loading_indicator.dart';

class CreditsPackController extends GetxController {
  final isPurchasing = false.obs;
  final showCloseButton = false.obs;
  final packPrice = CreditService.packFallbackPrice.obs;

  late final int _creditsWhenOpened;
  Timer? _closeTimer;
  PremiumService? _premium;

  int get packCredits => CreditService.instance.packCredits;

  @override
  void onInit() {
    super.onInit();
    AdPresentationGate.markIapOpened();
    AppOpenAdManager.instance.blockAppOpenAds = true;
    unawaited(AnalyticsService.instance.logCreditsPackOpen());
    _creditsWhenOpened = CreditService.instance.paidCredits.value;
    CreditService.instance.paidCredits.addListener(_onCreditsChanged);
    _closeTimer = Timer(const Duration(seconds: 3), () {
      showCloseButton.value = true;
    });
    unawaited(_loadPrice());
  }

  @override
  void onClose() {
    _closeTimer?.cancel();
    CreditService.instance.paidCredits.removeListener(_onCreditsChanged);
    AdPresentationGate.markIapClosed();
    AdPresentationGate.reconcileIapVisibility();
    AppOpenAdManager.instance.blockAppOpenAds =
        AdPresentationGate.isOnIapRoute;
    super.onClose();
  }

  void _onCreditsChanged() {
    final now = CreditService.instance.paidCredits.value;
    if (now <= _creditsWhenOpened || isClosed) return;
    unawaited(_finishSuccess());
  }

  Future<void> _loadPrice() async {
    _premium = await PremiumService.getInstance();
    await _premium!.ensureProductsLoaded();
    await _premium!.reloadProducts();
    final price = _premium!.getCreditsPackPrice();
    if (price != null && price.isNotEmpty) {
      packPrice.value = price;
    }
  }

  Future<void> purchase() async {
    if (isPurchasing.value) return;
    isPurchasing.value = true;
    try {
      _premium ??= await PremiumService.getInstance();
      await _premium!.ensureProductsLoaded();
      await _premium!.reloadProducts();

      final started = await _premium!.purchaseCreditsPack();
      if (!started) {
        if (_premium!.lastPurchaseCancelledByUser) return;
        AppToast.error(
          'credits_pack_purchase_failed'.tr,
          description: 'iap_product_unavailable'.tr,
        );
      }
    } finally {
      isPurchasing.value = false;
    }
  }

  Future<void> _finishSuccess() async {
    if (isClosed) return;
    AppToast.success('credits_pack_purchase_success'.tr);
    Get.back(result: true);
  }

  void close() => Get.back(result: false);
}

class CreditsPackBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CreditsPackController());
  }
}

/// Diginotes-style single consumable pack paywall (+3 credits).
class CreditsPackView extends GetView<CreditsPackController> {
  const CreditsPackView({super.key});

  static const _pink = Color(0xFF6C63FF);
  static const _page = Color(0xFFF7F7FB);
  static const _card = Color(0xFFFFFFFF);
  static const _border = Color(0xFFE8E8F0);
  static const _text = Color(0xFF1A1A2E);
  static const _subText = Color(0xFF6B6B80);

  @override
  Widget build(BuildContext context) {
    final credits = controller.packCredits;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: _page,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              Responsive.w(context, 20),
              Responsive.w(context, 12),
              Responsive.w(context, 20),
              Responsive.w(context, 20),
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Obx(() {
                    if (!controller.showCloseButton.value) {
                      return SizedBox(height: Responsive.w(context, 36));
                    }
                    return IconButton(
                      onPressed: controller.close,
                      icon: const Icon(Icons.close_rounded),
                      color: _text,
                    );
                  }),
                ),
                SizedBox(height: Responsive.w(context, 8)),
                Container(
                  width: Responsive.w(context, 72),
                  height: Responsive.w(context, 72),
                  decoration: BoxDecoration(
                    color: AppColors.homeAccentLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: _border),
                  ),
                  child: Icon(
                    Icons.bolt_rounded,
                    color: _pink,
                    size: Responsive.w(context, 36),
                  ),
                ),
                SizedBox(height: Responsive.w(context, 16)),
                Text(
                  'credits_pack_title'.tr,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: _text,
                    fontSize: Responsive.sp(context, 22),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: Responsive.w(context, 8)),
                Text(
                  'credits_pack_subtitle'.tr,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: _subText,
                    fontSize: Responsive.sp(context, 14),
                    height: 1.35,
                  ),
                ),
                SizedBox(height: Responsive.w(context, 24)),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(Responsive.w(context, 16)),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _border),
                    boxShadow: [
                      BoxShadow(
                        color: _pink.withValues(alpha: 0.1),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: _pink,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.workspace_premium_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'credits_pack_card_title'.tr,
                                  style: GoogleFonts.inter(
                                    color: _text,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'credits_pack_card_desc'.tr,
                                  style: GoogleFonts.inter(
                                    color: _subText,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _border),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '$credits',
                                  style: GoogleFonts.inter(
                                    color: _pink,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  'credits_pack_unit'.tr,
                                  style: GoogleFonts.inter(
                                    color: _subText,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Divider(color: _border, height: 1),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline, color: _pink, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'credits_pack_info'.trParams({
                                'count': '$credits',
                              }),
                              style: GoogleFonts.inter(
                                color: _subText,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Obx(() {
                  final buying = controller.isPurchasing.value;
                  final price = controller.packPrice.value;
                  return SizedBox(
                    width: double.infinity,
                    height: Responsive.w(context, 54),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.homeCardGradientStart,
                            AppColors.homeCardGradientMid,
                            AppColors.homeCardGradientEnd,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: ElevatedButton(
                        onPressed: buying ? null : controller.purchase,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          disabledBackgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: buying
                            ? const ButtonLoadingIndicator(color: Colors.white)
                            : Text(
                                'credits_pack_cta'.trParams({'price': price}),
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: Responsive.sp(context, 16),
                                ),
                              ),
                      ),
                    ),
                  );
                }),
                SizedBox(height: Responsive.w(context, 10)),
                Text(
                  'credits_pack_one_time'.tr,
                  style: GoogleFonts.inter(
                    color: _subText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
