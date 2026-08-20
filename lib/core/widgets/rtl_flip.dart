import 'package:flutter/material.dart';

/// Horizontally mirrors [child] when the ambient text direction is RTL.
class RtlFlip extends StatelessWidget {
  const RtlFlip({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (Directionality.of(context) != TextDirection.rtl) {
      return child;
    }
    return Transform.flip(flipX: true, child: child);
  }
}
