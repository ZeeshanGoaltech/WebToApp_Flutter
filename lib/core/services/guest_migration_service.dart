import 'package:get/get.dart';
import 'package:web_to_app/core/api/api_exception.dart';
import 'package:web_to_app/core/services/session_service.dart';
import 'package:web_to_app/core/services/token_storage.dart';
import 'package:web_to_app/data/repositories/apps_repository.dart';
import 'package:web_to_app/data/repositories/auth_repository.dart';

class GuestAppExport {
  const GuestAppExport({
    required this.name,
    required this.androidPackage,
    required this.config,
  });

  final String name;
  final String androidPackage;
  final Map<String, dynamic> config;

  String get nameKey => name.trim().toLowerCase();
}

/// Moves guest-created apps onto the signed-in account after login/signup.
class GuestMigrationService extends GetxService {
  GuestMigrationService(this._authRepository, this._appsRepository);

  final AuthRepository _authRepository;
  final AppsRepository _appsRepository;

  bool _migrationInFlight = false;

  /// Snapshot guest apps while the guest token is still active.
  Future<List<GuestAppExport>> exportGuestProjects() async {
    final apps = await _appsRepository.listApps();
    final exports = <GuestAppExport>[];
    final seenPackages = <String>{};

    for (final app in apps) {
      final package = app.androidPackage.trim();
      if (package.isEmpty || !seenPackages.add(package)) continue;

      try {
        final configResponse = await _appsRepository.getConfig(app.id);
        exports.add(
          GuestAppExport(
            name: app.name,
            androidPackage: package,
            config: _deepCopyMap(configResponse.config),
          ),
        );
      } catch (_) {
        // Skip apps that cannot be exported; continue with the rest.
      }
    }

    return exports;
  }

  /// Returns how many projects were newly created.
  Future<int> migrateGuestApps({
    String? guestRefreshToken,
    List<GuestAppExport> exportedProjects = const [],
  }) async {
    if (exportedProjects.isEmpty) return 0;
    if (_migrationInFlight) return 0;

    _migrationInFlight = true;
    try {
      if (guestRefreshToken != null && guestRefreshToken.isNotEmpty) {
        try {
          await _authRepository.mergeGuestAccount(
            guestRefreshToken: guestRefreshToken,
          );
        } catch (_) {
          // Continue with client-side recreate.
        }
      }

      return _ensureProjectsOnCurrentAccount(exportedProjects);
    } finally {
      _migrationInFlight = false;
    }
  }

  Future<bool> areProjectsPresent(List<GuestAppExport> exports) async {
    if (exports.isEmpty) return true;
    try {
      final existing = await _appsRepository.listApps();
      final packages = existing.map((e) => e.androidPackage.trim()).toSet();
      final names = existing.map((e) => e.name.trim().toLowerCase()).toSet();
      return exports.every(
        (project) => _isDuplicate(
          project: project,
          existingPackages: packages,
          existingNames: names,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  /// Marks migration finished so home recovery will not run again.
  Future<void> markMigrationCompleted(TokenStorage storage) async {
    await storage.markGuestProjectsRecovered();
    await storage.clearGuestCredentials();
  }

  /// For already-logged-in users: pull leftover guest projects using saved creds.
  Future<int> recoverGuestProjectsIfNeeded(TokenStorage storage) async {
    if (storage.hasRecoveredGuestProjects) return 0;
    if (!Get.find<SessionService>().isAuthenticated) return 0;
    if (_migrationInFlight) return 0;

    final guestEmail = storage.guestEmail;
    final guestPassword = storage.guestPassword;
    if (guestEmail == null ||
        guestEmail.isEmpty ||
        guestPassword == null ||
        guestPassword.isEmpty) {
      await storage.markGuestProjectsRecovered();
      return 0;
    }

    final userAccess = storage.accessToken;
    final userRefresh = storage.refreshToken;
    final userExpires = storage.accessExpiresAt;
    if (userAccess == null || userRefresh == null) return 0;

    try {
      await _authRepository.login(email: guestEmail, password: guestPassword);
      final exports = await exportGuestProjects();

      await _restoreTokens(
        storage: storage,
        accessToken: userAccess,
        refreshToken: userRefresh,
        expiresAt: userExpires,
      );

      if (exports.isEmpty) {
        await markMigrationCompleted(storage);
        return 0;
      }

      if (await areProjectsPresent(exports)) {
        await markMigrationCompleted(storage);
        return 0;
      }

      final created = await migrateGuestApps(exportedProjects: exports);
      await markMigrationCompleted(storage);
      return created;
    } catch (_) {
      await _restoreTokens(
        storage: storage,
        accessToken: userAccess,
        refreshToken: userRefresh,
        expiresAt: userExpires,
      );
      return 0;
    }
  }

  Future<void> _restoreTokens({
    required TokenStorage storage,
    required String accessToken,
    required String refreshToken,
    required int? expiresAt,
  }) async {
    final remainingSec = expiresAt == null
        ? 3600
        : ((expiresAt - DateTime.now().millisecondsSinceEpoch) / 1000)
            .ceil()
            .clamp(60, 86400);
    await storage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresInSec: remainingSec,
    );
  }

  Future<int> _ensureProjectsOnCurrentAccount(
    List<GuestAppExport> exports,
  ) async {
    final existing = await _appsRepository.listApps();
    final existingPackages = existing.map((e) => e.androidPackage.trim()).toSet();
    final existingNames =
        existing.map((e) => e.name.trim().toLowerCase()).toSet();
    var created = 0;

    for (final project in exports) {
      if (_isDuplicate(
        project: project,
        existingPackages: existingPackages,
        existingNames: existingNames,
      )) {
        continue;
      }

      final createdPackage = await _createOnce(
        name: project.name,
        androidPackage: project.androidPackage,
        config: project.config,
        existingPackages: existingPackages,
      );
      if (createdPackage != null) {
        existingPackages.add(createdPackage);
        existingNames.add(project.nameKey);
        created++;
      }
    }

    return created;
  }

  bool _isDuplicate({
    required GuestAppExport project,
    required Set<String> existingPackages,
    required Set<String> existingNames,
  }) {
    final package = project.androidPackage.trim();
    final migratedPackage = _deterministicMigratedPackage(package);

    if (existingPackages.contains(package) ||
        existingPackages.contains(migratedPackage)) {
      return true;
    }

    // Same display name already on account → do not create another copy.
    if (project.nameKey.isNotEmpty && existingNames.contains(project.nameKey)) {
      return true;
    }

    return false;
  }

  Future<String?> _createOnce({
    required String name,
    required String androidPackage,
    required Map<String, dynamic> config,
    required Set<String> existingPackages,
  }) async {
    final first = await _tryCreate(
      name: name,
      packageName: androidPackage,
      config: config,
    );
    if (first != null) return first;

    final fallback = _deterministicMigratedPackage(androidPackage);
    if (existingPackages.contains(fallback)) return null;

    return _tryCreate(
      name: name,
      packageName: fallback,
      config: config,
    );
  }

  Future<String?> _tryCreate({
    required String name,
    required String packageName,
    required Map<String, dynamic> config,
  }) async {
    try {
      await _appsRepository.createApp(
        name: name,
        androidPackage: packageName,
        config: _sanitizeConfigForNewAccount(
          config,
          packageName: packageName,
          name: name,
        ),
      );
      return packageName;
    } on ApiException catch (_) {
      return null;
    } catch (_) {
      return null;
    }
  }

  String _deterministicMigratedPackage(String packageName) {
    if (packageName.endsWith('.guestmig')) return packageName;
    return '$packageName.guestmig';
  }

  Map<String, dynamic> _sanitizeConfigForNewAccount(
    Map<String, dynamic> config, {
    required String packageName,
    required String name,
  }) {
    final next = _deepCopyMap(config);

    final identity = Map<String, dynamic>.from(
      (next['identity'] as Map?)?.cast<String, dynamic>() ?? {},
    );
    identity['androidPackage'] = packageName;
    identity['name'] = name;
    next['identity'] = identity;

    final theme = Map<String, dynamic>.from(
      (next['theme'] as Map?)?.cast<String, dynamic>() ?? {},
    );
    theme.remove('appIconAssetId');
    theme.remove('splashAssetId');
    theme.remove('iconAssetId');
    next['theme'] = theme;

    final onboarding = next['onboarding'];
    if (onboarding is Map) {
      final onboardingMap = Map<String, dynamic>.from(
        onboarding.cast<String, dynamic>(),
      );
      final slides = onboardingMap['slides'];
      if (slides is List) {
        onboardingMap['slides'] = slides.map((slide) {
          if (slide is! Map) return slide;
          final copy = Map<String, dynamic>.from(slide.cast<String, dynamic>());
          copy.remove('imageAssetId');
          copy.remove('assetId');
          return copy;
        }).toList();
      }
      next['onboarding'] = onboardingMap;
    }

    return next;
  }

  Map<String, dynamic> _deepCopyMap(Map<String, dynamic> source) {
    final copy = <String, dynamic>{};
    source.forEach((key, value) {
      if (value is Map) {
        copy[key] = _deepCopyMap(value.cast<String, dynamic>());
      } else if (value is List) {
        copy[key] = value.map((item) {
          if (item is Map) {
            return _deepCopyMap(item.cast<String, dynamic>());
          }
          return item;
        }).toList();
      } else {
        copy[key] = value;
      }
    });
    return copy;
  }
}
