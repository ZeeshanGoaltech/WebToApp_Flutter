import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_to_app/core/constants/app_assets.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/utils/responsive.dart';

/// Figma intro-next pill (node 17:3313) — Get Started with drop shadow.
class IntroGetStartedButton extends StatelessWidget {
  const IntroGetStartedButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final width = Responsive.w(context, 156.56);
    final height = Responsive.w(context, 63.281);
    final radius = Responsive.w(context, 56.501);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.introAccent.withValues(alpha: 0.3),
            offset: Offset(0, Responsive.w(context, 6.78)),
            blurRadius: Responsive.w(context, 13.56),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(radius),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  AppAssets.introGetStartedBg,
                  width: width,
                  height: height,
                  fit: BoxFit.cover,
                ),
                Text(
                  'get_started'.tr,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: Responsive.sp(context, 16.95),
                    height: 25.425 / 16.95,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
