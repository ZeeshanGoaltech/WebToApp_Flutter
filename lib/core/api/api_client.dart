import 'package:dio/dio.dart' as http;
import 'package:get/get.dart';
import 'package:web_to_app/core/api/api_config.dart';
import 'package:web_to_app/core/api/api_exception.dart';
import 'package:web_to_app/core/api/api_log_interceptor.dart';
import 'package:web_to_app/core/services/token_storage.dart';

class ApiClient extends GetxService {
  ApiClient(this._tokenStorage);

  final TokenStorage _tokenStorage;
  late final http.Dio _dio;
  Future<bool>? _refreshFuture;

  http.Dio get dio => _dio;

  Future<ApiClient> init() async {
    _dio = http.Dio(
      http.BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {'Accept': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      http.InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _tokenStorage.accessToken;
          if (!_isRefreshPath(options.path) &&
              token != null &&
              token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

    if (ApiConfig.enableApiLogs) {
      _dio.interceptors.add(ApiDebugLogInterceptor(enabled: true));
    }

    return this;
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? parser,
  }) => _request('GET', path, queryParameters: queryParameters, parser: parser);

  /// Returns null when the server responds with 404 (e.g. logs not ready yet).
  Future<T?> getOrNullIfNotFound<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? parser,
  }) =>
      _requestOrNullOnNotFound<T>(
        'GET',
        path,
        queryParameters: queryParameters,
        parser: parser,
      );

  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    T Function(dynamic json)? parser,
  }) => _request(
    'POST',
    path,
    data: data,
    queryParameters: queryParameters,
    headers: headers,
    parser: parser,
  );

  Future<T> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic json)? parser,
  }) => _request('PUT', path, data: data, parser: parser);

  Future<T> patch<T>(
    String path, {
    dynamic data,
    T Function(dynamic json)? parser,
  }) => _request('PATCH', path, data: data, parser: parser);

  Future<void> delete(String path) async {
    await _request<dynamic>('DELETE', path);
  }

  Future<T> postMultipart<T>(
    String path, {
    required http.FormData formData,
    T Function(dynamic json)? parser,
  }) => _request('POST', path, data: formData, parser: parser);

  Future<T?> _requestOrNullOnNotFound<T>(
    String method,
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    T Function(dynamic json)? parser,
  }) async {
    final canRefresh = !_skipsAuthRefresh(path);
    if (canRefresh) {
      await _refreshIfExpiringSoon();
    }

    try {
      return await _sendOrNullOnNotFound<T>(
        method,
        path,
        data: data,
        queryParameters: queryParameters,
        headers: headers,
        parser: parser,
      );
    } on http.DioException catch (e) {
      if (canRefresh && e.response?.statusCode == 401) {
        final refreshed = await _refreshAccessToken();
        if (refreshed) {
          try {
            return await _sendOrNullOnNotFound<T>(
              method,
              path,
              data: data,
              queryParameters: queryParameters,
              headers: headers,
              parser: parser,
            );
          } on http.DioException catch (retryError) {
            throw _mapDioError(retryError);
          }
        }
      }
      throw _mapDioError(e);
    }
  }

  Future<T> _request<T>(
    String method,
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    T Function(dynamic json)? parser,
  }) async {
    final canRefresh = !_skipsAuthRefresh(path);
    if (canRefresh) {
      await _refreshIfExpiringSoon();
    }

    try {
      return await _send<T>(
        method,
        path,
        data: data,
        queryParameters: queryParameters,
        headers: headers,
        parser: parser,
      );
    } on http.DioException catch (e) {
      if (canRefresh && e.response?.statusCode == 401) {
        final refreshed = await _refreshAccessToken();
        if (refreshed) {
          try {
            return await _send<T>(
              method,
              path,
              data: data,
              queryParameters: queryParameters,
              headers: headers,
              parser: parser,
            );
          } on http.DioException catch (retryError) {
            throw _mapDioError(retryError);
          }
        }
      }
      throw _mapDioError(e);
    }
  }

  Future<T> _send<T>(
    String method,
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    T Function(dynamic json)? parser,
  }) async {
    final response = await _dio.request<dynamic>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: http.Options(method: method, headers: headers),
    );

    final body = response.data;
    if (parser != null) {
      return parser(body);
    }
    return body as T;
  }

  Future<T?> _sendOrNullOnNotFound<T>(
    String method,
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    T Function(dynamic json)? parser,
  }) async {
    final response = await _dio.request<dynamic>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: http.Options(
        method: method,
        headers: headers,
        validateStatus: (status) =>
            status != null && (status < 400 || status == 404),
      ),
    );

    if (response.statusCode == 404) {
      return null;
    }

    final body = response.data;
    if (parser != null) {
      return parser(body);
    }
    return body as T;
  }

  Future<void> _refreshIfExpiringSoon() async {
    if (!_tokenStorage.hasTokens) return;

    final expiresAt = _tokenStorage.accessExpiresAt;
    if (expiresAt == null) return;

    final refreshAt = DateTime.now().millisecondsSinceEpoch + 30000;
    if (expiresAt <= refreshAt) {
      await _refreshAccessToken();
    }
  }

  Future<bool> _refreshAccessToken() {
    final inFlight = _refreshFuture;
    if (inFlight != null) return inFlight;

    final future = _performTokenRefresh();
    _refreshFuture = future;
    future.whenComplete(() => _refreshFuture = null);
    return future;
  }

  Future<bool> _performTokenRefresh() async {
    final refreshToken = _tokenStorage.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      await _tokenStorage.clear();
      return false;
    }

    try {
      final response = await _dio.post<dynamic>(
        '/v1/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final body = response.data as Map<String, dynamic>;
      final tokens = body['tokens'] as Map<String, dynamic>;
      await _tokenStorage.saveTokens(
        accessToken: tokens['accessToken'] as String,
        refreshToken: tokens['refreshToken'] as String,
        expiresInSec: tokens['expiresInSec'] as int,
      );
      return true;
    } on http.DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokenStorage.clear();
      }
      return false;
    } catch (_) {
      await _tokenStorage.clear();
      return false;
    }
  }

  bool _skipsAuthRefresh(String path) =>
      path == '/v1/auth/login' ||
      path == '/v1/auth/signup' ||
      path == '/v1/auth/refresh' ||
      path == '/v1/auth/logout';

  bool _isRefreshPath(String path) => path == '/v1/auth/refresh';

  ApiException _mapDioError(http.DioException e) {
    final response = e.response;
    if (response?.data is Map<String, dynamic>) {
      return ApiException.fromResponse(
        statusCode: response!.statusCode ?? 0,
        body: response.data as Map<String, dynamic>,
      );
    }

    if (e.type == http.DioExceptionType.connectionTimeout ||
        e.type == http.DioExceptionType.receiveTimeout ||
        e.type == http.DioExceptionType.connectionError) {
      return ApiException.network('network_error_check'.tr);
    }

    return ApiException(
      code: 'internal_error',
      message: e.message ?? 'request_failed'.tr,
      statusCode: response?.statusCode,
    );
  }
}
