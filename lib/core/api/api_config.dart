import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  /// App Builder API — see http://62.171.190.161/docs
  static const String baseUrl = 'http://62.171.190.161';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);

  /// Logs request/response bodies in the debug console.
  static const bool enableApiLogs = kDebugMode;
}
