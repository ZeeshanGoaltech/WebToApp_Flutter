import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/utils/responsive.dart';

class CreateAppProgressBar extends StatelessWidget {
  const CreateAppProgressBar({
    super.key,
    required this.currentStep,
    this.totalSteps = 6,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final pillHeight = Responsive.w(context, 7.994);
    final gap = Responsive.w(context, 4);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        Responsive.w(context, 24),
        Responsive.w(context, 8),
        Responsive.w(context, 24),
        Responsive.w(context, 16),
      ),
      child: ClipRect(
        child: Row(
          children: List.generate(totalSteps, (i) {
            final active = i <= currentStep;
            final isCurrent = i == currentStep;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < totalSteps - 1 ? gap : 0),
                child: Container(
                  height: pillHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: active ? _accentGradient : null,
                    color: active ? null : AppColors.createFieldBorder,
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: AppColors.createAccent.withValues(alpha: 0.5),
                              blurRadius: Responsive.w(context, 8),
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  static const _accentGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    transform: GradientRotation(math.pi / 2),
    colors: [
      Color(0xFF6C63FF),
      Color(0xFF7070FF),
      Color(0xFF7470FF),
      Color(0xFF7972FF),
      Color(0xFF7D77FF),
      Color(0xFF827BFF),
      Color(0xFF8680FF),
      Color(0xFF8B84FF),
    ],
  );
}
