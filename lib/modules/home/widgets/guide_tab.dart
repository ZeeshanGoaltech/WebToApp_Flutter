import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/app/routes/app_routes.dart';
import 'package:web_to_app/core/ads/ad_placements.dart';
import 'package:web_to_app/core/ads/widgets/medium_native_ad_widget.dart';
import 'package:web_to_app/core/services/build_login_gate.dart';
import 'package:web_to_app/core/constants/help_guide_assets.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';
import 'package:web_to_app/core/widgets/figma_svg_icon.dart';
import 'package:web_to_app/core/widgets/rtl_flip.dart';
import 'package:web_to_app/modules/create_app/bindings/create_app_binding.dart';
import 'package:web_to_app/modules/home/controllers/home_controller.dart';
import 'package:web_to_app/modules/home/data/help_guide_steps.dart';

/// Figma Help & Guide screen (node 5:2444).
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

class GuideTab extends GetView<HomeController> {
  const GuideTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.homeBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _HelpGuideHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                Responsive.w(context, 24),
                Responsive.w(context, 24),
                Responsive.w(context, 24),
                Responsive.w(context, 32),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _QuickGuideCard(),
                  SizedBox(height: Responsive.w(context, 28)),
                  Text(
                    'step_by_step'.tr,
                    style: AppTextStyles.helpGuideSectionTitle(context),
                  ),
                  SizedBox(height: Responsive.w(context, 12)),
                  ...HelpGuideSteps.steps.asMap().entries.expand((entry) {
                    final index = entry.key;
                    final step = entry.value;
                    return [
                      Padding(
                        padding: EdgeInsets.only(
                          top: index == 0 ? 0 : Responsive.w(context, 12),
                        ),
                        child: _HelpGuideStepCard(
                          step: step,
                          showConnector:
                              index < HelpGuideSteps.steps.length - 1,
                        ),
                      ),
                      // Medium native after first step card (RC: helpscreen_native)
                      if (index == 0) ...[
                        SizedBox(height: Responsive.w(context, 12)),
                        const MediumNativeAdWidget(
                          placementId: AdPlacements.helpScreenNative,
                          includeOuterPadding: false,
                        ),
                      ],
                    ];
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpGuideHeader extends GetView<HomeController> {
  const _HelpGuideHeader();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.homeBorder, width: 1.16),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          Responsive.w(context, 24),
          Responsive.w(context, 24),
          Responsive.w(context, 24),
          Responsive.w(context, 16),
        ),
        child: Row(
          children: [
            Container(
              width: Responsive.w(context, 36),
              height: Responsive.w(context, 36),
              decoration: BoxDecoration(
                color: AppColors.homeAccentLight,
                borderRadius: BorderRadius.circular(Responsive.w(context, 10)),
              ),
              child: Center(
                child: FigmaSvgIcon(
                  asset: HelpGuideAssets.book,
                  size: Responsive.w(context, 18),
                  color: AppColors.homeAccent,
                  tinted: true,
                ),
              ),
            ),
            SizedBox(width: Responsive.w(context, 10)),
            Text(
              'help_guide'.tr,
              style: AppTextStyles.homeHeaderTitle(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickGuideCard extends StatelessWidget {
  const _QuickGuideCard();

  @override
  Widget build(BuildContext context) {
    final radius = Responsive.w(context, 22);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  transform: GradientRotation(149.866 * math.pi / 180),
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
            right: Responsive.w(context, -24),
            top: Responsive.w(context, -24),
            child: Container(
              width: Responsive.w(context, 111.995),
              height: Responsive.w(context, 111.995),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: Responsive.w(context, 32),
            bottom: Responsive.w(context, 4),
            child: Container(
              width: Responsive.w(context, 63.992),
              height: Responsive.w(context, 63.992),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(Responsive.w(context, 24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'quick_guide'.tr,
                  style: AppTextStyles.helpGuideQuickBadge(context),
                ),
                SizedBox(height: Responsive.w(context, 8)),
                Text(
                  'build_in_2_minutes'.tr,
                  style: AppTextStyles.helpGuideQuickTitle(context),
                ),
                SizedBox(height: Responsive.w(context, 4)),
                Text(
                  'quick_guide_body'.tr,
                  style: AppTextStyles.helpGuideQuickBody(context),
                ),
                SizedBox(height: Responsive.w(context, 16)),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _openFreshCreateApp,
                      borderRadius: BorderRadius.circular(999),
                      child: Ink(
                        height: Responsive.w(context, 35.477),
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.w(context, 16),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'start_building'.tr,
                              style: AppTextStyles.helpGuideQuickButton(
                                context,
                              ),
                            ),
                            SizedBox(width: Responsive.w(context, 4)),
                            RtlFlip(
                              child: FigmaSvgIcon(
                                asset: HelpGuideAssets.arrowRight,
                                size: Responsive.w(context, 15.989),
                                color: Colors.white,
                                tinted: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpGuideStepCard extends StatelessWidget {
  const _HelpGuideStepCard({required this.step, required this.showConnector});

  final HelpGuideStep step;
  final bool showConnector;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(context, 17.16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
        border: Border.all(color: AppColors.homeBorder, width: 1.16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: Responsive.w(context, 39.99),
                height: Responsive.w(context, 39.99),
                decoration: BoxDecoration(
                  color: step.iconBackground,
                  borderRadius: BorderRadius.circular(
                    Responsive.w(context, 12),
                  ),
                ),
                child: Center(
                  child: FigmaSvgIcon(
                    asset: step.iconAsset,
                    size: Responsive.w(context, 19.995),
                  ),
                ),
              ),
              if (showConnector) ...[
                SizedBox(height: Responsive.w(context, 4)),
                Container(
                  width: Responsive.w(context, 0.997),
                  height: Responsive.w(context, 43.453),
                  color: AppColors.homeBorder,
                ),
              ],
            ],
          ),
          SizedBox(width: Responsive.w(context, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.w(context, 6),
                        vertical: Responsive.w(context, 2),
                      ),
                      decoration: BoxDecoration(
                        color: step.badgeColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${step.number}',
                        style: AppTextStyles.helpGuideStepBadge(context),
                      ),
                    ),
                    SizedBox(width: Responsive.w(context, 8)),
                    Expanded(
                      child: Text(
                        step.title,
                        style: AppTextStyles.helpGuideStepTitle(context),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.w(context, 4)),
                Text(
                  step.description,
                  style: AppTextStyles.helpGuideStepBody(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
