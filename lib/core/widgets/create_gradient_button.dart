import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';
import 'package:web_to_app/core/widgets/button_loading_indicator.dart';

class CreateGradientButton extends StatelessWidget {
  const CreateGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leading,
    this.width,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final double? width;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final height = Responsive.w(context, 55.997);
    final radius = Responsive.w(context, 50);
    final enabled = onPressed != null && !isLoading;

    return Container(
      width: width ?? Responsive.w(context, 391.747),
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.createAccent.withValues(alpha: 0.2),
            offset: Offset(0, Responsive.w(context, 2)),
            blurRadius: Responsive.w(context, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(radius),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                transform: GradientRotation(171.865 * math.pi / 180),
                colors: const [
                  Color(0xFF6C63FF),
                  Color(0xFF6E66FF),
                  Color(0xFF7169FF),
                  Color(0xFF7370FF),
                  Color(0xFF7671FF),
                  Color(0xFF7875FF),
                  Color(0xFF7B74FF),
                  Color(0xFF7E77FF),
                  Color(0xFF807AFF),
                  Color(0xFF837CFF),
                  Color(0xFF867FFF),
                  Color(0xFF8881FF),
                  Color(0xFF8B84FF),
                ],
              ),
            ),
            child: Center(
              child: isLoading
                  ? const ButtonLoadingIndicator()
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (leading != null) ...[
                          leading!,
                          SizedBox(width: Responsive.w(context, 8)),
                        ],
                        Text(label, style: AppTextStyles.createCta(context)),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
