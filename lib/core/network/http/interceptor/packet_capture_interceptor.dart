import '../error/http_exception.dart';
import '../request/http_request.dart';
import '../response/http_response.dart';
import 'http_interceptor.dart';

/// 抓包事件回调签名。
typedef PacketCaptureCallback = void Function(PacketCaptureEvent event);

/// 抓包事件 —— 在请求 / 响应 / 错误各阶段触发。
class PacketCaptureEvent {
  const PacketCaptureEvent({
    required this.stage,
    required this.time,
    required this.request,
    this.response,
    this.error,
    this.exception,
  });

  /// 阶段标识：`request` / `response` / `error`。
  final String stage;

  /// 事件时间戳。
  final DateTime time;

  /// 对应的请求信息。
  final HttpRequest<dynamic> request;

  /// 响应数据（response 阶段）。
  final HttpResponse<dynamic>? response;

  /// 原始异常（error 阶段，来自 Dio / 网络层）。
  final Object? error;

  /// 转换后的 HttpException（error 阶段）。
  final HttpException? exception;
}

/// 抓包事件拦截器 —— 提供统一回调，方便对接自定义抓包面板。
///
/// 用法：
/// ```dart
/// HttpClient(
///   config: HttpConfig(enablePacketCapture: true),
///   onPacketCapture: (event) {
///     debugPrint('[${event.stage}] ${event.request.method} ${event.request.path}');
///   },
/// )
/// ```
class PacketCaptureInterceptor extends HttpInterceptor {
  PacketCaptureInterceptor({
    required this.enablePacketCapture,
    this.onCapture,
  });

  /// 全局开关（来自 [HttpConfig.enablePacketCapture]）。
  final bool enablePacketCapture;

  /// 外部回调。
  final PacketCaptureCallback? onCapture;

  @override
  Future<HttpRequest<dynamic>> onRequest(HttpRequest<dynamic> request) async {
    _emit(PacketCaptureEvent(
      stage: 'request',
      time: DateTime.now(),
      request: request,
    ));
    return request;
  }

  @override
  Future<HttpResponse<dynamic>> onResponse(
    HttpRequest<dynamic> request,
    HttpResponse<dynamic> response,
  ) async {
    _emit(PacketCaptureEvent(
      stage: 'response',
      time: DateTime.now(),
      request: request,
      response: response,
    ));
    return response;
  }

  @override
  Future<HttpException> onError(
    HttpRequest<dynamic> request,
    HttpException error,
  ) async {
    _emit(PacketCaptureEvent(
      stage: 'error',
      time: DateTime.now(),
      request: request,
      exception: error,
    ));
    return error;
  }

  void _emit(PacketCaptureEvent event) {
    if (!enablePacketCapture) return;
    onCapture?.call(event);
  }
}
