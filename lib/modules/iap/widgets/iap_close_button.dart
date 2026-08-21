import 'package:flutter/material.dart';
import 'package:web_to_app/core/constants/app_assets.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/widgets/figma_svg_icon.dart';

/// Close control sized to match the main IAP paywall (Figma 28 / icon 20, scaled).
class IapCloseButton extends StatelessWidget {
  const IapCloseButton({super.key, required this.onTap});

  final VoidCallback onTap;

  /// Same design frame as [IapView].
  static const double designW = 456;
  static const double designH = 996;
  static const double designSize = 28;
  static const double designIconSize = 20;
  static const double designTop = 19;
  static const double designLeft = 11;

  /// Scale used by the main IAP canvas so other paywalls match visually.
  static double scaleOf(BuildContext context) {
    final mq = MediaQuery.of(context);
    final availH = mq.size.height - mq.padding.top - mq.padding.bottom;
    final sx = mq.size.width / designW;
    final sy = availH / designH;
    return sx < sy ? sx : sy;
  }

  @override
  Widget build(BuildContext context) {
    final scale = scaleOf(context);
    final size = designSize * scale;
    final iconSize = designIconSize * scale;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: AppColors.iapCloseBg,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: FigmaSvgIcon(
            asset: AppAssets.iapCloseIcon,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}
