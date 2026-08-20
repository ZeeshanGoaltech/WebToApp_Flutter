import 'package:get/get.dart';
import 'package:web_to_app/core/api/api_client.dart';
import 'package:web_to_app/data/models/app_models.dart';

class AppsRepository extends GetxService {
  AppsRepository(this._client);

  final ApiClient _client;

  Future<List<AppSummary>> listApps({int limit = 50}) async {
    final json = await _client.get<Map<String, dynamic>>(
      '/v1/apps',
      queryParameters: {'limit': limit},
      parser: (data) => data as Map<String, dynamic>,
    );
    final apps = json['apps'] as List<dynamic>? ?? [];
    return apps
        .map((e) => AppSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AppSummary> getApp(String appId) async {
    final json = await _client.get<Map<String, dynamic>>(
      '/v1/apps/$appId',
      parser: (data) => data as Map<String, dynamic>,
    );
    return AppSummary.fromJson(json['app'] as Map<String, dynamic>);
  }

  Future<OkResponse> updateApp({
    required String appId,
    String? name,
    String? status,
  }) {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (status != null) data['status'] = status;

    return _client.patch<OkResponse>(
      '/v1/apps/$appId',
      data: data,
      parser: (json) => OkResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<void> archiveApp(String appId) => _client.delete('/v1/apps/$appId');

  Future<CreateAppResponse> createApp({
    required String name,
    required String androidPackage,
    required Map<String, dynamic> config,
  }) => _client.post<CreateAppResponse>(
    '/v1/apps',
    data: {'name': name, 'androidPackage': androidPackage, 'config': config},
    parser: (json) => CreateAppResponse.fromJson(json as Map<String, dynamic>),
  );

  Future<PutConfigResponse> putConfig({
    required String appId,
    required Map<String, dynamic> config,
  }) => _client.put<PutConfigResponse>(
    '/v1/apps/$appId/config',
    data: {'config': config},
    parser: (json) => PutConfigResponse.fromJson(json as Map<String, dynamic>),
  );

  Future<GetConfigResponse> getConfig(String appId) =>
      _client.get<GetConfigResponse>(
        '/v1/apps/$appId/config',
        parser: (json) =>
            GetConfigResponse.fromJson(json as Map<String, dynamic>),
      );

  Future<AppVersionDto?> getLatestVersion(String appId) async {
    final config = await getConfig(appId);
    return config.version;
  }

  Future<List<AppVersionDto>> listConfigVersions(String appId) async {
    final response = await _client.get<VersionsListResponse>(
      '/v1/apps/$appId/config/versions',
      parser: (json) =>
          VersionsListResponse.fromJson(json as Map<String, dynamic>),
    );
    return response.versions;
  }

  Future<OwnershipVerifyResponse> verifyOwnership(String appId) =>
      _client.post<OwnershipVerifyResponse>(
        '/v1/apps/$appId/ownership/verify',
        parser: (json) =>
            OwnershipVerifyResponse.fromJson(json as Map<String, dynamic>),
      );

  Future<PreflightResponse> preflight(String appId) =>
      _client.get<PreflightResponse>(
        '/v1/apps/$appId/preflight',
        parser: (json) =>
            PreflightResponse.fromJson(json as Map<String, dynamic>),
      );
}
