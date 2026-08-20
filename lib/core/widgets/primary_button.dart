import 'package:flutter/material.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width,
    this.height,
  });

  final String label;
  final VoidCallback onPressed;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final buttonWidth = width ?? Responsive.w(context, 91.833);
    final buttonHeight = height ?? Responsive.w(context, 38);
    final radius = Responsive.r(context, 12.667);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          width: buttonWidth,
          height: buttonHeight,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                offset: Offset(0, Responsive.w(context, 7.917)),
                blurRadius: Responsive.w(context, 5.938),
              ),
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                offset: Offset(0, Responsive.w(context, 3.167)),
                blurRadius: Responsive.w(context, 2.375),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.primaryButton(context),
            ),
          ),
        ),
      ),
    );
  }
}
