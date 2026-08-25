import 'package:get/get.dart';
import 'package:web_to_app/core/api/api_exception.dart';
import 'package:web_to_app/data/repositories/auth_repository.dart';

/// Moves guest-built apps onto the signed-in account after login/signup.
class GuestMigrationService extends GetxService {
  GuestMigrationService(this._authRepository);

  final AuthRepository _authRepository;

  Future<void> migrateGuestApps({required String guestRefreshToken}) async {
    try {
      await _authRepository.mergeGuestAccount(
        guestRefreshToken: guestRefreshToken,
      );
    } on ApiException catch (e) {
      // Backend may not expose merge yet — ignore missing route.
      if (e.statusCode == 404 || e.code == 'not_found') return;
      rethrow;
    }
  }
}
