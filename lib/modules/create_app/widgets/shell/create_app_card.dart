import 'package:flutter/material.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/utils/responsive.dart';

class CreateAppCard extends StatelessWidget {
  const CreateAppCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
  });

  final Widget child;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding ?? EdgeInsets.all(Responsive.w(context, 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.w(context, 20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.createCardShadow,
            offset: Offset(0, Responsive.w(context, 2)),
            blurRadius: Responsive.w(context, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
