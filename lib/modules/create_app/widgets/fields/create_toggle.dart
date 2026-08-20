import 'package:flutter/material.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';

class CreateToggle extends StatelessWidget {
  const CreateToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final width = Responsive.w(context, 51.991);
    final height = Responsive.w(context, 29.984);
    final thumbSize = Responsive.w(context, 26);

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: value ? accentGradient : null,
          color: value ? null : AppColors.createFieldBorder,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: Responsive.w(context, 2)),
            width: thumbSize,
            height: thumbSize,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  offset: Offset(0, Responsive.w(context, 1)),
                  blurRadius: Responsive.w(context, 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const accentGradient = LinearGradient(
    colors: [
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
  );
}

class CreateToggleRow extends StatelessWidget {
  const CreateToggleRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.createRowTitle(context)),
              Text(subtitle, style: AppTextStyles.createRowSubtitle(context)),
            ],
          ),
        ),
        CreateToggle(value: value, onChanged: onChanged),
      ],
    );
  }
}
