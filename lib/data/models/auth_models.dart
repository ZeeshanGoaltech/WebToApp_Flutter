import 'package:web_to_app/data/models/billing_models.dart';

class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.expiresInSec,
    required this.refreshToken,
  });

  final String accessToken;
  final int expiresInSec;
  final String refreshToken;

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
        accessToken: json['accessToken'] as String,
        expiresInSec: json['expiresInSec'] as int,
        refreshToken: json['refreshToken'] as String,
      );
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.accountId,
    required this.role,
    this.email,
    this.displayName,
  });

  final String id;
  final String accountId;
  final String role;
  final String? email;
  final String? displayName;

  String get resolvedName {
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final mail = email?.trim();
    if (mail != null && mail.contains('@')) return mail.split('@').first;
    return 'User';
  }

  AuthUser mergeProfile({String? email, String? displayName}) => AuthUser(
        id: id,
        accountId: accountId,
        role: role,
        email: email ?? this.email,
        displayName: displayName ?? this.displayName,
      );

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as String,
        accountId: json['accountId'] as String,
        role: json['role'] as String,
        email: json['email'] as String?,
        displayName: json['displayName'] as String?,
      );
}

class AuthResult {
  const AuthResult({required this.user, required this.tokens});

  final AuthUser user;
  final AuthTokens tokens;

  factory AuthResult.fromJson(Map<String, dynamic> json) => AuthResult(
        user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
        tokens: AuthTokens.fromJson(json['tokens'] as Map<String, dynamic>),
      );
}

class MeResult {
  const MeResult({required this.user, required this.entitlement});

  final AuthUser user;
  final EntitlementDto entitlement;

  factory MeResult.fromJson(Map<String, dynamic> json) => MeResult(
        user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
        entitlement: EntitlementDto.fromJson(
          json['entitlement'] as Map<String, dynamic>,
        ),
      );
}

class RefreshResult {
  const RefreshResult({required this.tokens});

  final AuthTokens tokens;

  factory RefreshResult.fromJson(Map<String, dynamic> json) => RefreshResult(
        tokens: AuthTokens.fromJson(json['tokens'] as Map<String, dynamic>),
      );
}
