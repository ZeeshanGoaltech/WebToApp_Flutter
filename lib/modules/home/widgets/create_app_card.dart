import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/app/routes/app_routes.dart';
import 'package:web_to_app/core/services/build_login_gate.dart';
import 'package:web_to_app/core/constants/app_assets.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';
import 'package:web_to_app/core/widgets/figma_svg_icon.dart';
import 'package:web_to_app/core/widgets/rtl_flip.dart';
import 'package:web_to_app/modules/create_app/bindings/create_app_binding.dart';

/// Figma create-app card (node 2:267).
class CreateAppCard extends StatelessWidget {
  const CreateAppCard({super.key});

  Future<void> _openFreshCreateApp() async {
    if (!await BuildLoginGate.ensureForNewApp(
      openCreateApp: _openFreshCreateAppInternal,
    )) {
      return;
    }
    await _openFreshCreateAppInternal();
  }

  Future<void> _openFreshCreateAppInternal() async {
    CreateAppBinding.resetForNewAppIfPresent();
    Get.toNamed(AppRoutes.createApp);
  }

  @override
  Widget build(BuildContext context) {
    final radius = Responsive.w(context, 22);
    final cardHeight = Responsive.w(context, 173.377);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openFreshCreateApp,
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          height: cardHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        transform: GradientRotation(156.127 * math.pi / 180),
                        colors: const [
                          AppColors.homeCardGradientStart,
                          AppColors.homeCardGradientMid,
                          AppColors.homeCardGradientEnd,
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: Responsive.w(context, 279.75),
                  top: Responsive.w(context, -32),
                  child: Container(
                    width: Responsive.w(context, 143.991),
                    height: Responsive.w(context, 143.991),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  left: Responsive.w(context, 303.75),
                  top: Responsive.w(context, 101.37),
                  child: Container(
                    width: Responsive.w(context, 95.988),
                    height: Responsive.w(context, 95.988),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  left: Responsive.w(context, 319.76),
                  top: Responsive.w(context, 15.99),
                  child: Container(
                    width: Responsive.w(context, 55.997),
                    height: Responsive.w(context, 55.997),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(Responsive.w(context, 16)),
                    ),
                    child: Center(
                      child: FigmaSvgIcon(
                        asset: AppAssets.cardRocket,
                        size: Responsive.w(context, 27.99),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: Responsive.w(context, 24),
                  top: Responsive.w(context, 24),
                  width: Responsive.w(context, 344),
                  height: Responsive.w(context, 145),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: Responsive.w(context, 24.473),
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.w(context, 10),
                          vertical: Responsive.w(context, 4),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FigmaSvgIcon(
                              asset: AppAssets.cardSparkle,
                              size: Responsive.w(context, 11.983),
                            ),
                            SizedBox(width: Responsive.w(context, 6)),
                            Text(
                              'new_badge'.tr,
                              style: AppTextStyles.homeCardBadge(context),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: Responsive.w(context, 12.46)),
                      Text(
                        'create_new_app'.tr,
                        style: AppTextStyles.homeCardTitle(context),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: Responsive.w(context, 4)),
                        child: Text(
                          'create_new_app_subtitle'.tr,
                          style: AppTextStyles.homeCardSubtitle(context),
                        ),
                      ),
                      SizedBox(height: Responsive.w(context, 8)),
                      Container(
                        width: Responsive.w(context, 104),
                        height: Responsive.w(context, 36),
                        decoration: BoxDecoration(
                          color: AppColors.homeGetStartedBtn,
                          borderRadius:
                              BorderRadius.circular(Responsive.w(context, 9)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'get_started_cta'.tr,
                              style: AppTextStyles.homeCardButton(context),
                            ),
                            RtlFlip(
                              child: FigmaSvgIcon(
                                asset: AppAssets.cardArrow,
                                size: Responsive.w(context, 15.989),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
