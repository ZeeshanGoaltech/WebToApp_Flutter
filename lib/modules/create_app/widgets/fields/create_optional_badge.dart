import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';

class CreateOptionalBadge extends StatelessWidget {
  const CreateOptionalBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(context, 8),
        vertical: Responsive.w(context, 4),
      ),
      decoration: BoxDecoration(
        color: AppColors.createAccentLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'optional'.tr,
        style: AppTextStyles.createOptionalBadge(context),
      ),
    );
  }
}
