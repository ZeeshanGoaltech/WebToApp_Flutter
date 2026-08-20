import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/modules/create_app/controllers/create_app_controller.dart';
import 'package:web_to_app/modules/create_app/widgets/shell/create_app_bottom_bar.dart';
import 'package:web_to_app/modules/create_app/widgets/shell/create_app_header.dart';
import 'package:web_to_app/modules/create_app/widgets/shell/create_app_progress_bar.dart';
import 'package:web_to_app/modules/create_app/widgets/steps/step1_identity_page.dart';
import 'package:web_to_app/modules/create_app/widgets/steps/step2_settings_page.dart';
import 'package:web_to_app/modules/create_app/widgets/steps/step3_onboarding_page.dart';
import 'package:web_to_app/modules/create_app/widgets/steps/step4_permissions_page.dart';
import 'package:web_to_app/modules/create_app/widgets/steps/step5_extra_features_page.dart';
import 'package:web_to_app/modules/create_app/widgets/steps/step6_preview_page.dart';

class CreateAppView extends GetView<CreateAppController> {
  const CreateAppView({super.key});

  @override
  Widget build(BuildContext context) {
    // Body resizes for the keyboard so focused fields auto-scroll into
    // view; the CTA bar hides while typing instead of riding the keyboard.
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Obx(
      () => Scaffold(
        backgroundColor: AppColors.createBackground,
        body: SafeArea(
          child: Column(
            children: [
              CreateAppHeader(
                title: controller.title,
                stepLabel: '${controller.currentStep.value + 1} of 6',
                onBack: controller.back,
              ),
              CreateAppProgressBar(
                currentStep: controller.currentStep.value,
              ),
              Expanded(
                child: PageView(
                  controller: controller.pageController,
                  onPageChanged: controller.onPageChanged,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    Step1IdentityPage(),
                    Step2SettingsPage(),
                    Step3OnboardingPage(),
                    Step4PermissionsPage(),
                    Step5ExtraFeaturesPage(),
                    Step6PreviewPage(),
                  ],
                ),
              ),
              if (!keyboardOpen)
                CreateAppBottomBar(
                  ctaLabel: controller.ctaLabel,
                  onCta: controller.isSaving.value ? null : controller.next,
                  isLoading: controller.isSaving.value,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
