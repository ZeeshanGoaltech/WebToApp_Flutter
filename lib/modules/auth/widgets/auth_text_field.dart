import 'package:flutter/material.dart';
import 'package:web_to_app/core/constants/app_assets.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';
import 'package:web_to_app/core/widgets/figma_svg_icon.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.prefixIcon,
    this.obscureText = false,
    this.onToggleVisibility,
    this.keyboardType,
    this.errorText,
    this.onChanged,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final String prefixIcon;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final TextInputType? keyboardType;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final fieldHeight = Responsive.w(context, 58.138);
    final radius = Responsive.w(context, 18);
    final borderWidth = Responsive.w(context, 1.098);
    final iconSize = Responsive.w(context, 20);
    final hasError = errorText != null && errorText!.isNotEmpty;
    final borderColor =
        hasError ? AppColors.createDelete : AppColors.authInputBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.authLabel(context)),
        SizedBox(height: Responsive.w(context, 7.992)),
        SizedBox(
          height: fieldHeight,
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              final showVisibilityToggle = onToggleVisibility != null;

              return TextField(
                controller: controller,
                obscureText: obscureText,
                keyboardType: keyboardType,
                onChanged: onChanged,
                style: AppTextStyles.authField(context),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: AppTextStyles.authFieldHint(context),
                  filled: true,
                  fillColor: AppColors.authInputBg,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: Responsive.w(context, 16),
                    vertical: Responsive.w(context, 16),
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(
                      left: Responsive.w(context, 16),
                      right: Responsive.w(context, 12),
                    ),
                    child: FigmaSvgIcon(
                      asset: prefixIcon,
                      size: iconSize,
                    ),
                  ),
                  prefixIconConstraints: BoxConstraints(
                    minWidth: Responsive.w(context, 48),
                    minHeight: iconSize,
                  ),
                  suffixIcon: showVisibilityToggle
                      ? GestureDetector(
                          onTap: onToggleVisibility,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: Responsive.w(context, 16),
                              left: Responsive.w(context, 8),
                            ),
                            child: FigmaSvgIcon(
                              asset: AppAssets.authEyeIcon,
                              size: iconSize,
                            ),
                          ),
                        )
                      : null,
                  suffixIconConstraints: showVisibilityToggle
                      ? BoxConstraints(
                          minWidth: Responsive.w(context, 44),
                          minHeight: iconSize,
                        )
                      : null,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(radius),
                    borderSide: BorderSide(
                      color: borderColor,
                      width: borderWidth,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(radius),
                    borderSide: BorderSide(
                      color: hasError
                          ? AppColors.createDelete
                          : AppColors.authAccent,
                      width: borderWidth,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(radius),
                    borderSide: BorderSide(
                      color: AppColors.createDelete,
                      width: borderWidth,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(radius),
                    borderSide: BorderSide(
                      color: AppColors.createDelete,
                      width: borderWidth,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(radius),
                    borderSide: BorderSide(
                      color: borderColor,
                      width: borderWidth,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (hasError) ...[
          SizedBox(height: Responsive.w(context, 6)),
          Padding(
            padding: EdgeInsets.only(left: Responsive.w(context, 8)),
            child: Text(
              errorText!,
              style: AppTextStyles.createRowSubtitle(context).copyWith(
                color: AppColors.createDelete,
                fontSize: Responsive.sp(context, 12),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
