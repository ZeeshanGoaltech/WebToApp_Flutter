import 'package:get/get.dart';
import 'package:web_to_app/core/api/api_client.dart';
import 'package:web_to_app/data/models/build_models.dart';

class BuildsRepository extends GetxService {
  BuildsRepository(this._client);

  final ApiClient _client;

  Future<BuildDto> enqueueBuild({
    required String appId,
    required String appVersionId,
    required String idempotencyKey,
  }) async {
    return _client.post<BuildDto>(
      '/v1/apps/$appId/builds',
      data: {'appVersionId': appVersionId},
      headers: {'Idempotency-Key': idempotencyKey},
      parser: (json) => BuildDto.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<BuildDto> getBuild(String buildId) => _client.get<BuildDto>(
        '/v1/builds/$buildId',
        parser: (json) => BuildDto.fromJson(json as Map<String, dynamic>),
      );

  Future<List<BuildDto>> listBuilds(String appId) async {
    final json = await _client.get<Map<String, dynamic>>(
      '/v1/apps/$appId/builds',
      parser: (data) => data as Map<String, dynamic>,
    );
    final builds = json['builds'] as List<dynamic>? ?? [];
    return builds
        .map((e) => BuildDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<BuildArtifactResponse> getArtifact({
    required String buildId,
    required String type,
  }) =>
      _client.get<BuildArtifactResponse>(
        '/v1/builds/$buildId/artifacts/$type',
        parser: (json) =>
            BuildArtifactResponse.fromJson(json as Map<String, dynamic>),
      );

  Future<BuildLogsResponse> getLogs(String buildId) =>
      _client.get<BuildLogsResponse>(
        '/v1/builds/$buildId/logs',
        parser: (json) =>
            BuildLogsResponse.fromJson(json as Map<String, dynamic>),
      );

  Future<void> cancelBuild(String buildId) async {
    await _client.post<void>('/v1/builds/$buildId/cancel');
  }
}
