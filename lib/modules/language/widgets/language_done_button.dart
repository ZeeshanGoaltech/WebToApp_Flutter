import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';

/// Pill-shaped Done button matching Select Languages header.
class LanguageDoneButton extends StatelessWidget {
  const LanguageDoneButton({
    super.key,
    required this.onPressed,
    this.compact = false,
  });

  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final height = Responsive.w(context, compact ? 34 : 36);
    final radius = height / 2;
    final horizontalPad = Responsive.w(context, compact ? 16 : 20);

    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPad),
          child: SizedBox(
            height: height,
            child: Center(
              child: Text(
                'done'.tr,
                style: AppTextStyles.primaryButton(context).copyWith(
                  fontSize: Responsive.sp(context, compact ? 13 : 14),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
