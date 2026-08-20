import 'package:flutter/material.dart';
import 'package:web_to_app/core/constants/create_app_assets.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';
import 'package:web_to_app/core/widgets/figma_svg_icon.dart';
import 'package:web_to_app/modules/create_app/widgets/fields/create_picked_image.dart';

class CreateUploadZone extends StatelessWidget {
  const CreateUploadZone({
    super.key,
    required this.label,
    required this.onTap,
    this.dashed = true,
  });

  final String label;
  final VoidCallback onTap;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    final height = Responsive.w(context, 55.997);
    final radius = Responsive.w(context, 14);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: CustomPaint(
          painter: dashed
              ? _DashedBorderPainter(
                  color: AppColors.createAccent.withValues(alpha: 0.4),
                  radius: radius,
                )
              : null,
          child: Container(
            height: height,
            width: double.infinity,
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FigmaSvgIcon(
                  asset: CreateAppAssets.upload,
                  size: Responsive.w(context, 19.995),
                ),
                SizedBox(width: Responsive.w(context, 8)),
                Text(label, style: AppTextStyles.createLink(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CreateImagePreview extends StatelessWidget {
  const CreateImagePreview({
    super.key,
    required this.imagePath,
    required this.onRemove,
    this.height,
    this.fit = BoxFit.contain,
  });

  final String imagePath;
  final VoidCallback onRemove;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final h = height ?? Responsive.w(context, 95.988);
    final radius = Responsive.w(context, 14);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: h,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: AppColors.createAccent.withValues(alpha: 0.4),
              width: 1.16,
            ),
            color: AppColors.createFieldBg,
          ),
          clipBehavior: Clip.antiAlias,
          child: CreatePickedImage(
            imagePath: imagePath,
            fit: fit,
            width: double.infinity,
            height: h,
          ),
        ),
        Positioned(
          right: Responsive.w(context, 8),
          top: Responsive.w(context, 8),
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: Responsive.w(context, 23.983),
              height: Responsive.w(context, 23.983),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: Responsive.w(context, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '✕',
                  style: TextStyle(
                    color: AppColors.createDelete,
                    fontWeight: FontWeight.bold,
                    fontSize: Responsive.sp(context, 12),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.16;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    canvas.drawPath(
      path,
      paint..shader = null,
    );
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) => false;
}
