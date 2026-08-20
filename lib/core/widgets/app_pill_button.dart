import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/utils/responsive.dart';

class AppPillButton extends StatelessWidget {
  const AppPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.width,
    required this.height,
    required this.fontSize,
    this.borderRadius,
    this.fontWeight = FontWeight.w600,
    this.lineHeight,
    this.backgroundColor,
    this.gradientColors,
    this.textColor = Colors.white,
    this.trailing,
  });

  final String label;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final double fontSize;
  final double? borderRadius;
  final FontWeight fontWeight;
  final double? lineHeight;
  final Color? backgroundColor;
  final List<Color>? gradientColors;
  final Color textColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final buttonWidth = Responsive.w(context, width);
    final buttonHeight = Responsive.w(context, height);
    final radius = borderRadius ?? height / 2;
    final resolvedLineHeight = lineHeight ?? fontSize * 1.5;
    final colors = gradientColors ??
        const [AppColors.introAccent, Color(0xFF8B83FF)];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(Responsive.w(context, radius)),
        child: Ink(
          width: buttonWidth,
          height: buttonHeight,
          decoration: BoxDecoration(
            color: backgroundColor,
            gradient: backgroundColor == null
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors,
                  )
                : null,
            borderRadius: BorderRadius.circular(Responsive.w(context, radius)),
            boxShadow: [
              BoxShadow(
                color: AppColors.introAccent.withValues(alpha: 0.3),
                offset: Offset(0, Responsive.w(context, 6.78)),
                blurRadius: Responsive.w(context, 13.56),
              ),
            ],
          ),
          child: Center(
            child: trailing == null
                ? Text(
                    label,
                    style: GoogleFonts.inter(
                      fontWeight: fontWeight,
                      fontSize: Responsive.sp(context, fontSize),
                      height: resolvedLineHeight / fontSize,
                      color: textColor,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.inter(
                          fontWeight: fontWeight,
                          fontSize: Responsive.sp(context, fontSize),
                          height: resolvedLineHeight / fontSize,
                          color: textColor,
                        ),
                      ),
                      trailing!,
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
