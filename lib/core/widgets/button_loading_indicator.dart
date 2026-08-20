import 'package:flutter/material.dart';
import 'package:web_to_app/core/utils/responsive.dart';

class ButtonLoadingIndicator extends StatelessWidget {
  const ButtonLoadingIndicator({
    super.key,
    this.color = Colors.white,
    this.size = 22,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final dimension = Responsive.w(context, size);
    return SizedBox(
      width: dimension,
      height: dimension,
      child: CircularProgressIndicator(
        strokeWidth: Responsive.w(context, 2),
        color: color,
      ),
    );
  }
}
