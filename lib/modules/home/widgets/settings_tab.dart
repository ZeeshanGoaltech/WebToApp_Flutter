import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/constants/settings_assets.dart';
import 'package:web_to_app/core/services/language_service.dart';
import 'package:web_to_app/core/services/session_service.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';
import 'package:web_to_app/core/widgets/button_loading_indicator.dart';
import 'package:web_to_app/core/widgets/figma_svg_icon.dart';
import 'package:web_to_app/core/widgets/rtl_flip.dart';
import 'package:web_to_app/modules/home/controllers/home_controller.dart';
import 'package:web_to_app/modules/home/controllers/settings_controller.dart';
import 'package:web_to_app/modules/home/data/settings_menu_data.dart';

/// Figma Settings screen (node 31:1454).
class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.homeBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SettingsHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: Responsive.h(context, 20),
                bottom: Responsive.h(context, 28) + MediaQuery.paddingOf(context).bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.w(context, 24),
                    ),
                    child: const _PremiumCard(),
                  ),
                  SizedBox(height: Responsive.h(context, 24)),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.w(context, 24),
                    ),
                    child: const _ProfileSection(),
                  ),
                  SizedBox(height: Responsive.h(context, 24)),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.w(context, 24),
                    ),
                    child: const _PreferencesSection(),
                  ),
                  SizedBox(height: Responsive.h(context, 24)),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.w(context, 24),
                    ),
                    child: const _MoreSection(),
                  ),
                  SizedBox(height: Responsive.h(context, 24)),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.w(context, 24),
                    ),
                    child: const _LogoutSection(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreSection extends GetView<SettingsController> {
  const _MoreSection();

  @override
  Widget build(BuildContext context) {
    return _SettingsMenuSection(
      title: 'more'.tr,
      items: [
        SettingsMenuItem(
          title: 'rate_app'.tr,
          subtitle: 'rate_app_subtitle'.tr,
          iconAsset: SettingsAssets.star,
          iconBackground: const Color(0xFFFFFBEB),
          onTap: controller.showRateDialog,
        ),
        SettingsMenuItem(
          title: 'share_app'.tr,
          subtitle: 'share_app_subtitle'.tr,
          iconAsset: SettingsAssets.share,
          iconBackground: const Color(0xFFFFF7ED),
          onTap: controller.shareApp,
        ),
        SettingsMenuItem(
          title: 'terms_conditions'.tr,
          subtitle: 'terms_subtitle'.tr,
          iconAsset: SettingsAssets.document,
          iconBackground: const Color(0xFFECFDF5),
          onTap: controller.openTermsAndConditions,
        ),
        SettingsMenuItem(
          title: 'privacy_policy'.tr,
          subtitle: 'privacy_policy_subtitle'.tr,
          iconAsset: SettingsAssets.shield,
          iconBackground: const Color(0xFFEFF6FF),
          onTap: controller.openPrivacyPolicy,
        ),
      ],
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.homeBorder, width: 1.327),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          Responsive.w(context, 24),
          Responsive.w(context, 20),
          Responsive.w(context, 24),
          Responsive.w(context, 22),
        ),
        child: Text(
          'settings'.tr,
          style: AppTextStyles.settingsHeaderTitle(context),
        ),
      ),
    );
  }
}

class _PremiumCard extends GetView<SettingsController> {
  const _PremiumCard();

  static const _dots = [
    _PremiumDot(left: 53.07, top: 21.98, size: 4.539, opacity: 0.30),
    _PremiumDot(left: 228.08, top: 55.71, size: 4.932, opacity: 0.54),
    _PremiumDot(left: 304.54, top: 25.86, size: 4.327, opacity: 0.29),
    _PremiumDot(left: 349.9, top: 102.78, size: 5.001, opacity: 0.56),
    _PremiumDot(left: 113.52, top: 130.77, size: 5.516, opacity: 0.53),
    _PremiumDot(left: 266.56, top: 150.3, size: 4.123, opacity: 0.22),
  ];

  @override
  Widget build(BuildContext context) {
    final session = Get.find<SessionService>();

    return Obx(() {
      if (session.hasPremiumAccess) {
        return const SizedBox.shrink();
      }

      final radius = Responsive.w(context, 22);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            transform: GradientRotation(159.193 * math.pi / 180),
            colors: const [Color(0xFFFF9500), Color(0xFFFF9D00)],
          ),
        ),
        child: Stack(
          children: [
            for (final dot in _dots)
              Positioned(
                left: Responsive.w(context, dot.left),
                top: Responsive.w(context, dot.top),
                child: Container(
                  width: Responsive.w(context, dot.size),
                  height: Responsive.w(context, dot.size),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: dot.opacity),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(Responsive.w(context, 16)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.w(context, 10),
                          vertical: Responsive.w(context, 4),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FigmaSvgIcon(
                              asset: SettingsAssets.crown,
                              size: Responsive.w(context, 12),
                            ),
                            SizedBox(width: Responsive.w(context, 6)),
                            Text(
                              'premium'.tr,
                              style: AppTextStyles.settingsPremiumBadge(
                                context,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$4.99/mo',
                        style: AppTextStyles.settingsPremiumPrice(context),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.w(context, 10)),
                  Text(
                    'unlock_full_power'.tr,
                    style: AppTextStyles.settingsPremiumTitle(context),
                  ),
                  SizedBox(height: Responsive.w(context, 2)),
                  Text(
                    'premium_subtitle'.tr,
                    style: AppTextStyles.settingsPremiumSubtitle(context),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: Responsive.w(context, 10)),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: controller.upgradeToPremium,
                      borderRadius: BorderRadius.circular(
                        Responsive.w(context, 12),
                      ),
                      child: Ink(
                        height: Responsive.w(context, 41),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            Responsive.w(context, 12),
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FigmaSvgIcon(
                                asset: SettingsAssets.sparkle,
                                size: Responsive.w(context, 16),
                                color: AppColors.homeTitle,
                                tinted: true,
                              ),
                              SizedBox(width: Responsive.w(context, 8)),
                              Text(
                                'upgrade_to_premium'.tr,
                                style: AppTextStyles.settingsPremiumButton(
                                  context,
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
      ),
    );
    });
  }
}

class _PremiumDot {
  const _PremiumDot({
    required this.left,
    required this.top,
    required this.size,
    required this.opacity,
  });

  final double left;
  final double top;
  final double size;
  final double opacity;
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection();

  @override
  Widget build(BuildContext context) {
    final session = Get.find<SessionService>();
    final home = Get.find<HomeController>();

    return Obx(() {
      final isGuest = session.isGuest.value;
      final user = session.user.value;
      final name = isGuest
          ? 'guest_user'.tr
          : (user?.resolvedName ?? 'user'.tr);
      final email = isGuest ? 'guest@appforge.dev' : (user?.email ?? '');
      final isPremium = session.hasPremiumAccess;
      final planLabel = isPremium ? 'premium'.tr : 'free_plan'.tr;
      final appsLabel = ' · ${home.apps.length} apps';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.only(left: Responsive.w(context, 4)),
            child: Text(
              'profile'.tr,
              style: AppTextStyles.settingsSectionLabel(context),
            ),
          ),
          SizedBox(height: Responsive.w(context, 8)),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Responsive.w(context, 19)),
              border: Border.all(color: AppColors.homeBorder, width: 1.363),
            ),
            padding: EdgeInsets.all(Responsive.w(context, 17)),
            child: Row(
              children: [
                SizedBox(
                  width: Responsive.w(context, 59),
                  height: Responsive.w(context, 59),
                  child: Container(
                    width: Responsive.w(context, 59),
                    height: Responsive.w(context, 59),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        transform: GradientRotation(135 * math.pi / 180),
                        colors: const [
                          AppColors.homeCardGradientStart,
                          AppColors.homeCardGradientMid,
                          AppColors.homeCardGradientEnd,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: Responsive.w(context, 4),
                          offset: Offset(0, Responsive.w(context, 2)),
                        ),
                      ],
                    ),
                    child: Center(
                      child: FigmaSvgIcon(
                        asset: SettingsAssets.user,
                        size: Responsive.w(context, 30),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: Responsive.w(context, 17)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.settingsProfileName(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        email,
                        style: AppTextStyles.settingsProfileEmail(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: Responsive.w(context, 4)),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Responsive.w(context, 8),
                              vertical: Responsive.w(context, 2),
                            ),
                            decoration: BoxDecoration(
                              color: isPremium
                                  ? AppColors.homeBuiltBg
                                  : AppColors.homeDraftBg,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              planLabel,
                              style: isPremium
                                  ? AppTextStyles.homeStatusBadge(
                                      context,
                                      AppColors.homeBuilt,
                                    )
                                  : AppTextStyles.settingsFreePlanBadge(
                                      context,
                                    ),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              appsLabel,
                              style: AppTextStyles.settingsAppsBuilt(context),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _PreferencesSection extends GetView<SettingsController> {
  const _PreferencesSection();

  @override
  Widget build(BuildContext context) {
    final languageService = Get.find<LanguageService>();

    return Obx(
      () => _SettingsMenuSection(
        title: 'preferences'.tr,
        items: [
          SettingsMenuItem(
            title: 'language'.tr,
            subtitle: languageService.settingsSubtitle,
            iconAsset: SettingsAssets.globe,
            iconBackground: const Color(0xFFECFEFF),
            onTap: controller.openLanguage,
          ),
        ],
      ),
    );
  }
}

class _LogoutSection extends GetView<SettingsController> {
  const _LogoutSection();

  @override
  Widget build(BuildContext context) {
    final session = Get.find<SessionService>();

    return Obx(() {
      if (session.isGuest.value || session.user.value == null) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: controller.openAuth,
            borderRadius: BorderRadius.circular(Responsive.w(context, 19)),
            child: Ink(
              height: Responsive.w(context, 52),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.homeCardGradientStart,
                    AppColors.homeCardGradientMid,
                    AppColors.homeCardGradientEnd,
                  ],
                ),
                borderRadius: BorderRadius.circular(Responsive.w(context, 19)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.homeAccent.withValues(alpha: 0.2),
                    blurRadius: Responsive.w(context, 10),
                    offset: Offset(0, Responsive.w(context, 4)),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.login_rounded,
                      size: Responsive.w(context, 18),
                      color: Colors.white,
                    ),
                    SizedBox(width: Responsive.w(context, 8)),
                    Text(
                      'sign_in'.tr,
                      style: AppTextStyles.settingsRowTitle(
                        context,
                      ).copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      final loading = controller.isLoggingOut.value;
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: loading ? null : controller.logout,
          borderRadius: BorderRadius.circular(Responsive.w(context, 19)),
          child: Ink(
            height: Responsive.w(context, 52),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Responsive.w(context, 19)),
              border: Border.all(color: const Color(0xFFFECACA), width: 1.363),
            ),
            child: Center(
              child: loading
                  ? const ButtonLoadingIndicator(color: Color(0xFFDC2626))
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          size: Responsive.w(context, 18),
                          color: const Color(0xFFDC2626),
                        ),
                        SizedBox(width: Responsive.w(context, 8)),
                        Text(
                          'log_out'.tr,
                          style: AppTextStyles.settingsRowTitle(
                            context,
                          ).copyWith(color: const Color(0xFFDC2626)),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      );
    });
  }
}

class _SettingsMenuSection extends StatelessWidget {
  const _SettingsMenuSection({required this.title, required this.items});

  final String title;
  final List<SettingsMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(left: Responsive.w(context, 4)),
          child: Text(
            title,
            style: AppTextStyles.settingsSectionLabel(context),
          ),
        ),
        SizedBox(height: Responsive.w(context, 8)),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Responsive.w(context, 19)),
            border: Border.all(color: AppColors.homeBorder, width: 1.363),
          ),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++)
                _SettingsRow(item: items[i], showDivider: i < items.length - 1),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.item, required this.showDivider});

  final SettingsMenuItem item;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        child: Ink(
          decoration: BoxDecoration(
            border: showDivider
                ? const Border(
                    bottom: BorderSide(color: Color(0xFFF5F5F8), width: 1.363),
                  )
                : null,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(context, 17),
            vertical: Responsive.w(context, 15),
          ),
          child: Row(
            children: [
              Container(
                width: Responsive.w(context, 38),
                height: Responsive.w(context, 38),
                decoration: BoxDecoration(
                  color: item.iconBackground,
                  borderRadius: BorderRadius.circular(
                    Responsive.w(context, 10.5),
                  ),
                ),
                child: Center(
                  child: FigmaSvgIcon(
                    asset: item.iconAsset,
                    size: Responsive.w(context, 17),
                  ),
                ),
              ),
              SizedBox(width: Responsive.w(context, 13)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTextStyles.settingsRowTitle(context),
                    ),
                    SizedBox(height: Responsive.w(context, 2)),
                    Text(
                      item.subtitle,
                      style: AppTextStyles.settingsRowSubtitle(context),
                    ),
                  ],
                ),
              ),
              RtlFlip(
                child: FigmaSvgIcon(
                  asset: SettingsAssets.chevronRight,
                  size: Responsive.w(context, 17),
                  color: AppColors.homeMuted,
                  tinted: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
