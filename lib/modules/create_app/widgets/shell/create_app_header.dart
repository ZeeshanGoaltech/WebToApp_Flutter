import 'package:flutter/material.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';
import 'package:web_to_app/core/widgets/credits_badge_button.dart';
import 'package:web_to_app/modules/create_app/widgets/shell/create_back_icon.dart';

class CreateAppHeader extends StatelessWidget {
  const CreateAppHeader({
    super.key,
    required this.title,
    required this.stepLabel,
    required this.onBack,
    this.trailing,
  });

  final String title;
  final String stepLabel;
  final VoidCallback onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final iconSize = Responsive.w(context, 31.996);
    final sideWidth = Responsive.w(context, 72);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        Responsive.w(context, 24),
        Responsive.w(context, 26),
        Responsive.w(context, 24),
        Responsive.w(context, 16),
      ),
      child: SizedBox(
        height: iconSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              children: [
                _BackButton(size: iconSize, onBack: onBack),
                const Spacer(),
                SizedBox(
                  width: sideWidth,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: trailing ??
                        Text(
                          stepLabel,
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.createStepLabel(context),
                        ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sideWidth),
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.createHeaderTitle(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.size, required this.onBack});

  final double size;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onBack,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: size,
        height: size,
        child: Center(
          child: CreateBackIcon(size: size),
        ),
      ),
    );
  }
}

class CreateBuildHeader extends StatelessWidget {
  const CreateBuildHeader({
    super.key,
    required this.onBack,
  });

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final iconSize = Responsive.w(context, 31.996);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        Responsive.w(context, 24),
        Responsive.w(context, 26),
        Responsive.w(context, 24),
        Responsive.w(context, 16),
      ),
      child: SizedBox(
        height: iconSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              children: [
                _BackButton(size: iconSize, onBack: onBack),
                const Spacer(),
                const CreditsBadgeButton(compact: true),
                SizedBox(width: Responsive.w(context, 8)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.w(context, 8),
                    vertical: Responsive.w(context, 4),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.createSuccessBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: Responsive.w(context, 5.982),
                        height: Responsive.w(context, 5.982),
                        decoration: const BoxDecoration(
                          color: AppColors.createSuccess,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: Responsive.w(context, 6)),
                      Text(
                        'Ready',
                        maxLines: 1,
                        style: AppTextStyles.createReadyBadge(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 110)),
              child: Text(
                'Build Your App',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.createHeaderTitle(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
