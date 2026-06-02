import '../enum/http_error_type.dart';
import '../request/http_request.dart';

/// 统一 HTTP 异常。
///
/// 单一异常类 + [HttpErrorType] 枚举，避免继承爆炸。调用方通过 [type]
///（或 [statusCode] / [businessCode]）来判断错误类型 ——
/// 既保持公共 API 的精简，又不失表达力。
class HttpException implements Exception {
  const HttpException({
    required this.type,
    required this.message,
    this.statusCode,
    this.businessCode,
    this.data,
    this.uri,
    this.originalError,
    this.request,
  });

  /// 高层错误分类。
  final HttpErrorType type;

  /// 人类可读的错误描述（可通过 [HttpHintConfig] 覆盖）。
  final String message;

  /// HTTP 状态码（来自 HTTP 响应时）。
  final int? statusCode;

  /// 业务级错误码 —— 从响应信封中提取（由 [BusinessStatusInterceptor] 设置）。
  final int? businessCode;

  /// 原始响应数据或错误 payload。
  final dynamic data;

  /// 触发错误的请求 URI。
  final Uri? uri;

  /// 底层原始异常（如 DioException、SocketException）。
  final Object? originalError;

  /// 触发此错误的请求。
  final HttpRequest<dynamic>? request;

  @override
  String toString() {
    return 'HttpException('
        'type: $type, '
        'statusCode: $statusCode, '
        'businessCode: $businessCode, '
        'message: $message, '
        'uri: $uri)';
  }
}
