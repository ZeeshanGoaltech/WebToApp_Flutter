import 'package:get/get.dart';
import 'package:web_to_app/app/routes/app_routes.dart';
import 'package:web_to_app/core/navigation/auth_redirect.dart';
import 'package:web_to_app/core/services/guest_auth_service.dart';
import 'package:web_to_app/core/services/session_service.dart';
import 'package:web_to_app/core/widgets/guest_login_premium_dialog.dart';

/// Guests may create projects and generate APKs without login.
/// Login is only suggested (guide) so data stays after uninstall.
class BuildLoginGate {
  BuildLoginGate._();

  static bool _guestBackupGuideShown = false;

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

  /// Guests can generate APK. We only show a soft backup/login tip once.
  static Future<bool> ensureForBuild({
    required Future<void> Function() retry,
  }) async {
    final session = Get.find<SessionService>();
    if (session.isAuthenticated) return true;

    if (session.isGuest.value) {
      await Get.find<GuestAuthService>().ensureGuestApiSession();

      if (!_guestBackupGuideShown) {
        _guestBackupGuideShown = true;
        final context = Get.context;
        if (context != null && context.mounted) {
          final action = await showGuestLoginGuideDialog(context);
          if (action == GuestLoginGuideAction.login) {
            AuthRedirect.setPendingAction(retry);
            await Get.toNamed(AppRoutes.auth);
            return false;
          }
        }
      }

      // Continue as guest — login is optional.
      return true;
    }

    AuthRedirect.setPendingAction(retry);
    await Get.toNamed(AppRoutes.auth);
    return false;
  }
}
