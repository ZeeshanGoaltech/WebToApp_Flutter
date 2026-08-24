import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  TokenStorage(this._prefs);

  final SharedPreferences _prefs;

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _expiresKey = 'access_expires_at';
  static const _emailKey = 'user_email';
  static const _displayNameKey = 'user_display_name';
  static const _languageKey = 'selected_language_id';
  static const _onboardingCompleteKey = 'onboarding_complete';
  static const _guestKey = 'guest_mode';
  static const _splashInter1stShownKey = 'splash_inter_1st_shown';
  static const _firstBuildCompleteKey = 'first_build_complete';
  static const _deviceIdKey = 'device_id';
  static const _guestEmailKey = 'guest_email';
  static const _guestPasswordKey = 'guest_password';

  static Future<TokenStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    final storage = TokenStorage(prefs);
    await storage._ensureDeviceId();
    return storage;
  }

  Future<void> _ensureDeviceId() async {
    final existing = _prefs.getString(_deviceIdKey);
    if (existing != null && existing.isNotEmpty) return;

    final generated =
        '${DateTime.now().microsecondsSinceEpoch}_${identityHashCode(_prefs)}';
    await _prefs.setString(_deviceIdKey, generated);
  }

  String? get accessToken => _prefs.getString(_accessKey);
  String? get refreshToken => _prefs.getString(_refreshKey);
  int? get accessExpiresAt => _prefs.getInt(_expiresKey);

  bool get hasTokens =>
      accessToken != null && accessToken!.isNotEmpty && refreshToken != null;

  String? get savedEmail => _prefs.getString(_emailKey);
  String? get savedDisplayName => _prefs.getString(_displayNameKey);

  String get selectedLanguageId =>
      _prefs.getString(_languageKey) ?? 'en_gb';

  Future<void> saveLanguageId(String id) => _prefs.setString(_languageKey, id);

  bool get hasCompletedOnboarding =>
      _prefs.getBool(_onboardingCompleteKey) ?? false;

  bool get isGuestMode => _prefs.getBool(_guestKey) ?? false;

  bool get hasCompletedFirstBuild =>
      _prefs.getBool(_firstBuildCompleteKey) ?? false;

  String? get guestEmail => _prefs.getString(_guestEmailKey);
  String? get guestPassword => _prefs.getString(_guestPasswordKey);

  String get deviceId {
    final existing = _prefs.getString(_deviceIdKey);
    if (existing != null && existing.isNotEmpty) return existing;
    return '${DateTime.now().microsecondsSinceEpoch}_${identityHashCode(_prefs)}';
  }

  Future<void> markOnboardingComplete() =>
      _prefs.setBool(_onboardingCompleteKey, true);

  /// Whether splash interstitial (1st time) has already been attempted.
  bool get hasShownSplashInter1st =>
      _prefs.getBool(_splashInter1stShownKey) ?? false;

  Future<void> markSplashInter1stShown() =>
      _prefs.setBool(_splashInter1stShownKey, true);

  Future<void> markFirstBuildComplete() =>
      _prefs.setBool(_firstBuildCompleteKey, true);

  Future<void> saveGuestCredentials({
    required String email,
    required String password,
  }) async {
    await _prefs.setString(_guestEmailKey, email);
    await _prefs.setString(_guestPasswordKey, password);
  }

  Future<void> setGuestMode(bool value) async {
    if (value) {
      await _prefs.setBool(_guestKey, true);
    } else {
      await _prefs.remove(_guestKey);
    }
  }

  Future<void> saveProfile({String? email, String? displayName}) async {
    if (email != null && email.isNotEmpty) {
      await _prefs.setString(_emailKey, email);
    }
    if (displayName != null && displayName.isNotEmpty) {
      await _prefs.setString(_displayNameKey, displayName);
    }
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresInSec,
  }) async {
    final expiresAt =
        DateTime.now().millisecondsSinceEpoch + (expiresInSec * 1000);
    await _prefs.setString(_accessKey, accessToken);
    await _prefs.setString(_refreshKey, refreshToken);
    await _prefs.setInt(_expiresKey, expiresAt);
  }

  Future<void> clearAuth() async {
    await _prefs.remove(_accessKey);
    await _prefs.remove(_refreshKey);
    await _prefs.remove(_expiresKey);
    await _prefs.remove(_emailKey);
    await _prefs.remove(_displayNameKey);
  }

  Future<void> clear() async {
    await clearAuth();
    await _prefs.remove(_guestKey);
  }
}
