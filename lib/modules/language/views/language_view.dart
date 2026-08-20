import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/ads/ad_placements.dart';
import 'package:web_to_app/core/ads/widgets/medium_native_ad_widget.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/utils/responsive.dart';
import 'package:web_to_app/modules/language/controllers/language_controller.dart';
import 'package:web_to_app/modules/language/widgets/language_header.dart';
import 'package:web_to_app/modules/language/widgets/language_tile.dart';

class LanguageView extends GetView<LanguageController> {
  const LanguageView({super.key});

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
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const LanguageHeader(),
              Expanded(
                child: Obx(() {
                  final selectedId = controller.selectedLanguageId.value;
                  return ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.w(context, 20),
                    ),
                    itemCount: controller.languages.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: Responsive.w(context, 10)),
                    itemBuilder: (context, index) {
                      final language = controller.languages[index];
                      return LanguageTile(
                        language: language,
                        isSelected: selectedId == language.id,
                        onTap: () => controller.selectLanguage(language.id),
                      );
                    },
                  );
                }),
              ),
              // Fixed bottom medium native (RC: language_native)
              const MediumNativeAdWidget(
                placementId: AdPlacements.languageNative,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
