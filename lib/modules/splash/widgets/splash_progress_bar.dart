import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';

class SplashProgressBar extends StatelessWidget {
  const SplashProgressBar({
    super.key,
    required this.progress,
    this.showAdsDisclaimer = true,
  });

  final double progress;

  /// Free users see "This action may contain ads"; Pro sees "Loading".
  final bool showAdsDisclaimer;

  @override
  Widget build(BuildContext context) {
    final barWidth = Responsive.w(context, 207.983);
    final barHeight = Responsive.w(context, 5.982);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: barWidth,
          height: barHeight,
          decoration: BoxDecoration(
            color: AppColors.progressTrack,
            borderRadius: BorderRadius.circular(barHeight / 2),
          ),
          clipBehavior: Clip.antiAlias,
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOut,
              width: barWidth * progress.clamp(0.0, 1.0),
              height: barHeight,
              decoration: BoxDecoration(
                color: AppColors.progressFill,
                borderRadius: BorderRadius.circular(barHeight / 2),
              ),
            ),
          ),
        ),
        SizedBox(height: Responsive.w(context, 12)),
        Text(
          showAdsDisclaimer ? 'splash_ads_notice'.tr : 'splash_loading'.tr,
          style: AppTextStyles.splashStatus(context),
        ),
      ],
    );
  }
}
