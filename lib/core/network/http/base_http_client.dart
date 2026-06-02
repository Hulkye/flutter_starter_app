import 'package:dio/dio.dart';

import 'batch/network_batch_request.dart';
import 'config/http_config.dart';
import 'config/http_security_config.dart';
import 'config/retry_policy.dart';
import 'enum/cache_policy.dart';
import 'interceptor/http_interceptor.dart';
import 'mock/http_mock.dart';
import 'request/http_request.dart';

/// HTTP 客户端抽象接口。
///
/// 定义完整的网络层契约，使上层业务代码不依赖具体实现（Dio / http / ...）。
/// 也为单元测试提供了 mock 接入点——测试时只需实现此接口即可。
abstract class BaseHttpClient {
  // -----------------------------------------------------------------------
  // 生命周期
  // -----------------------------------------------------------------------

  /// 释放客户端资源（关闭连接池、清理缓存等）。
  void dispose();

  // -----------------------------------------------------------------------
  // 核心请求方法
  // -----------------------------------------------------------------------

  /// 发起泛型请求（底层统一入口）。
  Future<T> request<T>(HttpRequest<T> request);

  /// GET 请求。
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    ResponseType? responseType,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    bool? followRedirects,
    bool? receiveDataWhenStatusError,
    bool Function(int? statusCode)? validateStatus,
    bool? loggingEnabled,
    CachePolicy cachePolicy = CachePolicy.noCache,
    Duration? cacheTtl,
    RetryPolicy? retryPolicy,
    T Function(dynamic data)? parser,
  });

  /// POST 请求。
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    ResponseType? responseType,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    bool? followRedirects,
    bool? receiveDataWhenStatusError,
    bool Function(int? statusCode)? validateStatus,
    bool? loggingEnabled,
    RetryPolicy? retryPolicy,
    T Function(dynamic data)? parser,
  });

  /// PUT 请求。
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    ResponseType? responseType,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    bool? followRedirects,
    bool? receiveDataWhenStatusError,
    bool Function(int? statusCode)? validateStatus,
    bool? loggingEnabled,
    RetryPolicy? retryPolicy,
    T Function(dynamic data)? parser,
  });

  /// DELETE 请求。
  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    ResponseType? responseType,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    bool? followRedirects,
    bool? receiveDataWhenStatusError,
    bool Function(int? statusCode)? validateStatus,
    bool? loggingEnabled,
    RetryPolicy? retryPolicy,
    T Function(dynamic data)? parser,
  });

  /// PATCH 请求。
  Future<T> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    ResponseType? responseType,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    bool? followRedirects,
    bool? receiveDataWhenStatusError,
    bool Function(int? statusCode)? validateStatus,
    bool? loggingEnabled,
    RetryPolicy? retryPolicy,
    T Function(dynamic data)? parser,
  });

  /// 文件上传。
  Future<T> upload<T>(
    String path, {
    required List<MultipartFile> files,
    Map<String, dynamic>? data,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    bool? followRedirects,
    bool? receiveDataWhenStatusError,
    bool Function(int? statusCode)? validateStatus,
    bool? loggingEnabled,
    RetryPolicy? retryPolicy,
    T Function(dynamic data)? parser,
  });

  /// 文件下载。
  Future<T> download<T>(
    String path,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    bool? followRedirects,
    bool? receiveDataWhenStatusError,
    bool Function(int? statusCode)? validateStatus,
    bool? loggingEnabled,
    RetryPolicy? retryPolicy,
    T Function(dynamic data)? parser,
  });

  /// 批量并发请求。
  Future<List<T>> sendAll<T>(List<NetworkBatchRequest<T>> requests);

  // -----------------------------------------------------------------------
  // 拦截器管理
  // -----------------------------------------------------------------------

  /// 添加拦截器。
  void addInterceptor(HttpInterceptor interceptor);

  /// 批量添加。
  void addInterceptors(List<HttpInterceptor> interceptors);

  /// 移除拦截器。
  void removeInterceptor(HttpInterceptor interceptor);

  // -----------------------------------------------------------------------
  // 配置管理
  // -----------------------------------------------------------------------

  /// 替换完整配置。
  void updateConfig(HttpConfig config);

  /// 动态修改 baseUrl。
  void setBaseUrl(String baseUrl);

  /// 动态修改全局 Header。
  void setHeaders(Map<String, String> headers);

  /// 动态修改超时。
  void setTimeout(Duration connectTimeout, Duration receiveTimeout);

  /// 动态修改安全配置（证书校验等）。
  void setSecurityConfig(HttpSecurityConfig securityConfig);

  /// 动态修改重试策略。
  void setRetryPolicy(RetryPolicy retryPolicy);

  /// 开关日志。
  void setLoggingEnabled(bool enabled);

  /// 开关 Mock 模式。
  void setMockEnabled(bool enabled);

  /// 设置 Mock 适配器。
  void setMockAdapter(HttpMockAdapter? adapter);

  // -----------------------------------------------------------------------
  // 工具方法
  // -----------------------------------------------------------------------

  /// 取消请求。
  void cancelRequests({CancelToken? token});

  /// 创建取消令牌。
  CancelToken createCancelToken();

  /// 清空缓存（可指定 key）。
  Future<void> clearCache({String? key});

  /// 获取缓存统计信息。
  Future<Map<String, dynamic>> getCacheInfo();
}
