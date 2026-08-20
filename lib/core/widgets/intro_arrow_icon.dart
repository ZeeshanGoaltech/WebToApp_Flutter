import 'package:flutter/material.dart';
import 'package:web_to_app/core/widgets/rtl_flip.dart';

/// Figma arrow icon (node 17:4075) — white chevron stroke, viewBox 30.4892.
class IntroArrowIcon extends StatelessWidget {
  const IntroArrowIcon({
    super.key,
    required this.size,
    this.color = Colors.white,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return RtlFlip(
      child: CustomPaint(
        size: Size(size, size),
        painter: _IntroArrowPainter(color: color),
      ),
    );
  }
}

class _IntroArrowPainter extends CustomPainter {
  _IntroArrowPainter({required this.color});

  final Color color;

  static const double _viewBox = 30.4892;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _viewBox;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.54077 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(11.4334 * scale, 22.867 * scale)
      ..lineTo(19.0558 * scale, 15.2447 * scale)
      ..lineTo(11.4334 * scale, 7.62243 * scale);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _IntroArrowPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
