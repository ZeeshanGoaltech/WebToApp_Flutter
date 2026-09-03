import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/utils/responsive.dart';

/// Compact "Loading ad" card (used by [showDialog] and [AdLoadingOverlay]).
class AdLoadingDialog extends StatelessWidget {
  const AdLoadingDialog({super.key, this.message});

  /// Optional override; defaults to translated [loading_ad].
  final String? message;

  @override
  Widget build(BuildContext context) {
    final radius = Responsive.w(context, 16);
    final padH = Responsive.w(context, 22);
    final padV = Responsive.w(context, 18);
    final spinner = Responsive.w(context, 22);
    final maxWidth = Responsive.w(context, 220);

    return Material(
      color: Colors.white,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(radius),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: spinner,
                height: spinner,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  strokeCap: StrokeCap.round,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                ),
              ),
              SizedBox(height: Responsive.w(context, 12)),
              Text(
                message ?? 'loading_ad'.tr,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: const Color(0xFF5A6472),
                  fontSize: Responsive.sp(context, 13),
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
