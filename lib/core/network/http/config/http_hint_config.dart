/// 可定制的用户可见错误提示文案。
///
/// 每个字段为 `null` 时自动回退为异常自带的默认消息，
/// 因此只需设置你希望覆盖的项即可。
class HttpHintConfig {
  const HttpHintConfig({
    this.networkErrorHint,
    this.serverErrorHint,
    this.unknownHint,
    this.timeoutHint,
    this.reqErrorHint,
    this.dataParseHint,
  });

  /// 网络 / 连接异常时的提示。
  final String? networkErrorHint;

  /// 服务端 / 业务逻辑错误时的提示。
  final String? serverErrorHint;

  /// 未知错误时的提示。
  final String? unknownHint;

  /// 超时错误时的提示。
  final String? timeoutHint;

  /// 请求构造错误时的提示。
  final String? reqErrorHint;

  /// 响应数据解析失败时的提示。
  final String? dataParseHint;

  HttpHintConfig copyWith({
    String? networkErrorHint,
    String? serverErrorHint,
    String? unknownHint,
    String? timeoutHint,
    String? reqErrorHint,
    String? dataParseHint,
  }) {
    return HttpHintConfig(
      networkErrorHint: networkErrorHint ?? this.networkErrorHint,
      serverErrorHint: serverErrorHint ?? this.serverErrorHint,
      unknownHint: unknownHint ?? this.unknownHint,
      timeoutHint: timeoutHint ?? this.timeoutHint,
      reqErrorHint: reqErrorHint ?? this.reqErrorHint,
      dataParseHint: dataParseHint ?? this.dataParseHint,
    );
  }
}
