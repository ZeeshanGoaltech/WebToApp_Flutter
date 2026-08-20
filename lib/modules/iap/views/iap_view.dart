import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_to_app/core/constants/app_assets.dart';
import 'package:web_to_app/core/navigation/launch_flow.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/widgets/button_loading_indicator.dart';
import 'package:web_to_app/core/widgets/figma_svg_icon.dart';
import 'package:web_to_app/modules/iap/controllers/iap_controller.dart';
import 'package:web_to_app/modules/iap/data/iap_data.dart';
import 'package:web_to_app/modules/iap/widgets/iap_check_icon.dart';

/// Figma IAP paywall (node 127:101). Fixed canvas scaled to fit — never scrolls.
class IapView extends GetView<IapController> {
  const IapView({super.key});

  /// Figma frame size for node 127:101.
  static const double _designW = 456;
  static const double _designH = 996;

  static const double _heroH = 326;
  static const double _screenHPad = 11;
  static const double _featureLeft = 28;
  static const double _btnRadius = 24;
  static const double _planBorderW = 2.048;
  static const double _trialH = 82.467;
  static const double _planH = 86.751;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.iapBackground,
        body: ColoredBox(
          color: AppColors.iapBackground,
          child: Padding(
            padding: EdgeInsets.only(
              top: padding.top,
              bottom: padding.bottom,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final scale = mathMin(
                  constraints.maxWidth / _designW,
                  constraints.maxHeight / _designH,
                );
                final w = _designW * scale;
                final h = _designH * scale;

                return Center(
                  child: SizedBox(
                    width: w,
                    height: h,
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: SizedBox(
                        width: _designW,
                        height: _designH,
                        child: const _IapCanvas(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  static double mathMin(double a, double b) => a < b ? a : b;
}

class _IapCanvas extends StatelessWidget {
  const _IapCanvas();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned.fill(child: ColoredBox(color: AppColors.iapBackground)),
        _HeroLayer(),
        _HeroFade(),
        _TitleBlock(),
        _FeatureList(),
        _FreeTrialButton(),
        _YearlyButton(),
        _LifetimeButton(),
        _FooterLinks(),
        _CloseButton(),
      ],
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 19,
      left: 11,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: LaunchFlow.completeIap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.iapCloseBg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const FigmaSvgIcon(
              asset: AppAssets.iapCloseIcon,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroLayer extends StatelessWidget {
  const _HeroLayer();

  @override
  Widget build(BuildContext context) {
    // Figma: 457×326 slot, image scaled ~105.21% and shifted up ~5.21%.
    return Positioned(
      top: 0,
      left: 0,
      width: IapView._designW,
      height: IapView._heroH,
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Transform.translate(
              offset: Offset(0, -IapView._heroH * 0.0521),
              child: SizedBox(
                height: IapView._heroH * 1.0521,
                width: IapView._designW,
                child: const Image(
                  image: AssetImage(AppAssets.iapHero),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroFade extends StatelessWidget {
  const _HeroFade();

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x00F7F6FB),
                AppColors.iapBackground,
              ],
              stops: [0.22276, 0.39978],
            ),
          ),
        ),
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: 303,
          left: 12,
          right: 12,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'iap_unlock'.tr,
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w800,
                    fontSize: 40.09,
                    height: 69.078 / 40.09,
                    color: AppColors.iapTitleDark,
                  ),
                ),
                TextSpan(
                  text: ' ${'iap_pro_version'.tr}',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w800,
                    fontSize: 40.09,
                    height: 69.078 / 40.09,
                    color: AppColors.iapTitleDark,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Positioned(
          top: 364.82,
          left: 12,
          right: 12,
          child: Text(
            'iap_subtitle'.tr,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w400,
              fontSize: 17.818,
              height: 30.311 / 17.818,
              color: AppColors.iapMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureList extends StatelessWidget {
  const _FeatureList();

  @override
  Widget build(BuildContext context) {
    final features = IapData.features;
    // Figma container top 410 + pt 21, gap 11 between 36px rows.
    const startTop = 431.0;
    const rowHeight = 36.0;
    const gap = 11.0;

    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < features.length; i++)
          Positioned(
            top: startTop + i * (rowHeight + gap),
            left: IapView._featureLeft,
            right: IapView._featureLeft,
            height: rowHeight,
            child: Row(
              children: [
                Container(
                  width: rowHeight,
                  height: rowHeight,
                  decoration: const BoxDecoration(
                    color: AppColors.iapFeatureIconBg,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const IapCheckIcon(size: 17.334),
                ),
                const SizedBox(width: 16.8),
                Expanded(
                  child: _FeatureLabel(text: features[i]),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Feature label — muted by default; only "APK" and "AAB" render black/bold.
class _FeatureLabel extends StatelessWidget {
  const _FeatureLabel({required this.text});

  final String text;

  static final _accentPattern = RegExp(r'APK|AAB');

  @override
  Widget build(BuildContext context) {
    final base = GoogleFonts.inter(
      fontWeight: FontWeight.w500,
      fontSize: 19,
      height: 22.785 / 19,
      letterSpacing: -0.2861,
      color: AppColors.iapMuted,
    );
    final accent = base.copyWith(
      color: AppColors.iapTitleDark,
      fontWeight: FontWeight.w700,
    );

    final spans = <TextSpan>[];
    var start = 0;
    for (final match in _accentPattern.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      spans.add(TextSpan(text: match.group(0), style: accent));
      start = match.end;
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return Text.rich(
      TextSpan(style: base, children: spans),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _FreeTrialButton extends GetView<IapController> {
  const _FreeTrialButton();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 642,
      left: IapView._screenHPad,
      right: IapView._screenHPad,
      height: IapView._trialH,
      child: Obx(
        () => Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: controller.isPurchasing.value || controller.isRestoring.value
                ? null
                : () => controller.purchase(IapPlan.freeTrial),
            borderRadius: BorderRadius.circular(IapView._btnRadius),
            child: Ink(
              decoration: BoxDecoration(
                color: AppColors.iapTrialButton,
                borderRadius: BorderRadius.circular(IapView._btnRadius),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    offset: Offset(0, 11.423),
                    blurRadius: 8.567,
                  ),
                  BoxShadow(
                    color: Color(0x1A000000),
                    offset: Offset(0, 4.569),
                    blurRadius: 3.427,
                  ),
                ],
              ),
              child:
                  controller.isPurchasing.value &&
                      controller.selectedPlan.value == IapPlan.freeTrial
                  ? const Center(child: ButtonLoadingIndicator())
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'iap_start_free_trial'.tr,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 19.278,
                            height: 27.415 / 19.278,
                            letterSpacing: -0.357,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            controller.displayTrialSubtitle() ?? '—',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                              fontSize: 14.994,
                              height: 27.415 / 14.994,
                              letterSpacing: -0.357,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _YearlyButton extends StatelessWidget {
  const _YearlyButton();

  @override
  Widget build(BuildContext context) {
    return const Positioned(
      top: 742.67,
      left: IapView._screenHPad,
      right: IapView._screenHPad,
      height: IapView._planH,
      child: _PlanCard(
        plan: IapPlan.yearly,
        titleKey: 'iap_yearly_access',
        priceLabelKey: 'iap_per_yearly',
      ),
    );
  }
}

class _LifetimeButton extends StatelessWidget {
  const _LifetimeButton();

  @override
  Widget build(BuildContext context) {
    return const Positioned(
      top: 848.7,
      left: IapView._screenHPad,
      right: IapView._screenHPad,
      height: IapView._planH,
      child: _PlanCard(
        plan: IapPlan.lifetime,
        titleKey: 'iap_lifetime',
        subtitleKey: 'iap_lifetime_subtitle',
      ),
    );
  }
}

class _PlanCard extends GetView<IapController> {
  const _PlanCard({
    required this.plan,
    required this.titleKey,
    this.subtitleKey,
    this.priceLabelKey,
  });

  final IapPlan plan;
  final String titleKey;
  final String? subtitleKey;
  final String? priceLabelKey;

  String _subtitle(IapController controller) {
    if (plan == IapPlan.yearly) {
      return controller.displayYearlyPerWeekSubtitle() ?? '—';
    }
    return subtitleKey?.tr ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading =
          controller.isPurchasing.value &&
          controller.selectedPlan.value == plan;
      final price = controller.displayPrice(plan);
      final subtitle = _subtitle(controller);

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: controller.isPurchasing.value || controller.isRestoring.value
              ? null
              : () => controller.purchase(plan),
          borderRadius: BorderRadius.circular(IapView._btnRadius),
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(IapView._btnRadius),
              border: Border.all(
                color: AppColors.iapPlanBorder,
                width: IapView._planBorderW,
              ),
            ),
            child: isLoading
                ? const Center(
                    child: ButtonLoadingIndicator(
                      color: AppColors.iapTitleDark,
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 23.12),
                    child: priceLabelKey != null
                        ? _YearlyPlanLayout(
                            title: titleKey.tr,
                            subtitle: subtitle,
                            price: price,
                            priceLabel: priceLabelKey!.tr,
                          )
                        : _LifetimePlanLayout(
                            title: titleKey.tr,
                            subtitle: subtitle,
                            price: price,
                          ),
                  ),
          ),
        ),
      );
    });
  }
}

class _YearlyPlanLayout extends StatelessWidget {
  const _YearlyPlanLayout({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.priceLabel,
  });

  final String title;
  final String subtitle;
  final String price;
  final String priceLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 19.999,
                  height: 29.998 / 19.999,
                  letterSpacing: -0.3906,
                  color: AppColors.iapTitleDark,
                ),
              ),
            ),
            Text(
              price,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                fontSize: 19.999,
                height: 21.42 / 19.999,
                letterSpacing: -0.3906,
                color: AppColors.iapTitleDark,
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 16.065,
                  height: 29.998 / 16.065,
                  letterSpacing: -0.3906,
                  color: AppColors.iapMuted,
                ),
              ),
            ),
            Text(
              priceLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                fontSize: 11.781,
                height: 21.42 / 11.781,
                letterSpacing: -0.3906,
                color: AppColors.iapMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LifetimePlanLayout extends StatelessWidget {
  const _LifetimePlanLayout({
    required this.title,
    required this.subtitle,
    required this.price,
  });

  final String title;
  final String subtitle;
  final String price;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 19.999,
                  height: 29.998 / 19.999,
                  letterSpacing: -0.3906,
                  color: AppColors.iapTitleDark,
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 16.065,
                  height: 29.998 / 16.065,
                  letterSpacing: -0.3906,
                  color: AppColors.iapMuted,
                ),
              ),
            ],
          ),
        ),
        Text(
          price,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 19.999,
            height: 21.42 / 19.999,
            letterSpacing: -0.3906,
            color: AppColors.iapTitleDark,
          ),
        ),
      ],
    );
  }
}

class _FooterLinks extends GetView<IapController> {
  const _FooterLinks();

  TextStyle _linkStyle() {
    return GoogleFonts.poppins(
      fontWeight: FontWeight.w500,
      fontSize: 12.852,
      height: 1.0,
      color: AppColors.iapMuted,
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = _linkStyle();
    final divider = Text('    |    ', style: style);

    return Positioned(
      top: 960,
      left: 40,
      right: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: GestureDetector(
              onTap: controller.openTerms,
              child: Text(
                'iap_terms_of_use'.tr,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
            ),
          ),
          divider,
          Flexible(
            child: GestureDetector(
              onTap: controller.openPrivacy,
              child: Text(
                'privacy_policy'.tr,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
            ),
          ),
          divider,
          Flexible(
            child: GestureDetector(
              onTap: controller.openManageSubscriptions,
              child: Text(
                'iap_cancel_anytime'.tr,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
