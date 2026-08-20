import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';
import 'package:web_to_app/modules/create_app/models/nav_tab_model.dart';

class CreateSegmentPill extends StatelessWidget {
  const CreateSegmentPill({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  final NavTabMode mode;
  final ValueChanged<NavTabMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _PillButton(
          label: 'webview'.tr,
          selected: mode == NavTabMode.webview,
          onTap: () => onChanged(NavTabMode.webview),
        ),
        SizedBox(width: Responsive.w(context, 8)),
        _PillButton(
          label: 'browser'.tr,
          selected: mode == NavTabMode.browser,
          onTap: () => onChanged(NavTabMode.browser),
        ),
      ],
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            padding: EdgeInsets.symmetric(vertical: Responsive.w(context, 8)),
            decoration: BoxDecoration(
              color: selected ? AppColors.createAccent : AppColors.createFieldBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Center(
              child: Text(
                label,
                style: AppTextStyles.createLink(context).copyWith(
                  color: selected ? Colors.white : AppColors.createMuted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
