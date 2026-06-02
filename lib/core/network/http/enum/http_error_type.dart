/// HTTP 统一错误类型枚举。
enum HttpErrorType {
  /// 请求被取消。
  cancel,

  /// 请求超时。
  timeout,

  /// 网络连接异常。
  network,

  /// 缓存相关错误。
  cache,

  /// 未授权（HTTP 401 或 Token 过期）。
  unauthorized,

  /// 无权限（HTTP 403）。
  forbidden,

  /// 资源不存在（HTTP 404）。
  notFound,

  /// 服务端错误（HTTP 5xx 或业务逻辑错误）。
  server,

  /// 响应状态码异常。
  badResponse,

  /// 数据解析 / 反序列化失败。
  parse,

  /// 未知错误。
  unknown,
}
