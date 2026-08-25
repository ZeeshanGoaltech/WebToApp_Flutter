import 'package:get/get.dart';
import 'package:web_to_app/core/api/api_exception.dart';
import 'package:web_to_app/core/services/session_service.dart';
import 'package:web_to_app/core/services/token_storage.dart';
import 'package:web_to_app/data/models/auth_models.dart';
import 'package:web_to_app/data/repositories/auth_repository.dart';

/// Creates a silent backend session for guest users on their first build.
class GuestAuthService extends GetxService {
  GuestAuthService(this._authRepository, this._sessionService, this._tokenStorage);

  final AuthRepository _authRepository;
  final SessionService _sessionService;
  final TokenStorage _tokenStorage;

  Future<void> ensureGuestApiSession() async {
    if (!_sessionService.isGuest.value) return;
    if (_tokenStorage.hasTokens) {
      await _restoreGuestProfileIfNeeded();
      return;
    }

    final email = _tokenStorage.guestEmail ?? _buildGuestEmail();
    final password = _tokenStorage.guestPassword ?? _buildGuestPassword(email);

    await _tokenStorage.saveGuestCredentials(email: email, password: password);

    try {
      final result = await _authRepository.login(email: email, password: password);
      await _sessionService.setGuestAuthResult(result);
      return;
    } on ApiException catch (e) {
      if (e.statusCode != 401 && e.code != 'invalid_credentials') {
        rethrow;
      }
    }

    final result = await _authRepository.signup(email: email, password: password);
    await _sessionService.setGuestAuthResult(result);
  }

  String _buildGuestEmail() {
    final deviceId = _tokenStorage.deviceId;
    return 'guest+$deviceId@appforge.dev';
  }

  String _buildGuestPassword(String email) {
    final suffix = email.hashCode.abs().toRadixString(36);
    return 'Guest@$suffix!';
  }

  Future<void> _restoreGuestProfileIfNeeded() async {
    if (_sessionService.user.value != null) return;

    try {
      final me = await _authRepository.me();
      await _sessionService.setGuestAuthResult(
        AuthResult(user: me.user, tokens: _currentTokens()),
      );
    } on ApiException catch (e) {
      if (e.statusCode != 401 && e.code != 'unauthenticated') {
        rethrow;
      }
      await _tokenStorage.clearAuth();
      await ensureGuestApiSession();
    }
  }

  AuthTokens _currentTokens() {
    final access = _tokenStorage.accessToken;
    final refresh = _tokenStorage.refreshToken;
    if (access == null || refresh == null) {
      throw StateError('Missing guest tokens');
    }
    return AuthTokens(
      accessToken: access,
      refreshToken: refresh,
      expiresInSec: _remainingTokenLifetimeSec(),
    );
  }

  int _remainingTokenLifetimeSec() {
    final expiresAt = _tokenStorage.accessExpiresAt;
    if (expiresAt == null) return 3600;
    final remainingMs = expiresAt - DateTime.now().millisecondsSinceEpoch;
    return remainingMs > 0 ? (remainingMs / 1000).ceil() : 60;
  }
}
