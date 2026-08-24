import 'dart:convert';

import 'package:dio/dio.dart' as http;
import 'package:flutter/foundation.dart';

/// Pretty-prints API traffic in debug builds only.
class ApiDebugLogInterceptor extends http.Interceptor {
  ApiDebugLogInterceptor({this.enabled = kDebugMode});

  final bool enabled;

  static const _tag = 'API';
  static const _divider = '────────────────────────────────────────';

  @override
  void onRequest(http.RequestOptions options, http.RequestInterceptorHandler handler) {
    if (enabled) {
      options.extra['_api_log_start'] = DateTime.now().millisecondsSinceEpoch;
      _logBlock([
        '▶ REQUEST',
        '${options.method} ${_fullUrl(options)}',
        if (options.queryParameters.isNotEmpty)
          'Query: ${_pretty(options.queryParameters)}',
        if (options.headers.isNotEmpty)
          'Headers: ${_pretty(_safeHeaders(options.headers))}',
        if (options.data != null) 'Body: ${_formatBody(options.data)}',
      ]);
    }
    handler.next(options);
  }

  @override
  void onResponse(
    http.Response response,
    http.ResponseInterceptorHandler handler,
  ) {
    if (enabled) {
      final started = response.requestOptions.extra['_api_log_start'] as int?;
      final ms = started == null
          ? null
          : DateTime.now().millisecondsSinceEpoch - started;

      _logBlock([
        if (_isPendingBuildLog(response))
          '◀ PENDING'
        else
          '◀ RESPONSE',
        '${response.requestOptions.method} ${_fullUrl(response.requestOptions)}',
        'Status: ${response.statusCode}',
        if (ms != null) 'Duration: ${ms}ms',
        if (_isPendingBuildLog(response))
          'Note: Build logs not uploaded yet — retrying'
        else
          'Body: ${_pretty(response.data)}',
      ]);
    }
    handler.next(response);
  }

  @override
  void onError(http.DioException err, http.ErrorInterceptorHandler handler) {
    if (enabled) {
      final started = err.requestOptions.extra['_api_log_start'] as int?;
      final ms = started == null
          ? null
          : DateTime.now().millisecondsSinceEpoch - started;

      final lines = <String>[
        '✖ ERROR',
        '${err.requestOptions.method} ${_fullUrl(err.requestOptions)}',
        'Type: ${err.type.name}',
        if (err.response?.statusCode != null)
          'Status: ${err.response!.statusCode}',
        if (ms != null) 'Duration: ${ms}ms',
        if (err.response?.data != null)
          'Body: ${_pretty(err.response!.data)}'
        else if (err.message != null)
          'Message: ${err.message}',
      ];
      _logBlock(lines, isError: true);
    }
    handler.next(err);
  }

  static bool _isPendingBuildLog(http.Response response) {
    if (response.statusCode != 404) return false;
    final path = response.requestOptions.path;
    if (!path.endsWith('/logs')) return false;
    final data = response.data;
    if (data is! Map<String, dynamic>) return false;
    final error = data['error'];
    if (error is! Map<String, dynamic>) return false;
    return error['code'] == 'not_found';
  }

  static String _fullUrl(http.RequestOptions options) {
    final base = options.baseUrl.endsWith('/')
        ? options.baseUrl.substring(0, options.baseUrl.length - 1)
        : options.baseUrl;
    final path = options.path.startsWith('/') ? options.path : '/${options.path}';
    return '$base$path';
  }

  static Map<String, dynamic> _safeHeaders(Map<String, dynamic> headers) {
    final safe = Map<String, dynamic>.from(headers);
    final auth = safe['Authorization'] ?? safe['authorization'];
    if (auth is String && auth.startsWith('Bearer ')) {
      final token = auth.substring(7);
      final tail = token.length > 8 ? token.substring(token.length - 8) : token;
      safe['Authorization'] = 'Bearer ***$tail';
    }
    return safe;
  }

  static String _formatBody(dynamic data) {
    if (data is http.FormData) {
      final fields = data.fields.map((e) => '${e.key}=${e.value}').join(', ');
      final files = data.files
          .map((e) => '${e.key}:${e.value.filename ?? 'file'}')
          .join(', ');
      return 'FormData(fields=[$fields], files=[$files])';
    }
    return _pretty(data);
  }

  static String _pretty(dynamic value) {
    if (value == null) return 'null';
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
        try {
          return const JsonEncoder.withIndent('  ').convert(jsonDecode(trimmed));
        } catch (_) {}
      }
      return value;
    }
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } catch (_) {
      return value.toString();
    }
  }

  static void _logBlock(List<String> lines, {bool isError = false}) {
    final buffer = StringBuffer()
      ..writeln(_divider)
      ..writeln('[$_tag]');
    for (final line in lines) {
      buffer.writeln(line);
    }
    buffer.writeln(_divider);
    debugPrint(buffer.toString());
  }
}
