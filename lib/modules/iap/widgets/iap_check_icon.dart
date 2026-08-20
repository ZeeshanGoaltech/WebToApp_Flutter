import 'package:flutter/material.dart';
import 'package:web_to_app/core/theme/app_colors.dart';

/// Figma checkmark icon (node 96:361) drawn in code to avoid asset codec issues.
class IapCheckIcon extends StatelessWidget {
  const IapCheckIcon({
    super.key,
    required this.size,
    this.color = AppColors.iapCheck,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _IapCheckPainter(color: color),
    );
  }
}

class _IapCheckPainter extends CustomPainter {
  _IapCheckPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 17.3337;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.16671 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(2.88903 * scale, 8.66657 * scale)
      ..lineTo(6.50021 * scale, 12.2778 * scale)
      ..lineTo(14.4448 * scale, 4.33315 * scale);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _IapCheckPainter oldDelegate) =>
      oldDelegate.color != color;

}
