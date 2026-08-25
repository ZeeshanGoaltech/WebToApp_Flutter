import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_to_app/app/routes/app_routes.dart';
import 'package:web_to_app/core/services/credit_service.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/utils/responsive.dart';

/// Shows remaining free/pack credits; opens the credits pack screen on tap.
class CreditsBadgeButton extends StatelessWidget {
  const CreditsBadgeButton({super.key, this.compact = false});

  final bool compact;

  Future<void> _openPack() async {
    await Get.toNamed(AppRoutes.creditsPack);
  }

  @override
  Widget build(BuildContext context) {
    final credits = CreditService.instance;

    return ValueListenableBuilder<int>(
      valueListenable: credits.stateVersion,
      builder: (context, _, __) {
        final label = credits.displayLabel;
        final exhausted = credits.isExhausted;

        final bgColor =
            exhausted ? AppColors.homeFailedBg : const Color(0xFFEEEEFC);
        final borderColor =
            exhausted ? const Color(0xFFFECACA) : const Color(0xFFD8D7F5);
        final accentColor =
            exhausted ? AppColors.homeFailed : const Color(0xFF6A69D3);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _openPack,
            borderRadius: BorderRadius.circular(999),
            child: Ink(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(context, compact ? 10 : 12),
                vertical: Responsive.w(context, compact ? 6 : 8),
              ),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bolt_rounded,
                    size: Responsive.w(context, compact ? 16 : 18),
                    color: accentColor,
                  ),
                  SizedBox(width: Responsive.w(context, 4)),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      color: accentColor,
                      fontSize: Responsive.sp(context, compact ? 13 : 14),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
