import 'package:get/get.dart';
import 'package:web_to_app/core/api/api_exception.dart';
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
}

/// Moves guest-created apps onto the signed-in account after login/signup.
class GuestMigrationService extends GetxService {
  GuestMigrationService(this._authRepository, this._appsRepository);

  final AuthRepository _authRepository;
  final AppsRepository _appsRepository;

  /// Snapshot guest apps while the guest token is still active.
  Future<List<GuestAppExport>> exportGuestProjects() async {
    final apps = await _appsRepository.listApps();
    final exports = <GuestAppExport>[];

    for (final app in apps) {
      try {
        final configResponse = await _appsRepository.getConfig(app.id);
        exports.add(
          GuestAppExport(
            name: app.name,
            androidPackage: app.androidPackage,
            config: configResponse.config,
          ),
        );
      } catch (_) {
        // Skip apps that cannot be exported; continue with the rest.
      }
    }

    return exports;
  }

  /// Returns `-1` when server merge handled transfer, otherwise created count.
  Future<int> migrateGuestApps({
    String? guestRefreshToken,
    List<GuestAppExport> exportedProjects = const [],
  }) async {
    if (guestRefreshToken != null && guestRefreshToken.isNotEmpty) {
      try {
        await _authRepository.mergeGuestAccount(
          guestRefreshToken: guestRefreshToken,
        );
        return -1;
      } on ApiException catch (_) {
        // Fall through to client recreate when merge is unavailable.
      } catch (_) {
        // Fall through to client recreate.
      }
    }

    return _recreateProjects(exportedProjects);
  }

  Future<int> _recreateProjects(List<GuestAppExport> exports) async {
    if (exports.isEmpty) return 0;

    final existing = await _appsRepository.listApps();
    final existingPackages = existing.map((e) => e.androidPackage).toSet();
    var created = 0;

    for (final project in exports) {
      var packageName = project.androidPackage;
      if (existingPackages.contains(packageName)) {
        packageName = _uniquePackage(packageName, existingPackages);
      }

      try {
        await _appsRepository.createApp(
          name: project.name,
          androidPackage: packageName,
          config: _configWithPackage(project.config, packageName, project.name),
        );
        existingPackages.add(packageName);
        created++;
      } catch (_) {
        // Continue migrating remaining projects.
      }
    }

    return created;
  }

  String _uniquePackage(String packageName, Set<String> existing) {
    final stamp = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    final candidate = '$packageName.$stamp';
    if (!existing.contains(candidate)) return candidate;
    return '$packageName.g$stamp';
  }

  Map<String, dynamic> _configWithPackage(
    Map<String, dynamic> config,
    String packageName,
    String name,
  ) {
    final next = Map<String, dynamic>.from(config);
    final identity = Map<String, dynamic>.from(
      (next['identity'] as Map?)?.cast<String, dynamic>() ?? {},
    );
    identity['androidPackage'] = packageName;
    identity['name'] = name;
    next['identity'] = identity;
    return next;
  }
}
