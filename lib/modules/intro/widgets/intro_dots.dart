import 'package:flutter/material.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/utils/responsive.dart';

class IntroDots extends StatelessWidget {
  const IntroDots({
    super.key,
    required this.currentPage,
    this.pageCount = 3,
  });

  final int currentPage;
  final int pageCount;

  @override
  Widget build(BuildContext context) {
    final dotSize = Responsive.w(context, 9.04);
    final activeWidth = Responsive.w(context, 31.64);
    final gap = Responsive.w(context, 9.04);
    final radius = Responsive.w(context, 56.501);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(pageCount, (index) {
        final isActive = index == currentPage;
        return Padding(
          padding: EdgeInsets.only(left: index == 0 ? 0 : gap),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: isActive ? activeWidth : dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.introAccent
                  : AppColors.introDotInactive,
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        );
      }),
    );
  }
}
