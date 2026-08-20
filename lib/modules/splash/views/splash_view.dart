import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/services/premium_service.dart';
import 'package:web_to_app/core/services/session_service.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/utils/responsive.dart';
import 'package:web_to_app/modules/splash/controllers/splash_controller.dart';
import 'package:web_to_app/modules/splash/widgets/splash_logo_section.dart';
import 'package:web_to_app/modules/splash/widgets/splash_progress_bar.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 24)),
          child: Column(
            children: [
              const Expanded(
                child: Center(child: SplashLogoSection()),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: Responsive.h(context, 24)),
                child: Obx(() {
                  // Rebuild instantly when restore unlocks premium.
                  final sessionPremium = Get.isRegistered<SessionService>() &&
                      Get.find<SessionService>().hasPremiumAccess;
                  final showAdsDisclaimer = !controller.isPremium.value &&
                      !sessionPremium &&
                      !PremiumService.isPremiumCached;

                  return SplashProgressBar(
                    progress: controller.progress.value,
                    showAdsDisclaimer: showAdsDisclaimer,
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
