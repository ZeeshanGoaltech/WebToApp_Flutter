import 'package:flutter/material.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/utils/responsive.dart';

class AppCircleButton extends StatelessWidget {
  const AppCircleButton({
    super.key,
    required this.onPressed,
    required this.size,
    this.icon,
    this.iconAsset,
    this.iconSize,
    this.shadowColor,
    this.shadowOffsetY,
    this.shadowBlur,
    this.gradientColors,
  }) : assert(icon != null || iconAsset != null);

  final VoidCallback onPressed;
  final double size;
  final IconData? icon;
  final String? iconAsset;
  final double? iconSize;
  final Color? shadowColor;
  final double? shadowOffsetY;
  final double? shadowBlur;
  final List<Color>? gradientColors;

  @override
  Widget build(BuildContext context) {
    final buttonSize = Responsive.w(context, size);
    final resolvedIconSize = iconSize ?? Responsive.w(context, 30.489);
    final resolvedShadowOffset = shadowOffsetY ?? Responsive.w(context, 6.78);
    final resolvedShadowBlur = shadowBlur ?? Responsive.w(context, 13.56);
    final colors = gradientColors ??
        const [AppColors.introAccent, Color(0xFF8B83FF)];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Ink(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            boxShadow: [
              BoxShadow(
                color: (shadowColor ?? AppColors.introAccent)
                    .withValues(alpha: 0.3),
                offset: Offset(0, resolvedShadowOffset),
                blurRadius: resolvedShadowBlur,
              ),
            ],
          ),
          child: Center(
            child: iconAsset != null
                ? Image.asset(
                    iconAsset!,
                    width: resolvedIconSize,
                    height: resolvedIconSize,
                    fit: BoxFit.contain,
                  )
                : Icon(
                    icon,
                    color: Colors.white,
                    size: resolvedIconSize,
                  ),
          ),
        ),
      ),
    );
  }
}
