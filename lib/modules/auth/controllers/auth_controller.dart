import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/ads/ad_presentation_gate.dart';
import 'package:web_to_app/core/api/api_exception.dart';
import 'package:web_to_app/core/navigation/auth_redirect.dart';
import 'package:web_to_app/core/navigation/launch_flow.dart';
import 'package:web_to_app/core/services/guest_migration_service.dart';
import 'package:web_to_app/core/services/session_service.dart';
import 'package:web_to_app/core/services/token_storage.dart';
import 'package:web_to_app/core/utils/app_error_handler.dart';
import 'package:web_to_app/core/utils/app_toast.dart';
import 'package:web_to_app/data/models/auth_models.dart';
import 'package:web_to_app/data/repositories/auth_repository.dart';
import 'package:web_to_app/modules/home/controllers/home_controller.dart';

enum AuthTab { signIn, signUp }

class AuthController extends GetxController {
  final Rx<AuthTab> activeTab = AuthTab.signIn.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool isLoading = false.obs;
  final RxBool isGuestLoading = false.obs;
  final RxBool isResettingPassword = false.obs;
  final fieldErrors = <String, String>{}.obs;
  DateTime? _lastBackPressAt;

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final resetEmailController = TextEditingController();

  final formFilled = false.obs;

  bool get isSignIn => activeTab.value == AuthTab.signIn;

  bool get canContinueAsGuest {
    // Hide guest CTA when user was sent here specifically to unlock APK generate.
    if (AuthRedirect.hasPendingAction) return false;
    return true;
  }

  @override
  void onInit() {
    super.onInit();
    void updateFormFilled() => formFilled.value = _isFormFilled();
    fullNameController.addListener(updateFormFilled);
    emailController.addListener(updateFormFilled);
    passwordController.addListener(() {
      updateFormFilled();
      if (passwordController.text.isEmpty) {
        obscurePassword.value = true;
      }
    });
    ever(activeTab, (_) => formFilled.value = _isFormFilled());
  }

  bool _isFormFilled() {
    if (emailController.text.trim().isEmpty) return false;
    if (passwordController.text.isEmpty) return false;
    return true;
  }

  void switchToSignIn() {
    activeTab.value = AuthTab.signIn;
    fieldErrors.clear();
  }

  void switchToSignUp() {
    activeTab.value = AuthTab.signUp;
    fieldErrors.clear();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void preparePasswordReset() {
    resetEmailController.text = emailController.text.trim();
  }

  String? errorFor(String key) => fieldErrors[key];

  void clearFieldError(String key) {
    if (fieldErrors.remove(key) != null) {
      fieldErrors.refresh();
    }
  }

  Future<void> requestPasswordReset() async {
    final email = resetEmailController.text.trim();
    if (email.isEmpty) {
      AppToast.info(
        'missing_fields'.tr,
        description: 'password_reset_email_required'.tr,
      );
      return;
    }

    if (isResettingPassword.value) return;
    isResettingPassword.value = true;
    try {
      await Get.find<AuthRepository>().requestPasswordReset(email);
      Get.back();
      AppToast.success(
        'password_reset_sent'.tr,
        description: 'password_reset_sent_desc'.tr,
      );
    } on ApiException catch (e) {
      await AppErrorHandler.show(e);
    } finally {
      isResettingPassword.value = false;
    }
  }

  Future<void> onPrimaryAction() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (!_validateAuthForm(email: email, password: password)) {
      return;
    }

    isLoading.value = true;
    try {
      final authRepo = Get.find<AuthRepository>();
      final session = Get.find<SessionService>();
      final storage = Get.find<TokenStorage>();
      final migration = Get.find<GuestMigrationService>();

      // Guest projects must be exported BEFORE login overwrites tokens.
      final wasGuestSession =
          session.isGuest.value || storage.isGuestMode;
      final guestRefreshToken =
          wasGuestSession && storage.hasTokens ? storage.refreshToken : null;

      var exportedProjects = <GuestAppExport>[];
      if (wasGuestSession) {
        try {
          if (storage.hasTokens) {
            exportedProjects = await migration.exportGuestProjects();
          } else {
            final guestEmail = storage.guestEmail;
            final guestPassword = storage.guestPassword;
            if (guestEmail != null &&
                guestEmail.isNotEmpty &&
                guestPassword != null &&
                guestPassword.isNotEmpty) {
              await authRepo.login(email: guestEmail, password: guestPassword);
              exportedProjects = await migration.exportGuestProjects();
            }
          }
        } catch (_) {
          exportedProjects = <GuestAppExport>[];
        }
      }

      final AuthResult result;

      if (isSignIn) {
        result = await authRepo.login(email: email, password: password);
      } else {
        result = await authRepo.signup(
          email: email,
          password: password,
        );
      }

      await session.setAuthResult(result);

      // If export was empty (or session flags missed), recover via saved guest creds.
      if (exportedProjects.isEmpty) {
        final guestEmail = storage.guestEmail;
        final guestPassword = storage.guestPassword;
        if (guestEmail != null &&
            guestEmail.isNotEmpty &&
            guestPassword != null &&
            guestPassword.isNotEmpty) {
          try {
            final userAccess = storage.accessToken;
            final userRefresh = storage.refreshToken;
            final userExpires = storage.accessExpiresAt;

            await authRepo.login(email: guestEmail, password: guestPassword);
            exportedProjects = await migration.exportGuestProjects();

            if (userAccess != null &&
                userRefresh != null &&
                userExpires != null) {
              final remainingSec = ((userExpires -
                          DateTime.now().millisecondsSinceEpoch) /
                      1000)
                  .ceil()
                  .clamp(60, 86400);
              await storage.saveTokens(
                accessToken: userAccess,
                refreshToken: userRefresh,
                expiresInSec: remainingSec,
              );
            } else {
              // Fallback: re-login as the real user.
              if (isSignIn) {
                await authRepo.login(email: email, password: password);
              } else {
                await authRepo.login(email: email, password: password);
              }
            }
          } catch (_) {
            try {
              if (isSignIn) {
                await authRepo.login(email: email, password: password);
              } else {
                await authRepo.login(email: email, password: password);
              }
            } catch (_) {}
          }
        }
      }

      if (exportedProjects.isNotEmpty) {
        try {
          final migrated = await migration.migrateGuestApps(
            guestRefreshToken: guestRefreshToken,
            exportedProjects: exportedProjects,
          );
          await migration.markMigrationCompleted(storage);

          final verified = migrated > 0 ||
              await migration.areProjectsPresent(exportedProjects);
          if (verified) {
            AppToast.success(
              'guest_projects_migrated'.tr,
              description: migrated > 0
                  ? 'guest_projects_migrated_desc'
                      .trParams({'count': '$migrated'})
                  : 'guest_login_benefit_projects'.tr,
            );
          } else {
            AppToast.info(
              'guest_projects_migrate_failed'.tr,
              description: 'guest_projects_migrate_failed_desc'.tr,
            );
          }
        } catch (_) {
          AppToast.info(
            'guest_projects_migrate_failed'.tr,
            description: 'guest_projects_migrate_failed_desc'.tr,
          );
        }
      }

      await session.refreshProfile();
      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().loadApps();
      }
      await _completeAuthNavigation();
    } on ApiException catch (e) {
      await AppErrorHandler.show(
        e,
        title:
            isSignIn ? 'sign_in_failed'.tr : 'sign_up_failed'.tr,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _completeAuthNavigation() async {
    final pending = AuthRedirect.takePendingAction();
    if (pending != null) {
      if (Get.key.currentState?.canPop() ?? false) {
        Get.back();
      }
      await pending();
      return;
    }
    LaunchFlow.goHome();
  }

  bool _validateAuthForm({required String email, required String password}) {
    fieldErrors.clear();

    if (email.isEmpty) {
      fieldErrors['email'] = 'auth_err_email_required'.tr;
    } else if (!_isValidEmail(email)) {
      fieldErrors['email'] = 'auth_err_email_invalid'.tr;
    }

    if (password.isEmpty) {
      fieldErrors['password'] = 'auth_err_password_required'.tr;
    } else if (password.length < 6) {
      fieldErrors['password'] = 'auth_err_password_short'.tr;
    } else if (!_hasUppercase(password) || !_hasSpecialCharacter(password)) {
      fieldErrors['password'] = 'auth_err_password_complexity'.tr;
    }

    fieldErrors.refresh();
    return fieldErrors.isEmpty;
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);
  }

  bool _hasUppercase(String value) => RegExp(r'[A-Z]').hasMatch(value);

  bool _hasSpecialCharacter(String value) =>
      RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\\/\[\]]').hasMatch(value);

  // void onGoogleSignIn() {
  //   AppToast.info(
  //     'coming_soon'.tr,
  //     description: 'google_signin_unavailable'.tr,
  //   );
  // }

  Future<void> onGuestContinue() async {
    if (isGuestLoading.value) return;
    isGuestLoading.value = true;
    try {
      await Get.find<SessionService>().setGuest();
      LaunchFlow.goHome();
    } finally {
      isGuestLoading.value = false;
    }
  }

  /// Root auth (splash / first-install): first back shows toast, second exits.
  /// Pushed auth (e.g. build login gate): allow normal pop.
  Future<bool> handleSystemBack() async {
    if (AdPresentationGate.shouldBlockBack) return false;

    if (Get.key.currentState?.canPop() ?? false) return true;

    final now = DateTime.now();
    if (_lastBackPressAt == null ||
        now.difference(_lastBackPressAt!) > const Duration(seconds: 2)) {
      _lastBackPressAt = now;
      await AppToast.info('press_back_again_to_close'.tr);
      return false;
    }
    return true;
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    resetEmailController.dispose();
    super.onClose();
  }
}
