import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/constants/app_assets.dart';

/// Exit-intent sheet for free users — Stay opens the lifetime paywall.
class ExitLifetimeSheet extends StatelessWidget {
  const ExitLifetimeSheet({super.key});

  static const _bg = Color(0xFFFBF6F2);
  static const _heading = Color(0xFF301B0A);
  static const _eyebrow = Color(0xFF8C6963);
  static const _subtitle = Color(0xFF8C6963);
  static const _peach = Color(0xFFFDEBDD);
  static const _primary = Color(0xFFF35D89);
  static const _exitBg = Color(0x0D866E6C);
  static const _exitText = Color(0xFF182033);
  static const _cardBg = Color(0xFFFFFBF8);
  static const _cardBorder = Color(0xFFD3C2B4);
  static const _sheetBorder = Color(0xFFD3C2B4);
  static const _handle = Color(0x66D3C2B4);

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final horizontalPadding = media.size.width < 360 ? 16.0 : 24.0;

    return Container(
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        border: Border(
          top: BorderSide(color: _sheetBorder, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 56,
            offset: Offset(0, -13),
            spreadRadius: -13,
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(horizontalPadding, 14, horizontalPadding, 28),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 6,
                decoration: BoxDecoration(
                  color: _handle,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'exit_before_you_go'.tr,
              style: const TextStyle(
                color: _eyebrow,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'exit_never_lose_a_thought'.tr,
              style: const TextStyle(
                color: _heading,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Material(
              color: _cardBg,
              elevation: 3,
              shadowColor: const Color(0x1A000000),
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                onTap: () => Navigator.of(context).pop('stay'),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _cardBorder, width: 1.5),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 16, 10, 16),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: _peach,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          AppAssets.exitCrown,
                          width: 24,
                          height: 24,
                          fit: BoxFit.contain,
                          placeholderBuilder: (_) => const Icon(
                            Icons.workspace_premium_rounded,
                            color: _heading,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'exit_lifetime_card_title'.tr,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: _heading,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'exit_lifetime_card_subtitle'.tr,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: _subtitle,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 90,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _peach,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'exit_one_time_payment'.tr,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _heading,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop('exit'),
                      style: TextButton.styleFrom(
                        backgroundColor: _exitBg,
                        foregroundColor: _exitText,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'exit_sheet_exit'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop('stay'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: const Color(0x1A000000),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'exit_sheet_stay'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
