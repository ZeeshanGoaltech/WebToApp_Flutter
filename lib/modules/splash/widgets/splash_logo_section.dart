import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/constants/app_assets.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';

class SplashLogoSection extends StatelessWidget {
  const SplashLogoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final logoSize = Responsive.w(context, 162);
    final borderRadius = Responsive.w(context, 40);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image.asset(
            AppAssets.appIcon,
            width: logoSize,
            height: logoSize,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: Responsive.w(context, 24)),
        Text(
          'app_title'.tr,
          textAlign: TextAlign.center,
          style: AppTextStyles.splashTitle(context),
        ),
        Padding(
          padding: EdgeInsets.only(top: Responsive.w(context, 8)),
          child: Text(
            'splash_tagline'.tr,
            textAlign: TextAlign.center,
            style: AppTextStyles.splashSubtitle(context),
          ),
        ),
      ],
    );
  }
}
