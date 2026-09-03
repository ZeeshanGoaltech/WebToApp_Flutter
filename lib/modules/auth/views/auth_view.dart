import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/constants/app_assets.dart';
import 'package:web_to_app/core/services/language_service.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';
import 'package:web_to_app/core/widgets/figma_svg_icon.dart';
import 'package:web_to_app/modules/auth/controllers/auth_controller.dart';
import 'package:web_to_app/modules/auth/widgets/auth_buttons.dart';
import 'package:web_to_app/modules/auth/widgets/auth_text_field.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    final hPad = Responsive.w(context, 24);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldClose = await controller.handleSystemBack();
        if (!shouldClose || !context.mounted) return;

        if (Get.key.currentState?.canPop() ?? false) {
          Get.back();
        } else {
          await SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.authBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: Responsive.w(context, 32)),
            child: Obx(() {
              // Rebuild translated strings when app language changes.
              final _ = Get.find<LanguageService>().selectedLanguageId.value;
              final isSignIn = controller.isSignIn;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: Responsive.h(context, isSignIn ? 39 : 46)),
                  _AuthHeader(isSignIn: isSignIn),
                  SizedBox(height: Responsive.h(context, isSignIn ? 40 : 39)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: hPad),
                    child: _AuthCard(isSignIn: isSignIn),
                  ),
                  SizedBox(height: Responsive.w(context, 27)),
                  _AuthFooter(isSignIn: isSignIn),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader({required this.isSignIn});

  final bool isSignIn;

  @override
  Widget build(BuildContext context) {
    final logoSize = Responsive.w(context, 95.988);
    final logoRadius = Responsive.w(context, 28);
    final iconSize = Responsive.w(context, 47.985);

    return Column(
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(logoRadius),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.authLogoStart,
                AppColors.authLogoEnd,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7F77FF).withValues(alpha: 0.25),
                blurRadius: Responsive.w(context, 50),
                offset: Offset(0, Responsive.w(context, 25)),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: FigmaSvgIcon(
            asset: AppAssets.authPhoneIcon,
            size: iconSize,
          ),
        ),
        SizedBox(height: Responsive.w(context, 24)),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              AppColors.authTitle,
              AppColors.authTitleEnd,
            ],
          ).createShader(bounds),
          child: Text(
            isSignIn ? 'welcome'.tr : 'create_account'.tr,
            textAlign: TextAlign.center,
            style: AppTextStyles.authTitle(context),
          ),
        ),
        SizedBox(height: Responsive.w(context, 8)),
        Text(
          isSignIn ? 'sign_in_subtitle'.tr : 'sign_up_subtitle'.tr,
          textAlign: TextAlign.center,
          style: AppTextStyles.authSubtitle(context),
        ),
      ],
    );
  }
}

class _AuthCard extends GetView<AuthController> {
  const _AuthCard({required this.isSignIn});

  final bool isSignIn;

  @override
  Widget build(BuildContext context) {
    final radius = Responsive.w(context, 32);
    final borderWidth = Responsive.w(context, 1.098);
    final pad = Responsive.w(context, 31.98);
    final fieldGap = Responsive.w(context, 20);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: AppColors.authCard,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: AppColors.authCardBorder,
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: Responsive.w(context, 40),
            offset: Offset(0, Responsive.w(context, 16)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(
            () => AuthTextField(
              label: 'email_label'.tr,
              hint: 'email_hint'.tr,
              controller: controller.emailController,
              prefixIcon: AppAssets.authEmailIcon,
              keyboardType: TextInputType.emailAddress,
              errorText: controller.errorFor('email'),
              onChanged: (_) => controller.clearFieldError('email'),
            ),
          ),
          SizedBox(height: fieldGap),
          Obx(
            () => AuthTextField(
              label: 'password_label'.tr,
              hint: 'password_hint'.tr,
              controller: controller.passwordController,
              prefixIcon: AppAssets.authLockIcon,
              obscureText: controller.obscurePassword.value,
              onToggleVisibility: controller.togglePasswordVisibility,
              errorText: controller.errorFor('password'),
              onChanged: (_) => controller.clearFieldError('password'),
            ),
          ),
          if (isSignIn) ...[
            SizedBox(height: Responsive.w(context, 18)),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => _showForgotPasswordSheet(context),
                child: Text(
                  'forgot_password'.tr,
                  style: AppTextStyles.authLink(context),
                ),
              ),
            ),
            SizedBox(height: Responsive.w(context, 26)),
          ] else
            SizedBox(height: Responsive.w(context, 24)),
          Obx(
            () => AuthPrimaryButton(
              label: isSignIn ? 'sign_in'.tr : 'create_account'.tr,
              isLoading: controller.isLoading.value,
              enabled: controller.formFilled.value,
              onPressed: controller.isLoading.value
                  ? null
                  : controller.onPrimaryAction,
            ),
          ),
          if (controller.canContinueAsGuest) ...[
            SizedBox(height: Responsive.w(context, 18)),
            Obx(
              () => AuthGuestButton(
                isLoading: controller.isGuestLoading.value,
                onPressed: controller.isGuestLoading.value
                    ? null
                    : controller.onGuestContinue,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showForgotPasswordSheet(BuildContext context) {
    controller.preparePasswordReset();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ForgotPasswordSheet(),
    );
  }
}

class _AuthFooter extends GetView<AuthController> {
  const _AuthFooter({required this.isSignIn});

  final bool isSignIn;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 24)),
      child: Text.rich(
        TextSpan(
          text: isSignIn
              ? '${'dont_have_account'.tr} '
              : '${'already_have_account'.tr} ',
          style: AppTextStyles.authFooter(context),
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: GestureDetector(
                onTap: isSignIn
                    ? controller.switchToSignUp
                    : controller.switchToSignIn,
                child: Text(
                  isSignIn ? 'sign_up'.tr : 'sign_in'.tr,
                  style: AppTextStyles.authFooterLink(context),
                ),
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _ForgotPasswordSheet extends GetView<AuthController> {
  const _ForgotPasswordSheet();

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        Responsive.w(context, 20),
        0,
        Responsive.w(context, 20),
        bottomInset + safeBottom + Responsive.w(context, 16),
      ),
      child: Container(
        padding: EdgeInsets.all(Responsive.w(context, 22)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Responsive.w(context, 28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: Responsive.w(context, 32),
              offset: Offset(0, Responsive.w(context, 12)),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: Responsive.w(context, 50),
                  height: Responsive.w(context, 50),
                  decoration: BoxDecoration(
                    color: AppColors.authTabTrack,
                    borderRadius: BorderRadius.circular(
                      Responsive.w(context, 16),
                    ),
                  ),
                  child: Icon(
                    Icons.lock_reset_rounded,
                    color: AppColors.authAccent,
                    size: Responsive.w(context, 28),
                  ),
                ),
                SizedBox(width: Responsive.w(context, 14)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'forgot_password'.tr,
                        style: AppTextStyles.authTitle(context).copyWith(
                          fontSize: Responsive.sp(context, 22),
                          height: 1.15,
                        ),
                      ),
                      SizedBox(height: Responsive.w(context, 3)),
                      Text(
                        'password_reset_subtitle'.tr,
                        style: AppTextStyles.authSubtitle(context, size: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: Responsive.w(context, 20)),
            AuthTextField(
              label: 'email_label'.tr,
              hint: 'email_hint'.tr,
              controller: controller.resetEmailController,
              prefixIcon: AppAssets.authEmailIcon,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: Responsive.w(context, 18)),
            Obx(
              () => AuthGuestButton(
                isLoading: controller.isResettingPassword.value,
                showIcon: false,
                onPressed: controller.isResettingPassword.value
                    ? null
                    : controller.requestPasswordReset,
                label: 'password_reset_send'.tr,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
