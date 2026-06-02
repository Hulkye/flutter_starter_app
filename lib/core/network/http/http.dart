/// HTTP 网络层 —— 基于 Dio 的企业级封装。
///
/// ## 架构亮点
///
/// - **抽象接口**：`BaseHttpClient` 使上层不依赖 Dio，方便单测 mock 和底层替换。
/// - **一等请求/响应模型**：`HttpRequest<T>` / `HttpResponse<T>` 承载完整上下文。
/// - **Dio-无关拦截器链**：`HttpInterceptor` + `InterceptorChain`，请求顺序、响应逆序。
/// - **内置拦截器**：认证注入、业务状态码校验、抓包事件，开箱即用。
/// - **缓存系统**：6 种策略（cacheFirst / networkFirst / SWR 等）+ 内存/磁盘双存储。
/// - **Mock 系统**：`HttpMockAdapter` 抽象，方便测试拦截。
/// - **结构化日志**：`HttpLogger` 抽象 + 默认 `package:logger` 实现。
/// - **高级重试**：指数退避、jitter、最大耗时、自定义断言。
/// - **批量请求**：`sendAll` 并发 + 混合自定义闭包。
///
/// ## 快速开始
///
/// ```dart
/// final client = HttpClient(
///   config: HttpConfig(
///     baseUrl: 'https://api.example.com',
///     defaultRetryPolicy: RetryPolicy(maxAttempts: 3),
///     defaultCachePolicy: CachePolicy.cacheFirst,
///   ),
///   authConfig: HttpAuthConfig(
///     headerMapProvider: () async => {'Authorization': 'Bearer $token'},
///     onAuthFailed: () async => logout(),
///   ),
///   responseConfig: HttpResponseConfig(
///     defaultSuccessCode: 0,
///   ),
/// );
///
/// final user = await client.get<User>(
///   '/user/me',
///   parser: (data) => User.fromJson(data),
///   cachePolicy: CachePolicy.staleWhileRevalidate,
/// );
/// ```
library;

// 核心
export 'base_http_client.dart';
export 'http_client.dart';

// 请求 / 响应 / 异常
export 'request/http_request.dart';
export 'response/http_response.dart';
export 'response/api_response.dart';
export 'error/http_exception.dart';

// 枚举
export 'enum/http_method.dart';
export 'enum/cache_policy.dart';
export 'enum/http_error_type.dart';

// 配置
export 'config/http_config.dart';
export 'config/http_response_config.dart';
export 'config/http_auth_config.dart';
export 'config/http_hint_config.dart';
export 'config/retry_policy.dart';
export 'config/http_security_config.dart';

// 拦截器
export 'interceptor/http_interceptor.dart';
export 'interceptor/interceptor_chain.dart';
export 'interceptor/auth_interceptor.dart';
export 'interceptor/business_status_interceptor.dart';
export 'interceptor/exception_capture_interceptor.dart';
export 'interceptor/packet_capture_interceptor.dart';

// 缓存
export 'cache/cache_store.dart';
export 'cache/http_cache_entry.dart';
export 'cache/http_cache_info.dart';

// Mock
export 'mock/http_mock.dart';

// 日志
export 'logging/http_logger.dart';

// 批量请求
export 'batch/network_batch_request.dart';

// 工具
export 'shared/http_cache_key_builder.dart';
