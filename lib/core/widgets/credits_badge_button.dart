import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_to_app/app/routes/app_routes.dart';
import 'package:web_to_app/core/services/credit_service.dart';
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
        final remaining = credits.remaining;

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
                color: const Color(0xFFEEEEFC),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFD8D7F5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bolt_rounded,
                    size: Responsive.w(context, compact ? 16 : 18),
                    color: const Color(0xFF6A69D3),
                  ),
                  SizedBox(width: Responsive.w(context, 4)),
                  Text(
                    '$remaining',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF6A69D3),
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
