/// API 业务异常。
class ApiException implements Exception {
  const ApiException({required this.code, this.message});

  final int code;
  final String? message;

  @override
  String toString() => 'ApiException(code: $code, message: $message)';
}

/// 统一 API 响应模型。
///
/// 对应后端 JSON 响应格式：
/// ```json
/// { "code": 0, "message": "success", "data": { ... } }
/// ```
class ApiResponse<T> {
  const ApiResponse({
    required this.code,
    this.message,
    this.data,
  });

  final int code;
  final String? message;
  final T? data;

  bool get isSuccess => code == 0;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic)? fromJsonT,
  }) {
    return ApiResponse<T>(
      code: json['code'] as int? ?? -1,
      message: json['message'] as String?,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
    );
  }
}
