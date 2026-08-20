import 'package:flutter/material.dart';
import 'package:web_to_app/core/theme/app_colors.dart';

/// Figma eye icon (node 2:74) — purple stroke visibility toggle.
class AuthEyeIcon extends StatelessWidget {
  const AuthEyeIcon({
    super.key,
    required this.size,
    this.color = AppColors.authAccent,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _AuthEyePainter(color: color),
    );
  }
}

class _AuthEyePainter extends CustomPainter {
  _AuthEyePainter({required this.color});

  final Color color;

  static const double _viewBox = 22.8785;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _viewBox;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.90654 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final center = Offset(11.4394 * scale, 11.4395 * scale);
    final outerRect = Rect.fromCenter(
      center: center,
      width: 19.0 * scale,
      height: 13.35 * scale,
    );
    canvas.drawOval(outerRect, paint);
    canvas.drawCircle(center, 2.85984 * scale, paint);
  }

  @override
  bool shouldRepaint(covariant _AuthEyePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
