import 'package:flutter/material.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/utils/responsive.dart';
import 'package:web_to_app/core/widgets/create_gradient_button.dart';

class CreateAppBottomBar extends StatelessWidget {
  const CreateAppBottomBar({
    super.key,
    required this.ctaLabel,
    required this.onCta,
    this.isLoading = false,
  });

  final String ctaLabel;
  final VoidCallback? onCta;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.createFieldBorder, width: 1.16),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        Responsive.w(context, 24),
        Responsive.w(context, 17.16),
        Responsive.w(context, 24),
        Responsive.w(context, 32),
      ),
      child: CreateGradientButton(
        label: ctaLabel,
        onPressed: onCta,
        isLoading: isLoading,
      ),
    );
  }
}
