import 'package:flutter/material.dart';

/// Figma loading dots for splash preview — custom painted.
class CreateLoadingDots extends StatelessWidget {
  const CreateLoadingDots({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Dot(opacity: 0.97, size: 7.67),
        SizedBox(width: 4),
        _Dot(opacity: 0.83, size: 6.77),
        SizedBox(width: 4),
        _Dot(opacity: 0.71, size: 6.13),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.opacity, required this.size});

  final double opacity;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}
