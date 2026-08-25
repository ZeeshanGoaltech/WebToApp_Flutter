import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/utils/responsive.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle splashTitle(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w700,
      fontSize: Responsive.sp(context, 36),
      height: 40 / 36,
      letterSpacing: -0.9,
      color: AppColors.title,
    );
  }

  static TextStyle splashSubtitle(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w400,
      fontSize: Responsive.sp(context, 16),
      height: 24 / 16,
      color: AppColors.subtitle,
    );
  }

  static TextStyle splashStatus(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w400,
      fontSize: Responsive.sp(context, 12),
      height: 16 / 12,
      color: AppColors.subtitle,
    );
  }

  static TextStyle languageTitle(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w700,
      fontSize: Responsive.sp(context, 24),
      height: 30 / 24,
      color: AppColors.title,
    );
  }

  static TextStyle languageSubtitle(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w400,
      fontSize: Responsive.sp(context, 14),
      height: 20 / 14,
      color: AppColors.subtitle,
    );
  }

  static TextStyle languageItemName(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w700,
      fontSize: Responsive.sp(context, 14.983),
      height: 18.729 / 14.983,
      color: AppColors.title,
    );
  }

  static TextStyle languageItemCountry(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w500,
      fontSize: Responsive.sp(context, 12.843),
      height: 17.124 / 12.843,
      color: AppColors.subtitle,
    );
  }

  static TextStyle primaryButton(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      fontSize: Responsive.sp(context, 14.25),
      height: 22.167 / 14.25,
      color: Colors.white,
    );
  }

  static TextStyle introSkip(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w500,
      fontSize: Responsive.sp(context, 15.82),
      height: 23.73 / 15.82,
      color: AppColors.introBody,
    );
  }

  static TextStyle introTitle(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w700,
      fontSize: Responsive.sp(context, 29.38),
      height: 36.725 / 29.38,
      color: AppColors.introTitle,
    );
  }

  static TextStyle introBody(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w400,
      fontSize: Responsive.sp(context, 15.82),
      height: 26.103 / 15.82,
      color: AppColors.introBody,
    );
  }

  static TextStyle homeHeaderTitle(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w700,
      fontSize: Responsive.sp(context, 27.724),
      height: 34.654 / 27.724,
      letterSpacing: -0.3249,
      color: AppColors.homeTitle,
    );
  }

  static TextStyle homeCardBadge(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      fontSize: Responsive.sp(context, 11),
      height: 16.5 / 11,
      letterSpacing: 0.3395,
      color: Colors.white.withValues(alpha: 0.7),
    );
  }

  static TextStyle homeCardTitle(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w700,
      fontSize: Responsive.sp(context, 24),
      height: 30 / 24,
      letterSpacing: 0.0703,
      color: Colors.white,
    );
  }

  static TextStyle homeCardSubtitle(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w500,
      fontSize: Responsive.sp(context, 13),
      height: 19.5 / 13,
      letterSpacing: -0.0762,
      color: Colors.white.withValues(alpha: 0.7),
    );
  }

  static TextStyle homeCardButton(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      fontSize: Responsive.sp(context, 13),
      height: 19.5 / 13,
      letterSpacing: -0.0762,
      color: Colors.white.withValues(alpha: 0.9),
    );
  }

  static TextStyle homeSectionTitle(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      fontSize: Responsive.sp(context, 15),
      height: 22.5 / 15,
      letterSpacing: -0.2344,
      color: AppColors.homeTitle,
    );
  }

  static TextStyle homeSectionBadge(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      fontSize: Responsive.sp(context, 11),
      height: 16.5 / 11,
      letterSpacing: 0.0645,
      color: AppColors.homeAccent,
    );
  }

  static TextStyle homeSeeAll(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w500,
      fontSize: Responsive.sp(context, 12),
      height: 18 / 12,
      color: AppColors.homeAccent,
    );
  }

  static TextStyle homeAppName(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      fontSize: Responsive.sp(context, 14),
      height: 21 / 14,
      letterSpacing: -0.1504,
      color: AppColors.homeTitle,
    );
  }

  static TextStyle homeAppUrl(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w500,
      fontSize: Responsive.sp(context, 11),
      height: 16.5 / 11,
      letterSpacing: 0.0645,
      color: AppColors.homeMuted,
    );
  }

  static TextStyle homeStatusBadge(BuildContext context, Color color) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      fontSize: Responsive.sp(context, 11),
      height: 16.5 / 11,
      letterSpacing: 0.0645,
      color: color,
    );
  }

  static TextStyle homeAppInitial(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w700,
      fontSize: Responsive.sp(context, 15),
      height: 22.5 / 15,
      letterSpacing: -0.2344,
      color: Colors.white,
    );
  }

  static TextStyle homeNavLabel(BuildContext context, {required bool active}) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      fontSize: Responsive.sp(context, 14),
      height: 18 / 14,
      letterSpacing: 0.1283,
      color: active ? AppColors.homeAccent : AppColors.homeMuted,
    );
  }

  static TextStyle authTitle(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w700,
      fontSize: Responsive.sp(context, 30),
      height: 36 / 30,
      color: AppColors.authTitle,
    );
  }

  static TextStyle authSubtitle(BuildContext context, {double size = 16}) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w400,
      fontSize: Responsive.sp(context, size),
      height: 24 / 16,
      color: AppColors.authBody,
    );
  }

  static TextStyle authTabActive(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w500,
      fontSize: Responsive.sp(context, 17.163),
      height: 25.745 / 17.163,
      letterSpacing: -0.2682,
      color: AppColors.authTitle,
    );
  }

  static TextStyle authTabInactive(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w500,
      fontSize: Responsive.sp(context, 17.163),
      height: 25.745 / 17.163,
      letterSpacing: -0.2682,
      color: AppColors.authBody,
    );
  }

  static TextStyle authLabel(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w700,
      fontSize: Responsive.sp(context, 14),
      height: 20 / 14,
      color: AppColors.authLabel,
    );
  }

  static TextStyle authField(BuildContext context, {double size = 16}) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w400,
      fontSize: Responsive.sp(context, size),
      height: 1.2,
      color: AppColors.authTitle,
    );
  }

  static TextStyle authFieldHint(BuildContext context, {double size = 16}) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w400,
      fontSize: Responsive.sp(context, size),
      height: 1.2,
      color: AppColors.authPlaceholder,
    );
  }

  static TextStyle authLink(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      fontSize: Responsive.sp(context, 14),
      height: 20 / 14,
      color: AppColors.authForgot,
    );
  }

  static TextStyle authFooter(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w400,
      fontSize: Responsive.sp(context, 16),
      height: 24 / 16,
      color: AppColors.authFooter,
    );
  }

  static TextStyle authFooterLink(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w700,
      fontSize: Responsive.sp(context, 16),
      height: 24 / 16,
      color: AppColors.authAccent,
    );
  }

  static TextStyle authDivider(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w400,
      fontSize: Responsive.sp(context, 13.73),
      height: 20.596 / 13.73,
      color: AppColors.authPlaceholder,
    );
  }

  static TextStyle authGoogleBtn(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      fontSize: Responsive.sp(context, 17.163),
      height: 25.745 / 17.163,
      letterSpacing: -0.2682,
      color: AppColors.authTitle,
    );
  }

  static TextStyle authPrimaryBtn(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w700,
      fontSize: Responsive.sp(context, 16),
      height: 24 / 16,
      color: AppColors.authDisabledBtnText,
    );
  }

  static TextStyle authGuestBtn(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w700,
      fontSize: Responsive.sp(context, 16),
      height: 24 / 16,
      color: Colors.white,
    );
  }

  static TextStyle createHeaderTitle(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      fontSize: Responsive.sp(context, 20),
      height: 30 / 20,
      letterSpacing: -0.4492,
      color: AppColors.createTitle,
    );
  }

  static TextStyle createStepLabel(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w400,
      fontSize: Responsive.sp(context, 12),
      height: 18 / 12,
      color: AppColors.createMuted,
    );
  }

  static TextStyle createSectionTitle(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      fontSize: Responsive.sp(context, 16),
      height: 24 / 16,
      letterSpacing: -0.3125,
      color: AppColors.createTitle,
    );
  }

  static TextStyle createFieldLabel(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w500,
      fontSize: Responsive.sp(context, 11),
      height: 16.5 / 11,
      letterSpacing: 0.0645,
      color: AppColors.createMuted,
    );
  }

  static TextStyle createFieldValue(BuildContext context, {double size = 16}) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w400,
      fontSize: Responsive.sp(context, size),
      height: 24 / 16,
      letterSpacing: -0.3125,
      color: const Color(0xFF0A0A0A),
    );
  }

  static TextStyle createFieldHint(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w400,
      fontSize: Responsive.sp(context, 14),
      height: 24 / 14,
      letterSpacing: -0.3125,
      color: const Color(0x800A0A0A),
    );
  }

  static TextStyle createFieldError(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w500,
      fontSize: Responsive.sp(context, 12),
      height: 16 / 12,
      color: AppColors.createDelete,
    );
  }

  static TextStyle createPackageField(BuildContext context) {
    return GoogleFonts.robotoMono(
      fontWeight: FontWeight.w400,
      fontSize: Responsive.sp(context, 13),
      height: 19.5 / 13,
      color: const Color(0xFF0A0A0A),
    );
  }

  static TextStyle createCta(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      fontSize: Responsive.sp(context, 16),
      height: 24 / 16,
      letterSpacing: -0.3125,
      color: Colors.white,
    );
  }

  static TextStyle createOptionalBadge(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w500,
      fontSize: Responsive.sp(context, 10),
      height: 15 / 10,
      letterSpacing: 0.1172,
      color: AppColors.createAccent,
    );
  }

  static TextStyle createRowTitle(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      fontSize: Responsive.sp(context, 15),
      height: 22.5 / 15,
      letterSpacing: -0.2344,
      color: AppColors.createTitle,
    );
  }

  static TextStyle createRowSubtitle(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w400,
      fontSize: Responsive.sp(context, 12),
      height: 18 / 12,
      color: AppColors.createMuted,
    );
  }

  static TextStyle createLink(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w500,
      fontSize: Responsive.sp(context, 13),
      height: 19.5 / 13,
      letterSpacing: -0.0762,
      color: AppColors.createAccent,
    );
  }

  static TextStyle createPreviewMuted(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w400,
      fontSize: Responsive.sp(context, 13),
      height: 19.5 / 13,
      letterSpacing: -0.0762,
      color: AppColors.createPreviewMuted,
    );
  }

  static TextStyle createReadyBadge(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w500,
      fontSize: Responsive.sp(context, 11),
      height: 16.5 / 11,
      letterSpacing: 0.0645,
      color: AppColors.createSuccess,
    );
  }

  static TextStyle helpGuideHeaderTitle(BuildContext context) {
    return homeHeaderTitle(context);
  }

  static TextStyle helpGuideQuickBadge(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      fontSize: Responsive.sp(context, 11),
      height: 16.5 / 11,
      letterSpacing: 1.1645,
      color: Colors.white.withValues(alpha: 0.6),
    );
  }

  static TextStyle helpGuideQuickTitle(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w700,
      fontSize: Responsive.sp(context, 22),
      height: 30.25 / 22,
      letterSpacing: -0.2578,
      color: Colors.white,
    );
  }

  static TextStyle helpGuideQuickBody(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w400,
      fontSize: Responsive.sp(context, 13),
      height: 19.5 / 13,
      letterSpacing: -0.0762,
      color: Colors.white.withValues(alpha: 0.7),
    );
  }

  static TextStyle helpGuideQuickButton(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      fontSize: Responsive.sp(context, 13),
      height: 19.5 / 13,
      letterSpacing: -0.0762,
      color: Colors.white,
    );
  }

  static TextStyle helpGuideSectionTitle(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w700,
      fontSize: Responsive.sp(context, 15),
      height: 22.5 / 15,
      letterSpacing: -0.2344,
      color: AppColors.homeTitle,
    );
  }

  static TextStyle helpGuideStepBadge(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w700,
      fontSize: Responsive.sp(context, 10),
      height: 15 / 10,
      letterSpacing: 0.1172,
      color: Colors.white,
    );
  }

  static TextStyle helpGuideStepTitle(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      fontSize: Responsive.sp(context, 14),
      height: 21 / 14,
      letterSpacing: -0.1504,
      color: AppColors.homeTitle,
    );
  }

  static TextStyle helpGuideStepBody(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w400,
      fontSize: Responsive.sp(context, 12),
      height: 19.5 / 12,
      color: AppColors.introBody,
    );
  }

  static TextStyle settingsHeaderTitle(BuildContext context) {
    return homeHeaderTitle(context);
  }

  static TextStyle settingsSectionLabel(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w700,
      fontSize: Responsive.sp(context, 11.5),
      height: 17.472 / 11.5,
      letterSpacing: 1.233,
      color: AppColors.homeMuted,
    );
  }

  static TextStyle settingsPremiumBadge(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w700,
      fontSize: Responsive.sp(context, 10),
      height: 15.298 / 10,
      letterSpacing: 0.3745,
      color: Colors.white,
    );
  }

  static TextStyle settingsPremiumPrice(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w700,
      fontSize: Responsive.sp(context, 12),
      height: 18.358 / 12,
      color: Colors.white.withValues(alpha: 0.5),
    );
  }

  /// Settings premium card title (Figma 343:5) — "Upgrade to" portion.
  static TextStyle settingsPremiumTitle(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w800,
      fontSize: Responsive.sp(context, 25),
      height: 1.2,
      letterSpacing: -0.6573,
      color: AppColors.settingsPremiumTitle,
    );
  }

  static TextStyle settingsPremiumSubtitle(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w500,
      fontSize: Responsive.sp(context, 10.5),
      height: 1.0,
      color: AppColors.settingsPremiumSubtitle,
    );
  }

  static TextStyle settingsPremiumButton(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w700,
      fontSize: Responsive.sp(context, 14),
      height: 1.0,
      color: Colors.white,
    );
  }

  static TextStyle settingsProfileName(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w700,
      fontSize: Responsive.sp(context, 17),
      height: 25.413 / 17,
      letterSpacing: -0.3309,
      color: AppColors.homeTitle,
    );
  }

  static TextStyle settingsProfileEmail(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w400,
      fontSize: Responsive.sp(context, 12.5),
      height: 19.06 / 12.5,
      color: AppColors.homeMuted,
    );
  }

  static TextStyle settingsFreePlanBadge(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w700,
      fontSize: Responsive.sp(context, 10.5),
      height: 15.883 / 10.5,
      letterSpacing: 0.1241,
      color: AppColors.homeOrange,
    );
  }

  static TextStyle settingsAppsBuilt(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w400,
      fontSize: Responsive.sp(context, 10.5),
      height: 15.883 / 10.5,
      letterSpacing: 0.1241,
      color: AppColors.homeMuted,
    );
  }

  static TextStyle settingsRowTitle(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      fontSize: Responsive.sp(context, 14.5),
      height: 22.237 / 14.5,
      letterSpacing: -0.1592,
      color: AppColors.homeTitle,
    );
  }

  static TextStyle settingsRowSubtitle(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w500,
      fontSize: Responsive.sp(context, 11.5),
      height: 17.472 / 11.5,
      letterSpacing: 0.0682,
      color: AppColors.homeMuted,
    );
  }

  static TextStyle iapTitleUnlock(BuildContext context) {
    return GoogleFonts.roboto(
      fontWeight: FontWeight.w800,
      fontSize: Responsive.sp(context, 36),
      height: 62.031 / 36,
      color: AppColors.iapUnlockAccent,
    );
  }

  static TextStyle iapTitlePro(BuildContext context) {
    return GoogleFonts.roboto(
      fontWeight: FontWeight.w800,
      fontSize: Responsive.sp(context, 36),
      height: 62.031 / 36,
      color: AppColors.iapTitleDark,
    );
  }

  static TextStyle iapSubtitle(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w400,
      fontSize: Responsive.sp(context, 16),
      height: 27.219 / 16,
      color: AppColors.iapMuted,
    );
  }

  static TextStyle iapFeature(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w500,
      fontSize: Responsive.sp(context, 19),
      height: 22.785 / 19,
      letterSpacing: -0.2861,
      color: AppColors.iapTitleDark,
    );
  }

  static TextStyle iapTrialTitle(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      fontSize: Responsive.sp(context, 18.198),
      height: 25.878 / 18.198,
      letterSpacing: -0.337,
      color: Colors.white,
    );
  }

  static TextStyle iapTrialSubtitle(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w500,
      fontSize: Responsive.sp(context, 14.154),
      height: 25.878 / 14.154,
      letterSpacing: -0.337,
      color: Colors.white,
    );
  }

  static TextStyle iapPlanTitle(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      fontSize: Responsive.sp(context, 18.878),
      height: 28.317 / 18.878,
      letterSpacing: -0.3687,
      color: AppColors.iapTitleDark,
    );
  }

  static TextStyle iapPlanSubtitle(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w500,
      fontSize: Responsive.sp(context, 15.165),
      height: 28.317 / 15.165,
      letterSpacing: -0.3687,
      color: AppColors.iapMuted,
    );
  }

  static TextStyle iapPlanPrice(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w500,
      fontSize: Responsive.sp(context, 18.878),
      height: 20.22 / 18.878,
      letterSpacing: -0.3687,
      color: AppColors.iapTitleDark,
    );
  }

  static TextStyle iapPlanPriceLabel(BuildContext context) {
    return GoogleFonts.inter(
      fontWeight: FontWeight.w500,
      fontSize: Responsive.sp(context, 11.121),
      height: 20.22 / 11.121,
      letterSpacing: -0.3687,
      color: AppColors.iapMuted,
    );
  }

  static TextStyle iapFooter(BuildContext context) {
    return GoogleFonts.poppins(
      fontWeight: FontWeight.w500,
      fontSize: Responsive.sp(context, 12.132),
      height: 1.0,
      color: AppColors.iapFooter,
    );
  }
}
