import 'package:get/get.dart';
import 'package:web_to_app/app/routes/app_routes.dart';
import 'package:web_to_app/core/navigation/auth_redirect.dart';
import 'package:web_to_app/core/services/guest_auth_service.dart';
import 'package:web_to_app/core/services/session_service.dart';
import 'package:web_to_app/core/widgets/guest_login_premium_dialog.dart';

/// Guests may create unlimited projects. Generating an APK requires sign-in.
class BuildLoginGate {
  BuildLoginGate._();

  static Future<bool> ensureForNewApp({
    required Future<void> Function() openCreateApp,
  }) async {
    final session = Get.find<SessionService>();
    if (session.isAuthenticated) return true;

    if (session.isGuest.value) {
      await Get.find<GuestAuthService>().ensureGuestApiSession();
      return true;
    }

    AuthRedirect.setPendingAction(openCreateApp);
    await Get.toNamed(AppRoutes.auth);
    return false;
  }

  /// Call only when the user taps Generate APK / Build Again.
  static Future<bool> ensureForBuild({
    required Future<void> Function() retry,
  }) async {
    final session = Get.find<SessionService>();
    if (session.isAuthenticated) return true;

    if (session.isGuest.value) {
      final context = Get.context;
      if (context == null) return false;

      final shouldLogin = await showGuestLoginPremiumDialog(context);
      if (!shouldLogin) return false;

      AuthRedirect.setPendingAction(retry);
      await Get.toNamed(AppRoutes.auth);
      return false;
    }

    AuthRedirect.setPendingAction(retry);
    await Get.toNamed(AppRoutes.auth);
    return false;
  }
}
