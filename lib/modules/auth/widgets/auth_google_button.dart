import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/constants/app_assets.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';
import 'package:web_to_app/core/widgets/figma_svg_icon.dart';

class AuthGoogleButton extends StatelessWidget {
  const AuthGoogleButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final height = Responsive.w(context, 64.072);
    final radius = Responsive.w(context, 57.21);
    final borderWidth = Responsive.w(context, 1.327);
    final iconSize = Responsive.w(context, 22.879);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: AppColors.authInputBorder,
              width: borderWidth,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FigmaSvgIcon(
                asset: AppAssets.googleIcon,
                size: iconSize,
              ),
              SizedBox(width: Responsive.w(context, 9.154)),
              Text(
                'continue_with_google'.tr,
                style: AppTextStyles.authGoogleBtn(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
