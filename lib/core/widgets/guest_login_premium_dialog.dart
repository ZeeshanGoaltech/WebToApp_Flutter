import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/utils/responsive.dart';

/// Premium-style prompt that asks guests to sign in before generating an APK.
Future<bool> showGuestLoginPremiumDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (_) => const _GuestLoginPremiumDialog(),
  );
  return result == true;
}

class _GuestLoginPremiumDialog extends StatelessWidget {
  const _GuestLoginPremiumDialog();

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
                      Icons.lock_open_rounded,
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
                      fontSize: Responsive.w(context, 22),
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: Responsive.w(context, 10)),
                  Text(
                    'guest_login_dialog_subtitle'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _body,
                      fontSize: Responsive.w(context, 14),
                      fontWeight: FontWeight.w500,
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: Responsive.w(context, 18)),
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
                          icon: Icons.folder_special_rounded,
                          text: 'guest_login_benefit_projects'.tr,
                        ),
                        SizedBox(height: Responsive.w(context, 12)),
                        _BenefitRow(
                          icon: Icons.cloud_done_rounded,
                          text: 'guest_login_benefit_sync'.tr,
                        ),
                        SizedBox(height: Responsive.w(context, 12)),
                        _BenefitRow(
                          icon: Icons.android_rounded,
                          text: 'guest_login_benefit_apk'.tr,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.w(context, 20)),
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
                          onTap: () => Navigator.of(context).pop(true),
                          child: Center(
                            child: Text(
                              'guest_login_dialog_cta'.tr,
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
                  SizedBox(height: Responsive.w(context, 10)),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'guest_login_dialog_later'.tr,
                      style: TextStyle(
                        color: _body,
                        fontSize: Responsive.w(context, 14),
                        fontWeight: FontWeight.w600,
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
                  onTap: () => Navigator.of(context).pop(false),
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
            color: _GuestLoginPremiumDialog._iconBg,
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
                color: _GuestLoginPremiumDialog._heading,
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
