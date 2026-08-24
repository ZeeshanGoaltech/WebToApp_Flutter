import 'package:get/get.dart';
import 'package:web_to_app/app/routes/app_routes.dart';
import 'package:web_to_app/core/navigation/auth_redirect.dart';
import 'package:web_to_app/core/services/guest_auth_service.dart';
import 'package:web_to_app/core/services/session_service.dart';
import 'package:web_to_app/core/services/token_storage.dart';

/// First app build works without a visible login; later builds require sign-in.
class BuildLoginGate {
  BuildLoginGate._();

  static Future<bool> ensureForNewApp({
    required Future<void> Function() openCreateApp,
  }) async {
    if (await _ensureFirstBuildAccess()) return true;

    AuthRedirect.setPendingAction(openCreateApp);
    await Get.toNamed(AppRoutes.auth);
    return false;
  }

  static Future<bool> ensureForBuild({
    required Future<void> Function() retry,
  }) async {
    if (await _ensureFirstBuildAccess()) return true;

    AuthRedirect.setPendingAction(retry);
    await Get.toNamed(AppRoutes.auth);
    return false;
  }

  static Future<bool> _ensureFirstBuildAccess() async {
    final session = Get.find<SessionService>();
    if (session.isAuthenticated) return true;

    final storage = Get.find<TokenStorage>();
    if (session.isGuest.value && !storage.hasCompletedFirstBuild) {
      await Get.find<GuestAuthService>().ensureGuestApiSession();
      return true;
    }

    return false;
  }
}
