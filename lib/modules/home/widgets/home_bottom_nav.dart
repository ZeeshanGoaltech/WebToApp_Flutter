import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/constants/app_assets.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';
import 'package:web_to_app/core/widgets/figma_svg_icon.dart';

class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  static List<_NavTab> get _tabs => [
    _NavTab('nav_home'.tr, AppAssets.navHome),
    _NavTab('nav_my_apps'.tr, AppAssets.navMyApps),
    _NavTab('nav_help'.tr, AppAssets.navGuide),
    _NavTab('nav_settings'.tr, AppAssets.navSettings),
  ];

  @override
  Widget build(BuildContext context) {
    final borderWidth = Responsive.w(context, 1.212);
    final navHeight = Responsive.w(context, 86);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.homeBorder,
            width: borderWidth,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        left: Responsive.w(context, 17.519),
        top: borderWidth,
        right: Responsive.w(context, 17.519),
        bottom: bottomInset > 0 ? bottomInset : Responsive.h(context, 8),
      ),
      child: SizedBox(
        height: navHeight,
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final tab = _tabs[index];
            final isActive = selectedIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTabSelected(index),
                behavior: HitTestBehavior.opaque,
                child: _NavItem(
                  label: tab.label,
                  iconAsset: tab.iconAsset,
                  isActive: isActive,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavTab {
  _NavTab(this.label, this.iconAsset);
  final String label;
  final String iconAsset;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.iconAsset,
    required this.isActive,
  });

  final String label;
  final String iconAsset;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final iconSize = isActive
        ? Responsive.w(context, 32)
        : Responsive.w(context, 30);
    final radius = Responsive.w(context, 17.519);
    final labelGap = isActive
        ? Responsive.w(context, 4)
        : Responsive.w(context, 5);

    if (isActive) {
      return Center(
        child: SizedBox(
          width: Responsive.w(context, 82),
          height: Responsive.w(context, 66),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.homeAccentLight,
                  borderRadius: BorderRadius.circular(radius),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FigmaSvgIcon(
                    asset: iconAsset,
                    size: iconSize,
                    color: AppColors.homeAccent,
                    tinted: true,
                  ),
                  SizedBox(height: labelGap),
                  Text(
                    label,
                    style: AppTextStyles.homeNavLabel(context, active: true),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(context, 17.519),
        vertical: Responsive.w(context, 6.57),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FigmaSvgIcon(
            asset: iconAsset,
            size: iconSize,
            color: AppColors.homeMuted,
            tinted: true,
          ),
          SizedBox(height: labelGap),
          Text(
            label,
            style: AppTextStyles.homeNavLabel(context, active: false),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
