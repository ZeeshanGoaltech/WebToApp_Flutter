import 'package:flutter/material.dart';
import 'package:web_to_app/core/constants/app_assets.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/utils/responsive.dart';
import 'package:web_to_app/core/widgets/intro_arrow_icon.dart';

/// Figma intro-next (node 17:3248) — gradient circle + arrow + drop shadow.
class IntroCircleNextButton extends StatelessWidget {
  const IntroCircleNextButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final size = Responsive.w(context, 63.281);
    final radius = Responsive.w(context, 56.501);
    final iconSize = Responsive.w(context, 30.489);
    final iconLeft = Responsive.w(context, 16.95);
    final iconTop = Responsive.w(context, 15.82);

    return Container(
      width: size,
      height: size,
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
          customBorder: const CircleBorder(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Stack(
              children: [
                Image.asset(
                  AppAssets.introNextBg,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  left: iconLeft,
                  top: iconTop,
                  child: IntroArrowIcon(size: iconSize),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
