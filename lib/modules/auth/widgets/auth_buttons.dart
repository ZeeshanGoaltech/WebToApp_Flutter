import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/constants/app_assets.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';
import 'package:web_to_app/core/widgets/button_loading_indicator.dart';
import 'package:web_to_app/core/widgets/figma_svg_icon.dart';

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final height = Responsive.w(context, 55.96);
    final radius = Responsive.w(context, 108);
    final canTap = enabled && onPressed != null && !isLoading;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canTap ? onPressed : null,
          borderRadius: BorderRadius.circular(radius),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              color: canTap ? null : AppColors.authDisabledBtn,
              gradient: canTap
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.authGuestStart,
                        AppColors.authGuestEnd,
                      ],
                    )
                  : null,
            ),
            child: Center(
              child: isLoading
                  ? const ButtonLoadingIndicator(color: Colors.white)
                  : Text(
                      label,
                      style: canTap
                          ? AppTextStyles.authGuestBtn(context)
                          : AppTextStyles.authPrimaryBtn(context),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthGuestButton extends StatelessWidget {
  const AuthGuestButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.label,
    this.showIcon = true,
  });

  final VoidCallback? onPressed;
  final bool isLoading;
  final String? label;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final height = Responsive.w(context, 55.99);
    final radius = Responsive.w(context, 85);
    final enabled = onPressed != null && !isLoading;
    final iconSize = Responsive.w(context, 20);

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(radius),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.authGuestStart,
                  AppColors.authGuestEnd,
                ],
              ),
            ),
            child: Center(
              child: isLoading
                  ? const ButtonLoadingIndicator()
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (showIcon) ...[
                          FigmaSvgIcon(
                            asset: AppAssets.authGuestIcon,
                            size: iconSize,
                          ),
                          SizedBox(width: Responsive.w(context, 8)),
                        ],
                        Text(
                          label ?? 'continue_as_guest'.tr,
                          style: AppTextStyles.authGuestBtn(context),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Kept for forgot-password sheet compatibility.
class AuthSecondaryButton extends AuthPrimaryButton {
  const AuthSecondaryButton({
    super.key,
    required super.label,
    required super.onPressed,
    super.isLoading,
    super.enabled,
  });
}
