import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';

class IntroTopBar extends StatelessWidget {
  const IntroTopBar({
    super.key,
    required this.showSkip,
    required this.onSkip,
  });

  final bool showSkip;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final height = Responsive.h(context, showSkip ? 24 : 2);

    if (!showSkip) {
      return SizedBox(height: height);
    }

    return SizedBox(
      height: height,
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.only(right: Responsive.w(context, 20)),
          child: GestureDetector(
            onTap: onSkip,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(context, 8),
                vertical: Responsive.h(context, 2),
              ),
              child: Text(
                'skip'.tr,
                style: AppTextStyles.introSkip(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
