import 'dart:io';

import 'package:dio/dio.dart' as http;
import 'package:get/get.dart';
import 'package:web_to_app/core/api/api_client.dart';
import 'package:web_to_app/data/models/signing_models.dart';

class SigningRepository extends GetxService {
  SigningRepository(this._client);

  final ApiClient _client;

  Future<SigningDto> getSigning(String appId) => _client.get<SigningDto>(
        '/v1/apps/$appId/signing',
        parser: (json) => SigningDto.fromJson(json as Map<String, dynamic>),
      );

  Future<SigningDto> setSigning(String appId, SetSigningRequest request) =>
      _client.put<SigningDto>(
        '/v1/apps/$appId/signing',
        data: request.toJson(),
        parser: (json) => SigningDto.fromJson(json as Map<String, dynamic>),
      );

  Future<void> uploadKeystoreFile({
    required String appId,
    required String filePath,
  }) async {
    final file = File(filePath);
    final formData = http.FormData.fromMap({
      'file': await http.MultipartFile.fromFile(
        file.path,
        filename: file.uri.pathSegments.last,
      ),
    });

    await _client.postMultipart<void>(
      '/v1/apps/$appId/signing/keystore',
      formData: formData,
    );
  }
}
