import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/api/api_exception.dart';
import 'package:web_to_app/core/navigation/launch_flow.dart';
import 'package:web_to_app/core/services/session_service.dart';
import 'package:web_to_app/core/utils/app_error_handler.dart';
import 'package:web_to_app/core/utils/app_toast.dart';
import 'package:web_to_app/data/models/auth_models.dart';
import 'package:web_to_app/data/repositories/auth_repository.dart';

enum AuthTab { signIn, signUp }

class AuthController extends GetxController {
  final Rx<AuthTab> activeTab = AuthTab.signIn.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool isLoading = false.obs;
  final RxBool isGuestLoading = false.obs;
  final RxBool isResettingPassword = false.obs;
  final fieldErrors = <String, String>{}.obs;

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final resetEmailController = TextEditingController();

  final formFilled = false.obs;

  bool get isSignIn => activeTab.value == AuthTab.signIn;

  @override
  void onInit() {
    super.onInit();
    void updateFormFilled() => formFilled.value = _isFormFilled();
    fullNameController.addListener(updateFormFilled);
    emailController.addListener(updateFormFilled);
    passwordController.addListener(updateFormFilled);
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
      await session.refreshProfile();
      LaunchFlow.goHome();
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

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    resetEmailController.dispose();
    super.onClose();
  }
}
