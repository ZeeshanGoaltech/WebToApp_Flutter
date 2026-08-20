import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/ads/ad_placements.dart';
import 'package:web_to_app/core/ads/widgets/small_native_ad_widget.dart';
import 'package:web_to_app/core/localization/l10n.dart';
import 'package:web_to_app/core/constants/create_app_assets.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';
import 'package:web_to_app/core/widgets/figma_svg_icon.dart';
import 'package:web_to_app/modules/create_app/controllers/create_app_controller.dart';
import 'package:web_to_app/modules/create_app/models/nav_tab_model.dart';
import 'package:web_to_app/modules/create_app/models/preview_mode.dart';
import 'package:web_to_app/modules/create_app/widgets/fields/create_picked_image.dart';
import 'package:web_to_app/modules/create_app/widgets/shell/create_loading_dots.dart';

/// Figma phone frame size — content scales via [FittedBox].
const _phoneDesignWidth = 280.0;
const _phoneDesignHeight = 560.0;

class Step6PreviewPage extends GetView<CreateAppController> {
  const Step6PreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            Responsive.w(context, 24),
            Responsive.h(context, 4),
            Responsive.w(context, 24),
            0,
          ),
          child: SizedBox(
            height: Responsive.w(context, 52),
            child: Obx(() {
              final selected = controller.previewMode.value;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(context, 2),
                  vertical: Responsive.h(context, 4),
                ),
                itemCount: PreviewMode.values.length,
                separatorBuilder: (_, _) =>
                    SizedBox(width: Responsive.w(context, 10)),
                itemBuilder: (context, index) {
                  final mode = PreviewMode.values[index];
                  final active = selected == mode;
                  return _PreviewChip(
                    label: mode.localizedLabel,
                    active: active,
                    onTap: () => controller.previewMode.value = mode,
                  );
                },
              );
            }),
          ),
        ),
        SizedBox(height: Responsive.h(context, 12)),
        // Monetization: Creation Screen Native near top of preview
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 24)),
          child: const SmallNativeAdWidget(
            placementId: AdPlacements.creationScreenNative,
            includeOuterPadding: false,
          ),
        ),
        SizedBox(height: Responsive.h(context, 12)),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final footerHeight = Responsive.w(context, 72);
              final phoneAreaHeight = (constraints.maxHeight - footerHeight)
                  .clamp(200.0, double.infinity);
              final phoneAreaWidth =
                  constraints.maxWidth - Responsive.w(context, 48);
              final scale = math.min(
                phoneAreaWidth / _phoneDesignWidth,
                phoneAreaHeight / _phoneDesignHeight,
              );

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(context, 24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: phoneAreaWidth,
                      height: phoneAreaHeight,
                      child: Center(
                        child: Transform.scale(
                          scale: scale,
                          child: const _PhoneMockup(
                            width: _phoneDesignWidth,
                            height: _phoneDesignHeight,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.h(context, 18)),
                    GestureDetector(
                      onTap: () => controller.goToStep(0),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.w(context, 18),
                          vertical: Responsive.h(context, 12),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            Responsive.w(context, 999),
                          ),
                          border: Border.all(
                            color: AppColors.createAccent.withValues(alpha: 0.24),
                            width: 1.16,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.createAccent.withValues(alpha: 0.12),
                              blurRadius: Responsive.w(context, 14),
                              offset: Offset(0, Responsive.h(context, 4)),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FigmaSvgIcon(
                              asset: CreateAppAssets.previewEdit,
                              size: Responsive.w(context, 15.989),
                              color: AppColors.createAccent,
                            ),
                            SizedBox(width: Responsive.w(context, 8)),
                            Text(
                              'edit'.tr,
                              style: AppTextStyles.createLink(context).copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.h(context, 10)),
                    Text(
                      'looks_good'.tr,
                      style: AppTextStyles.createPreviewMuted(context),
                    ),
                    SizedBox(height: Responsive.h(context, 12)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PreviewChip extends StatelessWidget {
  const _PreviewChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(context, 16),
            vertical: Responsive.w(context, 8),
          ),
          decoration: BoxDecoration(
            color: active ? Colors.white : AppColors.createFieldBorder,
            borderRadius: BorderRadius.circular(999),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: Responsive.w(context, 4),
                      offset: Offset(0, Responsive.w(context, 2)),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: AppTextStyles.createFieldValue(context, size: 14).copyWith(
              color: active
                  ? AppColors.createAccent
                  : AppColors.createPreviewMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _PhoneMockup extends GetView<CreateAppController> {
  const _PhoneMockup({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final radius = width * 0.143;

    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: width * 0.19,
              offset: Offset(0, width * 0.063),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AnimatedBuilder(
                animation: Listenable.merge([
                  controller.appNameController,
                  controller.websiteUrlController,
                ]),
                builder: (_, _) => Obx(
                  () => _PreviewContent(
                    mode: controller.previewMode.value,
                    phoneWidth: width,
                    phoneHeight: height,
                  ),
                ),
              ),
              Positioned(
                top: height * 0.028,
                left: width / 2 - width * 0.15,
                child: Container(
                  width: width * 0.3,
                  height: height * 0.0375,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewContent extends GetView<CreateAppController> {
  const _PreviewContent({
    required this.mode,
    required this.phoneWidth,
    required this.phoneHeight,
  });

  final PreviewMode mode;
  final double phoneWidth;
  final double phoneHeight;

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case PreviewMode.splash:
        return _SplashPreview(phoneWidth: phoneWidth, phoneHeight: phoneHeight);
      case PreviewMode.onboarding:
        return _OnboardingPreview(
          phoneWidth: phoneWidth,
          phoneHeight: phoneHeight,
        );
      case PreviewMode.navigation:
        return _NavigationPreview(phoneHeight: phoneHeight);
      case PreviewMode.webview:
        return _WebviewPreview(phoneHeight: phoneHeight);
    }
  }
}

class _SplashPreview extends GetView<CreateAppController> {
  const _SplashPreview({required this.phoneWidth, required this.phoneHeight});

  final double phoneWidth;
  final double phoneHeight;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final color = controller.selectedThemeColor.value;
      final iconSize = phoneWidth * 0.2;
      final name = _appName(controller);
      final splashPath = controller.splashPath.value;
      final showLogoLoader = controller.extraFeatures['loadingScreen'] == true;

      return Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                transform: GradientRotation(116.458 * math.pi / 180),
                colors: [color, Color.lerp(color, Colors.white, 0.28)!],
              ),
            ),
          ),
          if (splashPath != null)
            Opacity(
              opacity: 0.32,
              child: CreatePickedImage(
                imagePath: splashPath,
                fit: BoxFit.cover,
              ),
            ),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: phoneWidth * 0.08),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PreviewAppIcon(
                    size: iconSize,
                    imagePath: controller.iconPath.value,
                    accent: color,
                  ),
                  SizedBox(height: phoneHeight * 0.022),
                  Text(
                    name,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: phoneWidth * 0.064,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: phoneHeight * 0.014),
                  _MiniUrlPill(url: _displayUrl(controller), color: color),
                  SizedBox(height: phoneHeight * 0.05),
                  showLogoLoader
                      ? _PreviewAppIcon(
                          size: phoneWidth * 0.095,
                          imagePath: controller.iconPath.value,
                          accent: color,
                        )
                      : const CreateLoadingDots(),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _PreviewAppIcon extends StatelessWidget {
  const _PreviewAppIcon({
    required this.size,
    required this.imagePath,
    required this.accent,
  });

  final double size;
  final String? imagePath;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: size * 0.28,
            offset: Offset(0, size * 0.12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: imagePath != null
          ? CreatePickedImage(imagePath: imagePath!, fit: BoxFit.cover)
          : Icon(Icons.public_rounded, color: accent, size: size * 0.5),
    );
  }
}

class _MiniUrlPill extends StatelessWidget {
  const _MiniUrlPill({required this.url, required this.color});

  final String url;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
      ),
      child: Text(
        url,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _OnboardingPreview extends GetView<CreateAppController> {
  const _OnboardingPreview({
    required this.phoneWidth,
    required this.phoneHeight,
  });

  final double phoneWidth;
  final double phoneHeight;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final color = controller.selectedThemeColor.value;
      final pad = phoneWidth * 0.07;

      if (!controller.onboardingEnabled.value) {
        return _WebAppScaffold(
          phoneHeight: phoneHeight,
          accent: color,
          title: _appName(controller),
          url: _displayUrl(controller),
          body: _PreviewEmptyState(
            icon: Icons.skip_next_rounded,
            title: 'enable_onboarding'.tr,
            message: 'enable_onboarding_sub'.tr,
            accent: color,
          ),
          showBottomNav: controller.bottomNavEnabled.value,
          tabs: controller.navTabs,
        );
      }

      final slide = controller.currentSlide;
      final dots = controller.slides.length;

      return ColoredBox(
        color: AppColors.createBackground,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (slide.imagePath != null)
                    CreatePickedImage(
                      imagePath: slide.imagePath!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  else
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withValues(alpha: 0.2),
                            color.withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.image_rounded,
                        color: color,
                        size: phoneWidth * 0.22,
                      ),
                    ),
                  Positioned(
                    top: phoneHeight * 0.06,
                    right: pad,
                    child: Text(
                      'skip'.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: phoneWidth * 0.035,
                        shadows: const [
                          Shadow(color: Colors.black26, blurRadius: 6),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(pad),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(dots, (index) {
                      final active =
                          index == controller.currentSlideIndex.value;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: EdgeInsets.symmetric(
                          horizontal: phoneWidth * 0.006,
                        ),
                        width: active ? phoneWidth * 0.055 : phoneWidth * 0.022,
                        height: phoneWidth * 0.022,
                        decoration: BoxDecoration(
                          color: active ? color : AppColors.createFieldBorder,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: phoneHeight * 0.02),
                  Text(
                    slide.title.trim().isEmpty
                        ? 'slide_title_placeholder'.tr
                        : slide.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: phoneWidth * 0.052,
                      color: AppColors.createTitle,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: phoneHeight * 0.012),
                  Text(
                    slide.description.trim().isEmpty
                        ? 'slide_desc_placeholder'.tr
                        : slide.description,
                    style: TextStyle(
                      fontSize: phoneWidth * 0.035,
                      color: AppColors.createMuted,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (slide.ctaEnabled) ...[
                    SizedBox(height: phoneHeight * 0.024),
                    _PreviewCta(
                      label: slide.ctaLabel.trim().isEmpty
                          ? 'button_label_hint'.tr
                          : slide.ctaLabel,
                      color: color,
                      width: phoneWidth,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _PreviewCta extends StatelessWidget {
  const _PreviewCta({
    required this.label,
    required this.color,
    required this.width,
  });

  final String label;
  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: width * 0.04),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(width * 0.05),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: width * 0.04,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _NavigationPreview extends GetView<CreateAppController> {
  const _NavigationPreview({required this.phoneHeight});

  final double phoneHeight;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final color = controller.selectedThemeColor.value;
      final tabs = controller.navTabs.toList();
      return _WebAppScaffold(
        phoneHeight: phoneHeight,
        accent: color,
        title: _appName(controller),
        url: _displayUrl(controller),
        showBottomNav: controller.bottomNavEnabled.value,
        tabs: tabs,
        body: _NavigationBody(
          accent: color,
          tabs: tabs,
          bottomNavEnabled: controller.bottomNavEnabled.value,
        ),
      );
    });
  }
}

class _NavigationBody extends StatelessWidget {
  const _NavigationBody({
    required this.accent,
    required this.tabs,
    required this.bottomNavEnabled,
  });

  final Color accent;
  final List<NavTabModel> tabs;
  final bool bottomNavEnabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bottomNavEnabled ? 'bottom_navigation'.tr : 'webview'.tr,
            style: const TextStyle(
              color: AppColors.createTitle,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            bottomNavEnabled
                ? '${tabs.length} ${'tab_home'.tr.toLowerCase()} / ${'browser'.tr}'
                : 'Single webview layout',
            style: const TextStyle(color: AppColors.createMuted, fontSize: 10),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.35,
              physics: const NeverScrollableScrollPhysics(),
              children: tabs.take(4).map((tab) {
                return _PreviewMiniCard(
                  icon: _navIcon(tab.type),
                  title: tab.label,
                  subtitle: tab.mode == NavTabMode.browser
                      ? 'browser'.tr
                      : 'preview_webview'.tr,
                  accent: accent,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _WebviewPreview extends GetView<CreateAppController> {
  const _WebviewPreview({required this.phoneHeight});

  final double phoneHeight;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final color = controller.selectedThemeColor.value;
      final permissions = controller.permissions.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();
      final features = controller.extraFeatures.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      return _WebAppScaffold(
        phoneHeight: phoneHeight,
        accent: color,
        title: _appName(controller),
        url: _displayUrl(controller),
        showBottomNav: controller.bottomNavEnabled.value,
        tabs: controller.navTabs,
        body: _WebviewBody(
          accent: color,
          url: _displayUrl(controller),
          pullToRefresh: controller.pullToRefresh.value,
          desktopMode: controller.desktopMode.value,
          keepAwake: controller.keepScreenAlive.value,
          permissions: permissions,
          features: features,
        ),
      );
    });
  }
}

class _WebviewBody extends StatelessWidget {
  const _WebviewBody({
    required this.accent,
    required this.url,
    required this.pullToRefresh,
    required this.desktopMode,
    required this.keepAwake,
    required this.permissions,
    required this.features,
  });

  final Color accent;
  final String url;
  final bool pullToRefresh;
  final bool desktopMode;
  final bool keepAwake;
  final List<String> permissions;
  final List<String> features;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ClipRect(
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.createFieldBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.createFieldBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.language_rounded, color: accent, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            url,
                            style: const TextStyle(
                              color: AppColors.createTitle,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _PreviewBrowserBar(accent: accent),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: [
                              if (pullToRefresh)
                                _PreviewBadge('pull_to_refresh'.tr),
                              if (desktopMode) _PreviewBadge('desktop_mode'.tr),
                              if (keepAwake)
                                _PreviewBadge('keep_screen_alive'.tr),
                              ...permissions.take(2).map(_permissionBadge),
                              ...features.take(2).map(_featureBadge),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (features.contains('noInternetDialog')) ...[
              const SizedBox(height: 6),
              _PreviewAlert(
                icon: Icons.wifi_off_rounded,
                title: 'feat_no_internet'.tr,
                accent: accent,
              ),
            ],
            if (features.contains('pushNotificationPopup')) ...[
              const SizedBox(height: 6),
              _PreviewAlert(
                icon: Icons.notifications_active_rounded,
                title: 'feat_push_popup'.tr,
                accent: accent,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WebAppScaffold extends StatelessWidget {
  const _WebAppScaffold({
    required this.phoneHeight,
    required this.accent,
    required this.title,
    required this.url,
    required this.body,
    required this.showBottomNav,
    required this.tabs,
  });

  final double phoneHeight;
  final Color accent;
  final String title;
  final String url;
  final Widget body;
  final bool showBottomNav;
  final List<NavTabModel> tabs;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            height: phoneHeight * 0.095,
            padding: EdgeInsets.fromLTRB(
              phoneHeight * 0.024,
              phoneHeight * 0.034,
              phoneHeight * 0.024,
              phoneHeight * 0.008,
            ),
            decoration: BoxDecoration(
              color: accent,
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: 210,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            url,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Icon(Icons.more_vert_rounded, color: Colors.white, size: 18),
              ],
            ),
          ),
          Expanded(child: body),
          if (showBottomNav) _PreviewBottomNav(tabs: tabs, accent: accent),
        ],
      ),
    );
  }
}

class _PreviewBottomNav extends StatelessWidget {
  const _PreviewBottomNav({required this.tabs, required this.accent});

  final List<NavTabModel> tabs;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final visibleTabs = tabs.take(4).toList();
    return Container(
      height: 50,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.createFieldBorder)),
      ),
      child: Row(
        children: visibleTabs.map((tab) {
          final active = visibleTabs.first == tab;
          return Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: 58,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _navIcon(tab.type),
                        color: active ? accent : AppColors.createPreviewMuted,
                        size: 15,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tab.label,
                        style: TextStyle(
                          color: active ? accent : AppColors.createPreviewMuted,
                          fontSize: 7.5,
                          fontWeight: active
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PreviewMiniCard extends StatelessWidget {
  const _PreviewMiniCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FittedBox(
        alignment: Alignment.center,
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: 86,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: accent, size: 18),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.createTitle,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.createMuted,
                  fontSize: 8,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewBrowserBar extends StatelessWidget {
  const _PreviewBrowserBar({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(4, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 7),
          height: index == 0 ? 44 : 26,
          decoration: BoxDecoration(
            color: index == 0 ? accent.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.createFieldBorder),
          ),
        );
      }),
    );
  }
}

class _PreviewEmptyState extends StatelessWidget {
  const _PreviewEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: accent, size: 42),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.createTitle,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: const TextStyle(
                color: AppColors.createMuted,
                fontSize: 10,
                height: 1.35,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewBadge extends StatelessWidget {
  const _PreviewBadge(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.createAccentLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.createAccent,
          fontWeight: FontWeight.w700,
          fontSize: 8,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _PreviewAlert extends StatelessWidget {
  const _PreviewAlert({
    required this.icon,
    required this.title,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.createFieldBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.createTitle,
                fontWeight: FontWeight.w700,
                fontSize: 9,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

String _appName(CreateAppController controller) {
  final name = controller.appNameController.text.trim();
  return name.isEmpty ? 'your_app'.tr : name;
}

String _displayUrl(CreateAppController controller) {
  final url = controller.websiteUrlController.text.trim();
  return url.isEmpty ? 'website_url_placeholder'.tr : url;
}

IconData _navIcon(NavTabType type) {
  switch (type) {
    case NavTabType.home:
      return Icons.home_rounded;
    case NavTabType.privacyPolicy:
      return Icons.privacy_tip_rounded;
    case NavTabType.whatsapp:
      return Icons.chat_rounded;
    case NavTabType.externalLink:
      return Icons.open_in_new_rounded;
  }
}

Widget _permissionBadge(String key) {
  final label = switch (key) {
    'push' => 'perm_push'.tr,
    'camera' => 'perm_camera'.tr,
    'location' => 'perm_location'.tr,
    'storage' => 'perm_storage'.tr,
    'microphone' => 'perm_microphone'.tr,
    _ => key,
  };
  return _PreviewBadge(label);
}

Widget _featureBadge(String key) {
  final label = switch (key) {
    'loadingScreen' => 'feat_loading'.tr,
    'errorScreen' => 'feat_error'.tr,
    'exitConfirmation' => 'feat_exit'.tr,
    'backButtonHandling' => 'feat_back'.tr,
    'noInternetDialog' => 'feat_no_internet'.tr,
    'pushNotificationPopup' => 'feat_push_popup'.tr,
    _ => key,
  };
  return _PreviewBadge(label);
}
