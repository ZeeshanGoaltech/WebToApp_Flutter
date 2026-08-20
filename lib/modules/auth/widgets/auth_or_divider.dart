import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';

class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: Responsive.w(context, 1.141),
            color: AppColors.authInputBorder,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(context, 18.307),
          ),
          child: Text(
            'or_continue_with'.tr,
            style: AppTextStyles.authDivider(context),
          ),
        ),
        Expanded(
          child: Container(
            height: Responsive.w(context, 1.141),
            color: AppColors.authInputBorder,
          ),
        ),
      ],
    );
  }
}
