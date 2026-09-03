import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FigmaSvgIcon extends StatelessWidget {
  const FigmaSvgIcon({
    super.key,
    required this.asset,
    required this.size,
    this.color,
    this.tinted = false,
  });

  final String asset;
  final double size;
  final Color? color;

  /// When true, strokes are normalized to black so [color] can tint them.
  final bool tinted;

  static final Map<String, String> _svgCache = {};

  /// Warm the SVG cache so first paint can show icon + chrome together.
  static Future<void> preload(String asset, {bool tinted = false}) async {
    if (_svgCache.containsKey(asset)) return;
    final raw = await rootBundle.loadString(asset);
    _svgCache[asset] = _sanitizeSvg(raw, tinted: tinted);
  }

  /// Returns cached SVG when available (after [preload] / prior paint).
  static String? cached(String asset) => _svgCache[asset];

  static String _sanitizeSvg(String svg, {required bool tinted}) {
    var result = svg
        .replaceAllMapped(
          RegExp(r'stroke="var\(--stroke-0,\s*([^)]+)\)"'),
          (match) => 'stroke="${match.group(1)!.trim()}"',
        )
        .replaceAllMapped(
          RegExp(r'fill="var\(--fill-0,\s*([^)]+)\)"'),
          (match) => 'fill="${match.group(1)!.trim()}"',
        )
        .replaceAllMapped(
          RegExp(r'fill=(#[0-9A-Fa-f]{3,8})'),
          (match) => 'fill="${match.group(1)}"',
        );

    if (tinted) {
      result = result.replaceAll(
        RegExp(r'stroke="#[0-9A-Fa-f]{3,8}"'),
        'stroke="#000000"',
      );
    }

    return result;
  }

  Future<String> _loadSvg(BuildContext context) async {
    if (_svgCache.containsKey(asset)) {
      return _svgCache[asset]!;
    }

    final raw = await rootBundle.loadString(asset);
    final sanitized = _sanitizeSvg(raw, tinted: tinted);
    _svgCache[asset] = sanitized;
    return sanitized;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _loadSvg(context),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(width: size, height: size);
        }

        return SvgPicture.string(
          snapshot.data!,
          width: size,
          height: size,
          fit: BoxFit.contain,
          colorFilter: color == null
              ? null
              : ColorFilter.mode(color!, BlendMode.srcIn),
        );
      },
    );
  }
}
