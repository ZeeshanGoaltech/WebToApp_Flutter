import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/app/routes/app_routes.dart';
import 'package:web_to_app/core/constants/app_assets.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/utils/responsive.dart';

/// Compact bottom toast with the app icon.
class AppToast {
  AppToast._();

  static const Color _bg = Color(0xE81A1A2E);
  static const Color _textDefault = Color(0xFFFFFFFF);
  static const Color _textSuccess = Color(0xFF86EFAC);
  static const Color _textError = Color(0xFFFCA5A5);

  static OverlayEntry? _entry;
  static Timer? _hideTimer;

  static Future<void> success(String message, {String? description}) =>
      _show(_line(message, description), _textSuccess);

  static Future<void> error(String message, {String? description}) =>
      _show(_line(message, description), _textError);

  static Future<void> info(String message, {String? description}) =>
      _show(_line(message, description), _textDefault);

  static String _line(String message, String? description) {
    final title = message.trim();
    final sub = description?.trim();
    if (title.isEmpty) return sub ?? '';
    if (sub == null || sub.isEmpty) return title;
    return '$title\n$sub';
  }

  static void _dismiss() {
    _hideTimer?.cancel();
    _hideTimer = null;
    _entry?.remove();
    _entry = null;
  }

  static Future<void> _show(String text, Color textColor) async {
    if (text.isEmpty) return;

    _dismiss();

    final overlay = Get.key.currentState?.overlay;
    if (overlay == null || !overlay.mounted) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) {
        final bottomGap = _bottomGap(ctx);
        final hPad = Responsive.w(ctx, 24);

        return Positioned(
          left: hPad,
          right: hPad,
          bottom: bottomGap,
          child: IgnorePointer(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _ToastChip(message: text, textColor: textColor),
            ),
          ),
        );
      },
    );

    _entry = entry;
    overlay.insert(entry);

    _hideTimer = Timer(const Duration(seconds: 2), () {
      if (identical(_entry, entry)) {
        entry.remove();
        _entry = null;
        _hideTimer = null;
      }
    });
  }

  static double _bottomGap(BuildContext context) {
    final safe = MediaQuery.paddingOf(context).bottom;
    final onHome = Get.currentRoute == AppRoutes.home;
    final nav = onHome ? Responsive.w(context, 88) : 0;
    return safe + nav + Responsive.w(context, 16);
  }
}

class _ToastChip extends StatelessWidget {
  const _ToastChip({
    required this.message,
    required this.textColor,
  });

  final String message;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final maxW = MediaQuery.sizeOf(context).width - Responsive.w(context, 72);
    final radius = Responsive.w(context, 14);
    final iconSize = Responsive.w(context, 22);

    return Material(
      color: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW > 0 ? maxW : 280),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(context, 12),
            vertical: Responsive.w(context, 10),
          ),
          decoration: BoxDecoration(
            color: AppToast._bg,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: Responsive.w(context, 18),
                offset: Offset(0, Responsive.w(context, 8)),
              ),
              BoxShadow(
                color: AppColors.homeAccent.withValues(alpha: 0.12),
                blurRadius: Responsive.w(context, 12),
                offset: Offset(0, Responsive.w(context, 4)),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ToastAppIcon(size: iconSize),
              SizedBox(width: Responsive.w(context, 10)),
              Flexible(
                child: Text(
                  message,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: Responsive.sp(context, 13),
                    height: 1.25,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToastAppIcon extends StatelessWidget {
  const _ToastAppIcon({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final radius = Responsive.w(context, 6);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        AppAssets.appIcon,
        width: size,
        height: size,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) => Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.homeCardGradientStart,
                AppColors.homeCardGradientEnd,
              ],
            ),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Icon(
            Icons.apps_rounded,
            size: size * 0.55,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
