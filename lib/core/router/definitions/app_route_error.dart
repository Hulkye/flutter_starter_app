/// 框架无关的路由错误上下文。
final class AppRouteError {
  const AppRouteError({
    required this.location,
    required this.message,
    this.exception,
  });

  /// 发生错误时请求访问的完整 location。
  final String location;

  /// 错误描述，可供日志或调试界面使用。
  final String message;

  /// 原始异常；可能包含框架相关类型，仅供诊断使用。
  final Object? exception;
}
