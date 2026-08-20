import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/constants/help_guide_assets.dart';

class HelpGuideStep {
  const HelpGuideStep({
    required this.number,
    required this.title,
    required this.description,
    required this.iconAsset,
    required this.iconBackground,
    required this.badgeColor,
  });

  final int number;
  final String title;
  final String description;
  final String iconAsset;
  final Color iconBackground;
  final Color badgeColor;
}

class HelpGuideSteps {
  HelpGuideSteps._();

  static List<HelpGuideStep> get steps => [
        HelpGuideStep(
          number: 1,
          title: 'help_step1_title'.tr,
          description: 'help_step1_desc'.tr,
          iconAsset: HelpGuideAssets.stepUrl,
          iconBackground: const Color(0xFFF0EFFF),
          badgeColor: const Color(0xFF6C63FF),
        ),
        HelpGuideStep(
          number: 2,
          title: 'help_step2_title'.tr,
          description: 'help_step2_desc'.tr,
          iconAsset: HelpGuideAssets.stepSettings,
          iconBackground: const Color(0xFFFFFBEB),
          badgeColor: const Color(0xFFF59E0B),
        ),
        HelpGuideStep(
          number: 3,
          title: 'help_step3_title'.tr,
          description: 'help_step3_desc'.tr,
          iconAsset: HelpGuideAssets.stepOnboarding,
          iconBackground: const Color(0xFFECFEFF),
          badgeColor: const Color(0xFF06B6D4),
        ),
        HelpGuideStep(
          number: 4,
          title: 'help_step4_title'.tr,
          description: 'help_step4_desc'.tr,
          iconAsset: HelpGuideAssets.stepPreview,
          iconBackground: const Color(0xFFECFDF5),
          badgeColor: const Color(0xFF10B981),
        ),
        HelpGuideStep(
          number: 5,
          title: 'help_step5_title'.tr,
          description: 'help_step5_desc'.tr,
          iconAsset: HelpGuideAssets.stepBuild,
          iconBackground: const Color(0xFFF3F2FF),
          badgeColor: const Color(0xFF8B84FF),
        ),
      ];
}
