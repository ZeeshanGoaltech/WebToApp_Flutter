class BuildDto {
  const BuildDto({
    required this.id,
    required this.appId,
    required this.appVersionId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.queuePosition,
    this.estimatedWaitSeconds,
    this.aabDownloadUrl,
    this.apkDownloadUrl,
    this.logUrl,
    this.error,
  });

  final String id;
  final String appId;
  final String appVersionId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? queuePosition;
  final int? estimatedWaitSeconds;
  final String? aabDownloadUrl;
  final String? apkDownloadUrl;
  final String? logUrl;
  final String? error;

  bool get isTerminal =>
      status == 'succeeded' ||
      status == 'failed' ||
      status == 'canceled';

  bool get isSuccess => status == 'succeeded';

  factory BuildDto.fromJson(Map<String, dynamic> json) => BuildDto(
        id: json['id'] as String,
        appId: json['appId'] as String,
        appVersionId: json['appVersionId'] as String,
        status: json['status'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        queuePosition: json['queuePosition'] as int?,
        estimatedWaitSeconds: json['estimatedWaitSeconds'] as int?,
        aabDownloadUrl: json['aabDownloadUrl'] as String?,
        apkDownloadUrl: json['apkDownloadUrl'] as String?,
        logUrl: json['logUrl'] as String?,
        error: json['error'] as String?,
      );
}

class BuildArtifactResponse {
  const BuildArtifactResponse({
    required this.type,
    required this.downloadUrl,
    required this.expiresAt,
    this.sha256,
    this.playAppSigning,
  });

  final String type;
  final String downloadUrl;
  final DateTime expiresAt;
  final String? sha256;
  final bool? playAppSigning;

  factory BuildArtifactResponse.fromJson(Map<String, dynamic> json) {
    final signing = json['signing'] as Map<String, dynamic>?;
    return BuildArtifactResponse(
      type: json['type'] as String,
      downloadUrl: json['downloadUrl'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      sha256: json['sha256'] as String?,
      playAppSigning: signing?['playAppSigning'] as bool?,
    );
  }
}

class BuildLogsResponse {
  const BuildLogsResponse({
    required this.logUrl,
    required this.expiresAt,
  });

  final String logUrl;
  final DateTime expiresAt;

  factory BuildLogsResponse.fromJson(Map<String, dynamic> json) =>
      BuildLogsResponse(
        logUrl: json['logUrl'] as String,
        expiresAt: DateTime.parse(json['expiresAt'] as String),
      );
}
