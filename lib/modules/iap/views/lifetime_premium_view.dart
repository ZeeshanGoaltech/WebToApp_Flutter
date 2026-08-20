import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/constants/app_assets.dart';
import 'package:web_to_app/modules/iap/controllers/lifetime_premium_controller.dart';

/// Dedicated lifetime paywall shown from the exit-intent sheet.
class LifetimePremiumView extends GetView<LifetimePremiumController> {
  const LifetimePremiumView({super.key});

  static const bg = Color(0xFFFBF6F2);
  static const heading = Color(0xFF301B0A);
  static const subtitle = Color(0xFF8C6963);
  static const primary = Color(0xFFF35D89);
  static const peach = Color(0xFFFDEADD);
  static const cardBorder = Color(0xFFD3C2B4);
  static const priceAccent = Color(0xFF301B0A);
  static const footer = Color(0xFF343434);

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return PopScope(
      canPop: false,
      child: MediaQuery.withClampedTextScaling(
        minScaleFactor: 0.9,
        maxScaleFactor: 1.0,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark.copyWith(
            systemNavigationBarColor: bg,
          ),
          child: Scaffold(
            backgroundColor: bg,
            body: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            AppAssets.iapLifetimeHero,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            filterQuality: FilterQuality.high,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: peach,
                              child: const Icon(
                                Icons.phone_android_rounded,
                                size: 64,
                                color: primary,
                              ),
                            ),
                          ),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Color(0x00FAF7F2),
                                  Color(0xBBFAF7F2),
                                  bg,
                                ],
                                stops: [0.0, 0.45, 0.75, 1.0],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 20,
                            right: 20,
                            bottom: 0,
                            child: Text(
                              'lifetime_hero_title'.tr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: heading,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                height: 1.15,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: cardBorder,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withValues(alpha: 0.12),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            _FeatureRow(
                              iconAsset: AppAssets.lifetimeIconBuild,
                              text: 'lifetime_feat_notebooks'.tr,
                              fallbackIcon: Icons.apps_rounded,
                            ),
                            const SizedBox(height: 14),
                            _FeatureRow(
                              iconAsset: AppAssets.lifetimeIconDownload,
                              text: 'lifetime_feat_scan'.tr,
                              fallbackIcon: Icons.download_rounded,
                            ),
                            const SizedBox(height: 14),
                            _FeatureRow(
                              iconAsset: AppAssets.lifetimeIconAds,
                              text: 'lifetime_feat_ads'.tr,
                              fallbackIcon: Icons.block_rounded,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Divider(
                                color: cardBorder,
                                height: 1,
                                thickness: 1,
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'lifetime_access_title'.tr,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                          color: heading,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'lifetime_access_subtitle'.tr,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: subtitle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Obx(
                                  () => Container(
                                    decoration: BoxDecoration(
                                      color: peach,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Directionality(
                                          textDirection: TextDirection.ltr,
                                          child: Text(
                                            controller.lifetimePrice.value,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w900,
                                              color: priceAccent,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'lifetime_pay_once'.tr,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: priceAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: Obx(
                          () => ElevatedButton(
                            onPressed: controller.isPurchasing.value
                                ? null
                                : controller.buyLifetime,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              disabledBackgroundColor:
                                  primary.withValues(alpha: 0.55),
                              foregroundColor: Colors.white,
                              elevation: 3,
                              shadowColor: primary.withValues(alpha: 0.35),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: controller.isPurchasing.value
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.lock_outline_rounded,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          'lifetime_unlock_cta'.tr,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        12,
                        0,
                        12,
                        12 + MediaQuery.paddingOf(context).bottom,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _FooterLink(
                                label: 'iap_terms_of_use'.tr,
                                onTap: controller.openTerms,
                              ),
                              const Text(
                                '  |  ',
                                style: TextStyle(
                                  color: footer,
                                  fontSize: 12,
                                ),
                              ),
                              _FooterLink(
                                label: 'privacy_policy'.tr,
                                onTap: controller.openPrivacy,
                              ),
                              const Text(
                                '  |  ',
                                style: TextStyle(
                                  color: footer,
                                  fontSize: 12,
                                ),
                              ),
                              _FooterLink(
                                label: 'iap_cancel_anytime'.tr,
                                onTap: _showCancelInfo,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Obx(
                  () => controller.showCloseButton.value
                      ? PositionedDirectional(
                          top: topInset + 8,
                          start: 12,
                          child: Material(
                            color: const Color(0xCC3D2418),
                            shape: const CircleBorder(),
                            elevation: 2,
                            child: InkWell(
                              onTap: controller.finish,
                              customBorder: const CircleBorder(),
                              child: const Padding(
                                padding: EdgeInsets.all(6),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showCancelInfo() async {
    await Get.dialog<void>(
      AlertDialog(
        title: Text('iap_cancel_anytime'.tr),
        content: Text('premium_cancel_info_body'.tr),
        actions: [
          FilledButton(
            onPressed: Get.back,
            child: Text('common_ok'.tr),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await controller.openManageSubscriptions();
            },
            child: Text('premium_manage_subscription'.tr),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.iconAsset,
    required this.text,
    required this.fallbackIcon,
  });

  final String iconAsset;
  final String text;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: LifetimePremiumView.peach,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            iconAsset,
            width: 20,
            height: 20,
            fit: BoxFit.contain,
            placeholderBuilder: (_) => Icon(
              fallbackIcon,
              color: LifetimePremiumView.heading,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: LifetimePremiumView.heading,
            ),
          ),
        ),
        SvgPicture.asset(
          AppAssets.lifetimeIconCheck,
          width: 22,
          height: 22,
          fit: BoxFit.contain,
          placeholderBuilder: (_) => const Icon(
            Icons.check_rounded,
            color: LifetimePremiumView.heading,
            size: 22,
          ),
        ),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: LifetimePremiumView.footer,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
