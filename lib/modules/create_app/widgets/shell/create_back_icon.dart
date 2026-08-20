import 'package:flutter/material.dart';
import 'package:web_to_app/core/constants/create_app_assets.dart';
import 'package:web_to_app/core/widgets/figma_svg_icon.dart';
import 'package:web_to_app/core/widgets/rtl_flip.dart';

/// Figma header back arrow (chevron + shaft).
class CreateBackIcon extends StatelessWidget {
  const CreateBackIcon({
    super.key,
    required this.size,
    this.color = const Color(0xFF1A1A2E),
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return RtlFlip(
      child: FigmaSvgIcon(
        asset: CreateAppAssets.backArrow,
        size: size,
        color: color,
        tinted: true,
      ),
    );
  }
}
