import 'dart:io';

import 'package:dio/dio.dart' as http;import 'package:get/get.dart';
import 'package:web_to_app/core/api/api_client.dart';
import 'package:web_to_app/data/models/asset_models.dart';

class AssetsRepository extends GetxService {
  AssetsRepository(this._client);

  final ApiClient _client;

  Future<AssetUploadResponse> uploadImage({
    required String appId,
    required String filePath,
    required String type,
  }) async {
    final file = File(filePath);
    final formData = http.FormData.fromMap({
      'file': await http.MultipartFile.fromFile(
        file.path,
        filename: file.uri.pathSegments.last,
      ),
      'type': type,
    });

    return _client.postMultipart<AssetUploadResponse>(
      '/v1/apps/$appId/assets/upload',
      formData: formData,
      parser: (json) =>
          AssetUploadResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<List<AssetListItem>> listAssets(String appId) async {
    final json = await _client.get<Map<String, dynamic>>(
      '/v1/apps/$appId/assets',
      parser: (data) => data as Map<String, dynamic>,
    );
    final assets = json['assets'] as List<dynamic>? ?? [];
    return assets
        .map((e) => AssetListItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
