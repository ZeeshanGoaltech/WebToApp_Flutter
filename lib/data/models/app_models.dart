class AppSummary {
  const AppSummary({
    required this.id,
    required this.name,
    required this.androidPackage,
    required this.domainVerified,
    required this.createdAt,
    this.currentVersionCode,
  });

  final String id;
  final String name;
  final String androidPackage;
  final bool domainVerified;
  final DateTime createdAt;
  final int? currentVersionCode;

  String get urlLabel => androidPackage;

  String get initial {
    final trimmed = name.trim();
    return trimmed.isNotEmpty ? trimmed[0].toUpperCase() : '?';
  }

  factory AppSummary.fromJson(Map<String, dynamic> json) => AppSummary(
    id: json['id'] as String,
    name: json['name'] as String,
    androidPackage: json['androidPackage'] as String,
    domainVerified: json['domainVerified'] as bool,
    createdAt: DateTime.parse(json['createdAt'] as String),
    currentVersionCode: json['currentVersionCode'] as int?,
  );
}

class OkResponse {
  const OkResponse({required this.ok});

  final bool ok;

  factory OkResponse.fromJson(Map<String, dynamic> json) =>
      OkResponse(ok: json['ok'] as bool? ?? true);
}

class CreateAppResponse {
  const CreateAppResponse({
    required this.appId,
    required this.configVersion,
    required this.schemaVersion,
  });

  final String appId;
  final int configVersion;
  final int schemaVersion;

  factory CreateAppResponse.fromJson(Map<String, dynamic> json) =>
      CreateAppResponse(
        appId: json['appId'] as String,
        configVersion: json['configVersion'] as int,
        schemaVersion: json['schemaVersion'] as int,
      );
}

class PutConfigResponse {
  const PutConfigResponse({
    required this.appId,
    required this.configVersion,
    required this.schemaVersion,
    required this.requiresRebuild,
  });

  final String appId;
  final int configVersion;
  final int schemaVersion;
  final List<String> requiresRebuild;

  factory PutConfigResponse.fromJson(Map<String, dynamic> json) =>
      PutConfigResponse(
        appId: json['appId'] as String,
        configVersion: json['configVersion'] as int,
        schemaVersion: json['schemaVersion'] as int,
        requiresRebuild: (json['requiresRebuild'] as List<dynamic>? ?? [])
            .map((e) => e as String)
            .toList(),
      );
}

class AppVersionDto {
  const AppVersionDto({
    required this.id,
    required this.appId,
    required this.versionName,
    required this.androidVersionCode,
    required this.createdAt,
  });

  final String id;
  final String appId;
  final String versionName;
  final int androidVersionCode;
  final DateTime createdAt;

  factory AppVersionDto.fromJson(Map<String, dynamic> json) => AppVersionDto(
    id: json['id'] as String,
    appId: json['appId'] as String,
    versionName: json['versionName'] as String,
    androidVersionCode: json['androidVersionCode'] as int,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

class VersionsListResponse {
  const VersionsListResponse({required this.versions});

  final List<AppVersionDto> versions;

  factory VersionsListResponse.fromJson(Map<String, dynamic> json) =>
      VersionsListResponse(
        versions: (json['versions'] as List<dynamic>? ?? [])
            .map((e) => AppVersionDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class GetConfigResponse {
  const GetConfigResponse({required this.config, required this.version});

  final Map<String, dynamic> config;
  final AppVersionDto version;

  factory GetConfigResponse.fromJson(Map<String, dynamic> json) =>
      GetConfigResponse(
        config: json['config'] as Map<String, dynamic>,
        version: AppVersionDto.fromJson(
          json['version'] as Map<String, dynamic>,
        ),
      );
}

class OwnershipVerifyResponse {
  const OwnershipVerifyResponse({required this.status, required this.message});

  final String status;
  final String message;

  factory OwnershipVerifyResponse.fromJson(Map<String, dynamic> json) =>
      OwnershipVerifyResponse(
        status: json['status'] as String? ?? 'pending',
        message: json['message'] as String? ?? '',
      );
}

class PreflightResponse {
  const PreflightResponse({
    required this.ok,
    required this.checks,
    required this.blocking,
  });

  final bool ok;
  final List<Map<String, dynamic>> checks;
  final List<String> blocking;

  factory PreflightResponse.fromJson(Map<String, dynamic> json) =>
      PreflightResponse(
        ok: json['ok'] as bool? ?? false,
        checks: (json['checks'] as List<dynamic>? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
        blocking: (json['blocking'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
      );
}
