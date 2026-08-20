import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/ads/ad_placements.dart';
import 'package:web_to_app/core/ads/widgets/medium_native_ad_widget.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/modules/intro/controllers/intro_controller.dart';
import 'package:web_to_app/modules/intro/data/intro_data.dart';
import 'package:web_to_app/modules/intro/widgets/intro_page_content.dart';
import 'package:web_to_app/modules/intro/widgets/intro_top_bar.dart';

class IntroView extends GetView<IntroController> {
  const IntroView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldClose = await controller.handleSystemBack();
        if (shouldClose && context.mounted) {
          Get.back();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.introBackground,
        body: SafeArea(
          child: Column(
            children: [
              Obx(
                () => IntroTopBar(
                  showSkip: controller.currentPage.value < 2,
                  onSkip: controller.skip,
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: controller.pageController,
                  onPageChanged: controller.onPageChanged,
                  itemCount: IntroData.pageCount,
                  itemBuilder: (context, index) {
                    return IntroPageContent(
                      page: IntroData.pages[index],
                      pageIndex: index,
                      onNext: controller.onNext,
                    );
                  },
                ),
              ),
              // Same medium ad size as language / other screens (no height clip)
              MediumNativeAdWidget(
                placementId: AdPlacements.onboardingNative,
                reserveSpaceWhileLoading: false,
                onVisibilityChanged: controller.onNativeAdVisibilityChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
