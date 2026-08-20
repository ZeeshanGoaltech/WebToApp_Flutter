import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/constants/settings_assets.dart';

class SettingsMenuItem {
  const SettingsMenuItem({
    required this.title,
    required this.subtitle,
    required this.iconAsset,
    required this.iconBackground,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String iconAsset;
  final Color iconBackground;
  final VoidCallback? onTap;
}

class SettingsMenuData {
  SettingsMenuData._();

  static List<SettingsMenuItem> get preferences => [
        SettingsMenuItem(
          title: 'language'.tr,
          subtitle: '🇬🇧 English',
          iconAsset: SettingsAssets.globe,
          iconBackground: const Color(0xFFECFEFF),
        ),
      ];

  static List<SettingsMenuItem> get more => [
        SettingsMenuItem(
          title: 'privacy_policy'.tr,
          subtitle: 'privacy_policy_subtitle'.tr,
          iconAsset: SettingsAssets.shield,
          iconBackground: const Color(0xFFEFF6FF),
        ),
        SettingsMenuItem(
          title: 'terms_conditions'.tr,
          subtitle: 'terms_subtitle'.tr,
          iconAsset: SettingsAssets.document,
          iconBackground: const Color(0xFFECFDF5),
        ),
        SettingsMenuItem(
          title: 'share_app'.tr,
          subtitle: 'share_app_subtitle'.tr,
          iconAsset: SettingsAssets.share,
          iconBackground: const Color(0xFFFFF7ED),
        ),
        SettingsMenuItem(
          title: 'rate_app'.tr,
          subtitle: 'rate_app_subtitle'.tr,
          iconAsset: SettingsAssets.star,
          iconBackground: const Color(0xFFFFFBEB),
        ),
      ];
}
