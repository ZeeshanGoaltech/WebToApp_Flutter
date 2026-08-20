import 'package:get/get.dart';
import 'package:web_to_app/core/api/api_client.dart';

class PushRepository extends GetxService {
  PushRepository(this._client);

  final ApiClient _client;

  Future<void> registerFcmToken(String token) => _client.post<void>(
    '/v1/auth/fcm-token',
    data: {'token': token},
  );
}
