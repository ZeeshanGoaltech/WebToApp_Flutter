import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web_to_app/core/constants/app_assets.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/widgets/figma_svg_icon.dart';

/// Close control sized to match the main IAP paywall (Figma 28 / icon 20, scaled).
///
/// Circle background and X icon always appear together — never an empty disc
/// while the SVG is still loading.
class IapCloseButton extends StatelessWidget {
  const IapCloseButton({
    super.key,
    required this.onTap,
    this.scale,
  });

  final VoidCallback onTap;

  /// When null, uses [scaleOf]. Pass `1` inside the IAP [FittedBox] canvas.
  final double? scale;

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
    final s = scale ?? scaleOf(context);
    final size = designSize * s;
    final iconSize = designIconSize * s;
    final cached = FigmaSvgIcon.cached(AppAssets.iapCloseIcon);

    if (cached != null) {
      return _CloseChrome(
        onTap: onTap,
        size: size,
        iconSize: iconSize,
        svg: cached,
      );
    }

    return FutureBuilder<void>(
      future: FigmaSvgIcon.preload(AppAssets.iapCloseIcon),
      builder: (context, snapshot) {
        final svg = FigmaSvgIcon.cached(AppAssets.iapCloseIcon);
        if (svg == null) return const SizedBox.shrink();
        return _CloseChrome(
          onTap: onTap,
          size: size,
          iconSize: iconSize,
          svg: svg,
        );
      },
    );
  }
}

class _CloseChrome extends StatelessWidget {
  const _CloseChrome({
    required this.onTap,
    required this.size,
    required this.iconSize,
    required this.svg,
  });

  final VoidCallback onTap;
  final double size;
  final double iconSize;
  final String svg;

  @override
  Widget build(BuildContext context) {
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
          child: SvgPicture.string(
            svg,
            width: iconSize,
            height: iconSize,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
