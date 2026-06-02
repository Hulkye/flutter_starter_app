abstract final class DurationConst {
  static const Duration durationXS = Duration(milliseconds: 100);
  static const Duration durationS = Duration(milliseconds: 200);
  static const Duration durationM = Duration(milliseconds: 300);
  static const Duration durationL = Duration(milliseconds: 500);
  static const Duration durationXL = Duration(milliseconds: 800);
  static const Duration durationXXL = Duration(milliseconds: 1200);
  static const Duration durationXXXL = Duration(milliseconds: 1500);

  // 页面过渡
  static const Duration pageTransition = Duration(milliseconds: 300);
  // 模态框过渡
  static const Duration modalTransition = Duration(milliseconds: 250);
  // 输入框防抖
  static const Duration debounceInput = Duration(milliseconds: 500);

  // HTTP 连接超时
  static const int httpConnectTimeoutMs = 20000;
  // HTTP 接收超时
  static const int httpReceiveTimeoutMs = 20000;
  // HTTP 发送超时
  static const int httpSendTimeoutMs = 20000;
  // HTTP 重试次数
  static const int httpRetryCount = 2;
  // HTTP 重试基础延迟
  static const Duration httpRetryDelay = Duration(milliseconds: 300);
}
