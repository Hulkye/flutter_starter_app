import '../enum/http_method.dart';

/// 自定义重试判定函数 —— 返回 `true` 允许继续重试。
typedef RetryPredicate = bool Function(
  HttpMethod method,
  int? statusCode,
  Object? error,
  int attempt,
);

/// 精细化的重试策略，支持指数退避与抖动。
class RetryPolicy {
  const RetryPolicy({
    this.maxAttempts = 0,
    this.delay = const Duration(milliseconds: 300),
    this.backoffFactor = 1.6,
    this.maxDelay = const Duration(seconds: 5),
    this.maxElapsedTime,
    this.jitterFactor = 0,
    this.retryOnStatusCodes = const {408, 429, 500, 502, 503, 504},
    this.retryOnMethods = const {
      HttpMethod.get,
      HttpMethod.head,
      HttpMethod.options,
    },
    this.retryOnErrors = const <Type>{},
    this.retryIf,
  });

  /// 最大重试次数。
  final int maxAttempts;

  /// 首次重试的基础等待时长。
  final Duration delay;

  /// 指数退避乘数。
  final double backoffFactor;

  /// 单次重试延迟的上限。
  final Duration maxDelay;

  /// 总重试耗时的硬上限。
  final Duration? maxElapsedTime;

  /// 抖动比例，0–1。例如 0.1 表示 ±10% 的随机抖动。
  final double jitterFactor;

  /// 允许重试的 HTTP 状态码集合。
  final Set<int> retryOnStatusCodes;

  /// 允许重试的 HTTP 方法集合。
  final Set<HttpMethod> retryOnMethods;

  /// 允许重试的异常类型集合（无状态码时生效）。
  final Set<Type> retryOnErrors;

  /// 完全自定义的重试门禁。
  final RetryPredicate? retryIf;

  /// 判断是否允许再次重试。
  bool canRetry(
    HttpMethod method,
    int? statusCode,
    Object? error,
    int attempt,
    Duration elapsed,
  ) {
    if (attempt >= maxAttempts) return false;
    if (!retryOnMethods.contains(method)) return false;
    if (maxElapsedTime != null && elapsed >= maxElapsedTime!) return false;

    if (retryIf != null) {
      return retryIf!(method, statusCode, error, attempt);
    }
    if (statusCode != null && !retryOnStatusCodes.contains(statusCode)) {
      return false;
    }
    if (statusCode == null && retryOnErrors.isNotEmpty && error != null) {
      return retryOnErrors.any((t) => error.runtimeType == t);
    }
    return true;
  }

  /// 计算第 *n* 次（从 1 开始）重试的延迟，
  /// 包含指数退避和确定性抖动。
  Duration nextDelay(int attempt) {
    final exp = attempt <= 0 ? 1.0 : _pow(backoffFactor, attempt).toDouble();
    final base = (delay.inMilliseconds * exp).round();
    final capped = base.clamp(0, maxDelay.inMilliseconds);
    final jitter = jitterFactor <= 0
        ? 0
        : (capped * jitterFactor * _stableJitter(attempt)).round();
    return Duration(milliseconds: capped + jitter);
  }

  // -----------------------------------------------------------------------
  // 内部工具
  // -----------------------------------------------------------------------

  static int _pow(double base, int exp) {
    double result = 1;
    for (int i = 0; i < exp; i++) {
      result *= base;
    }
    return result.round();
  }

  static double _stableJitter(int attempt) {
    final seed = (attempt * 1103515245 + 12345) & 0x7fffffff;
    return seed / 0x7fffffff;
  }

  // -----------------------------------------------------------------------
  // Copy
  // -----------------------------------------------------------------------

  RetryPolicy copyWith({
    int? maxAttempts,
    Duration? delay,
    double? backoffFactor,
    Duration? maxDelay,
    Duration? maxElapsedTime,
    double? jitterFactor,
    Set<int>? retryOnStatusCodes,
    Set<HttpMethod>? retryOnMethods,
    Set<Type>? retryOnErrors,
    RetryPredicate? retryIf,
  }) {
    return RetryPolicy(
      maxAttempts: maxAttempts ?? this.maxAttempts,
      delay: delay ?? this.delay,
      backoffFactor: backoffFactor ?? this.backoffFactor,
      maxDelay: maxDelay ?? this.maxDelay,
      maxElapsedTime: maxElapsedTime ?? this.maxElapsedTime,
      jitterFactor: jitterFactor ?? this.jitterFactor,
      retryOnStatusCodes: retryOnStatusCodes ?? this.retryOnStatusCodes,
      retryOnMethods: retryOnMethods ?? this.retryOnMethods,
      retryOnErrors: retryOnErrors ?? this.retryOnErrors,
      retryIf: retryIf ?? this.retryIf,
    );
  }
}
