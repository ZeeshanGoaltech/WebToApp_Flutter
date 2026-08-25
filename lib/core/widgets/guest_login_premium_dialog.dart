import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/utils/responsive.dart';

enum GuestLoginGuideAction {
  /// Continue as guest (create / generate APK).
  continueAsGuest,

  /// Optional: open login / signup.
  login,
}

/// Soft guide only — login is optional. Guests can always continue.
Future<GuestLoginGuideAction> showGuestLoginGuideDialog(
  BuildContext context,
) async {
  final result = await showDialog<GuestLoginGuideAction>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (_) => const _GuestLoginGuideDialog(),
  );
  // Dismiss / close = continue without login.
  return result ?? GuestLoginGuideAction.continueAsGuest;
}

class _GuestLoginGuideDialog extends StatelessWidget {
  const _GuestLoginGuideDialog();

  static const _heading = Color(0xFF101828);
  static const _body = Color(0xFF6A7282);
  static const _cardBorder = Color(0xFFF3F4F6);
  static const _iconBg = Color(0xFFEEEEFC);

  @override
  Widget build(BuildContext context) {
    final radius = Responsive.w(context, 28);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: Responsive.w(context, 24),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: Responsive.w(context, 28),
              offset: Offset(0, Responsive.w(context, 12)),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                Responsive.w(context, 22),
                Responsive.w(context, 28),
                Responsive.w(context, 22),
                Responsive.w(context, 22),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: Responsive.w(context, 72),
                    height: Responsive.w(context, 72),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF766EFF),
                          Color(0xFF6C63FF),
                          Color(0xFF857EFF),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(
                        Responsive.w(context, 22),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.homeAccent.withValues(alpha: 0.35),
                          blurRadius: Responsive.w(context, 18),
                          offset: Offset(0, Responsive.w(context, 8)),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.cloud_done_rounded,
                      color: Colors.white,
                      size: Responsive.w(context, 34),
                    ),
                  ),
                  SizedBox(height: Responsive.w(context, 18)),
                  Text(
                    'guest_login_dialog_title'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _heading,
                      fontSize: Responsive.w(context, 21),
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: Responsive.w(context, 12)),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.w(context, 14),
                      vertical: Responsive.w(context, 12),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.homeAccentLight,
                      borderRadius: BorderRadius.circular(
                        Responsive.w(context, 14),
                      ),
                      border: Border.all(
                        color: AppColors.homeAccent.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Text(
                      'guest_login_dialog_highlight'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.homeAccent,
                        fontSize: Responsive.w(context, 14),
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.w(context, 12)),
                  Text(
                    'guest_login_dialog_subtitle'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _body,
                      fontSize: Responsive.w(context, 13.5),
                      fontWeight: FontWeight.w500,
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: Responsive.w(context, 16)),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(Responsive.w(context, 14)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        Responsive.w(context, 18),
                      ),
                      border: Border.all(color: _cardBorder, width: 1.5),
                    ),
                    child: Column(
                      children: [
                        _BenefitRow(
                          icon: Icons.phonelink_erase_rounded,
                          text: 'guest_login_benefit_projects'.tr,
                        ),
                        SizedBox(height: Responsive.w(context, 12)),
                        _BenefitRow(
                          icon: Icons.lock_clock_rounded,
                          text: 'guest_login_benefit_sync'.tr,
                        ),
                        SizedBox(height: Responsive.w(context, 12)),
                        _BenefitRow(
                          icon: Icons.devices_rounded,
                          text: 'guest_login_benefit_apk'.tr,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.w(context, 20)),
                  // Primary: continue without forcing login
                  SizedBox(
                    width: double.infinity,
                    height: Responsive.w(context, 52),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF726AFF),
                            Color(0xFF6C63FF),
                            Color(0xFF8881FF),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                          Responsive.w(context, 16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.homeAccent.withValues(alpha: 0.28),
                            blurRadius: Responsive.w(context, 14),
                            offset: Offset(0, Responsive.w(context, 6)),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(
                            Responsive.w(context, 16),
                          ),
                          onTap: () => Navigator.of(context).pop(
                            GuestLoginGuideAction.continueAsGuest,
                          ),
                          child: Center(
                            child: Text(
                              'guest_login_dialog_continue'.tr,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: Responsive.w(context, 16),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.w(context, 8)),
                  // Optional login
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(
                      GuestLoginGuideAction.login,
                    ),
                    child: Text(
                      'guest_login_dialog_cta'.tr,
                      style: TextStyle(
                        color: AppColors.homeAccent,
                        fontSize: Responsive.w(context, 14),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.w(context, 8),
                    ),
                    child: Text(
                      'guest_login_dialog_later_hint'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _body,
                        fontSize: Responsive.w(context, 12),
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: Responsive.w(context, 10),
              right: Responsive.w(context, 10),
              child: Material(
                color: _iconBg,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.of(context).pop(
                    GuestLoginGuideAction.continueAsGuest,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(Responsive.w(context, 8)),
                    child: Icon(
                      Icons.close_rounded,
                      size: Responsive.w(context, 18),
                      color: _body,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: Responsive.w(context, 36),
          height: Responsive.w(context, 36),
          decoration: BoxDecoration(
            color: _GuestLoginGuideDialog._iconBg,
            borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
          ),
          child: Icon(
            icon,
            color: AppColors.homeAccent,
            size: Responsive.w(context, 18),
          ),
        ),
        SizedBox(width: Responsive.w(context, 12)),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: Responsive.w(context, 6)),
            child: Text(
              text,
              style: TextStyle(
                color: _GuestLoginGuideDialog._heading,
                fontSize: Responsive.w(context, 13.5),
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
