class ApiException implements Exception {
  ApiException({
    required this.code,
    required this.message,
    this.requestId,
    this.statusCode,
    this.details,
  });

  final String code;
  final String message;
  final String? requestId;
  final int? statusCode;
  final dynamic details;

  factory ApiException.fromResponse({
    required int statusCode,
    required Map<String, dynamic> body,
  }) {
    final error = body['error'] as Map<String, dynamic>? ?? {};
    return ApiException(
      code: error['code'] as String? ?? 'internal_error',
      message: error['message'] as String? ?? 'Request failed',
      requestId: error['requestId'] as String?,
      statusCode: statusCode,
      details: error['details'],
    );
  }

  factory ApiException.network(String message) => ApiException(
        code: 'network_error',
        message: message,
      );

  @override
  String toString() => 'ApiException($code): $message';
}
