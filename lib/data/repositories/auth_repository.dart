import 'package:get/get.dart';
import 'package:web_to_app/core/api/api_client.dart';
import 'package:web_to_app/core/services/token_storage.dart';
import 'package:web_to_app/data/models/auth_models.dart';

class AuthRepository extends GetxService {
  AuthRepository(this._client, this._tokenStorage);

  final ApiClient _client;
  final TokenStorage _tokenStorage;

  Future<AuthResult> signup({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final result = await _client.post<AuthResult>(
      '/v1/auth/signup',
      data: {
        'email': email,
        'password': password,
        if (displayName != null && displayName.isNotEmpty)
          'displayName': displayName,
      },
      parser: (json) => AuthResult.fromJson(json as Map<String, dynamic>),
    );
    await persistTokens(result.tokens);
    return result;
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final result = await _client.post<AuthResult>(
      '/v1/auth/login',
      data: {'email': email, 'password': password},
      parser: (json) => AuthResult.fromJson(json as Map<String, dynamic>),
    );
    await persistTokens(result.tokens);
    return result;
  }

  Future<void> refresh() async {
    final refreshToken = _tokenStorage.refreshToken;
    if (refreshToken == null) {
      throw StateError('No refresh token');
    }
    final result = await _client.post<RefreshResult>(
      '/v1/auth/refresh',
      data: {'refreshToken': refreshToken},
      parser: (json) => RefreshResult.fromJson(json as Map<String, dynamic>),
    );
    await persistTokens(result.tokens);
  }

  Future<MeResult> me() => _client.get<MeResult>(
    '/v1/auth/me',
    parser: (json) => MeResult.fromJson(json as Map<String, dynamic>),
  );

  Future<void> requestPasswordReset(String email) => _client.post<void>(
    '/v1/auth/password/reset-request',
    data: {'email': email},
  );

  Future<void> logout() async {
    final refreshToken = _tokenStorage.refreshToken;
    try {
      if (refreshToken != null) {
        await _client.post<void>(
          '/v1/auth/logout',
          data: {'refreshToken': refreshToken},
        );
      }
    } finally {
      await _tokenStorage.clear();
    }
  }

  Future<void> persistTokens(AuthTokens tokens) => _tokenStorage.saveTokens(
    accessToken: tokens.accessToken,
    refreshToken: tokens.refreshToken,
    expiresInSec: tokens.expiresInSec,
  );
}
