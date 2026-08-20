import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';
import 'package:web_to_app/modules/create_app/widgets/shell/create_back_icon.dart';
import 'package:web_to_app/modules/language/controllers/language_controller.dart';
import 'package:web_to_app/modules/language/widgets/language_done_button.dart';

class LanguageHeader extends GetView<LanguageController> {
  const LanguageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final fromSettings = controller.fromSettings;
    final titleStyle = fromSettings
        ? AppTextStyles.languageTitle(
            context,
          ).copyWith(fontSize: Responsive.sp(context, 19), height: 1.18)
        : AppTextStyles.languageTitle(context).copyWith(
            fontSize: Responsive.sp(context, 22),
            height: 1.2,
          );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        Responsive.w(context, 20),
        Responsive.w(context, fromSettings ? 16 : 20),
        Responsive.w(context, 20),
        Responsive.w(context, fromSettings ? 12 : 16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (fromSettings) ...[
            GestureDetector(
              onTap: controller.onBack,
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: Responsive.w(context, 32),
                height: Responsive.w(context, 32),
                child: Center(
                  child: CreateBackIcon(size: Responsive.w(context, 32)),
                ),
              ),
            ),
            SizedBox(width: Responsive.w(context, 8)),
          ],
          Expanded(
            child: Text('choose_language'.tr, style: titleStyle),
          ),
          LanguageDoneButton(onPressed: controller.onDone),
        ],
      ),
    );
  }
}
