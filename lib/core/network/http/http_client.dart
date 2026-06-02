import 'dart:async';
import 'dart:io' as io;

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import 'base_http_client.dart';
import 'batch/network_batch_request.dart';
import 'cache/cache_store.dart';
import 'cache/http_cache_entry.dart';
import 'config/http_config.dart';
import 'config/http_security_config.dart';
import 'config/retry_policy.dart';
import 'enum/cache_policy.dart';
import 'enum/http_error_type.dart';
import 'enum/http_method.dart';
import 'error/http_exception.dart';
import 'interceptor/auth_interceptor.dart';
import 'interceptor/business_status_interceptor.dart';
import 'interceptor/exception_capture_interceptor.dart';
import 'interceptor/http_interceptor.dart';
import 'interceptor/interceptor_chain.dart';
import 'interceptor/packet_capture_interceptor.dart';
import 'logging/http_logger.dart';
import 'mock/http_mock.dart';
import 'request/http_request.dart';
import 'response/http_response.dart';
import 'shared/http_cache_key_builder.dart';

/// 基于 Dio 的 [BaseHttpClient] 实现。
///
/// 提供完整的网络层能力：抽象接口、一等请求/响应模型、Dio-无关拦截器链、
/// 内置业务状态码检查、动态认证注入、6 种缓存策略、Mock 系统、结构化日志、
/// 高级重试、批量请求、文件上传下载、抓包回调及代理调试。
class HttpClient implements BaseHttpClient {
  // =======================================================================
  // 构造函数
  // =======================================================================

  /// 创建 HTTP 客户端实例。
  ///
  /// 内置拦截器安装顺序（列表头部 = 请求阶段最先执行，响应/错误阶段最后执行）：
  /// 1. [PacketCaptureInterceptor] — 抓包事件
  /// 2. [AuthInterceptor] — 认证注入（仅在提供 [HttpConfig.authConfig] 时）
  /// 3. [BusinessStatusInterceptor] — 业务状态码校验
  /// 4. [ExceptionCaptureInterceptor] — 网络异常捕获
  /// 5. 用户自定义拦截器（按传入顺序）
  HttpClient({
    Dio? dio,
    HttpConfig? config,
    List<HttpInterceptor> interceptors = const <HttpInterceptor>[],
    HttpCacheStore? memoryCacheStore,
    HttpCacheStore? diskCacheStore,
    HttpMockAdapter? mockAdapter,
    HttpLogger? httpLogger,
    // 可观测性 & 调试
    PacketCaptureCallback? onPacketCapture,
  }) : _dio = dio ?? Dio(),
       _config = config ?? const HttpConfig(),
       _memoryCacheStore = memoryCacheStore ?? MemoryHttpCacheStore(),
       _diskCacheStore = diskCacheStore ?? FileHttpCacheStore(),
       _mockAdapter = mockAdapter,
       _logger = httpLogger ?? DefaultHttpLogger() {
    _dio.options = _config.toBaseOptions();

    // ---- 内置拦截器（在用户拦截器之前插入）-------------------------------
    _builtInInterceptors.add(
      PacketCaptureInterceptor(
        enablePacketCapture: _config.enablePacketCapture,
        onCapture: onPacketCapture,
      ),
    );

    if (_config.authConfig != null) {
      _builtInInterceptors.add(AuthInterceptor(_config.authConfig!));
    }

    _builtInInterceptors.add(
      BusinessStatusInterceptor(
        responseConfig: _config.responseConfig,
        authConfig: _config.authConfig,
        hintConfig: _config.hintConfig,
      ),
    );

    _builtInInterceptors.add(const ExceptionCaptureInterceptor());

    // 用户拦截器
    _interceptors.addAll(interceptors);

    _applyConfig();
  }

  // =======================================================================
  // 私有字段
  // =======================================================================

  final Dio _dio;
  HttpConfig _config;

  /// 内置拦截器（先执行）。
  final List<HttpInterceptor> _builtInInterceptors = <HttpInterceptor>[];

  /// 用户拦截器（后执行）。
  final List<HttpInterceptor> _interceptors = <HttpInterceptor>[];

  /// 合并后的完整拦截器列表（内置 + 用户，惰性拼接）。
  List<HttpInterceptor> get _allInterceptors => [
    ..._builtInInterceptors,
    ..._interceptors,
  ];

  final HttpCacheStore _memoryCacheStore;
  final HttpCacheStore _diskCacheStore;
  HttpMockAdapter? _mockAdapter;
  final HttpLogger _logger;
  bool _isDisposed = false;

  // =======================================================================
  // 公开属性
  // =======================================================================

  /// 底层 Dio 实例（需要 Dio 特定 API 时使用）。
  Dio get dio => _dio;

  // =======================================================================
  // 生命周期
  // =======================================================================

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _dio.close(force: true);
  }

  // =======================================================================
  // 配置应用
  // =======================================================================

  /// 将 [HttpConfig] 同步到 Dio。
  void _applyConfig() {
    _dio.options = _config.toBaseOptions();
    if (_config.userAgent != null) {
      _dio.options.headers['user-agent'] = _config.userAgent!;
    }
    _applyProxyAndSecurity();
  }

  /// 代理 + HTTPS 证书配置（Charles / Proxyman / mitm 抓包调试）。
  void _applyProxyAndSecurity() {
    final adapter = _dio.httpClientAdapter;
    if (adapter is! IOHttpClientAdapter) return;

    adapter.createHttpClient = () {
      final client = io.HttpClient();

      // 代理（Charles / Proxyman / mitm）
      final proxyHost = _config.proxyHost;
      if (proxyHost != null && proxyHost.isNotEmpty) {
        client.findProxy = (uri) => 'PROXY $proxyHost:${_config.proxyPort}';
      }

      // 证书校验
      if (_config.allowBadCertificate ||
          _config.securityConfig.allowInvalidCertificates) {
        client.badCertificateCallback = (cert, host, port) => true;
      } else if (_config.securityConfig.validateCertificate != null) {
        client.badCertificateCallback =
            _config.securityConfig.validateCertificate!;
      }

      return client;
    };
  }

  // =======================================================================
  // 请求规范化 & 拦截器链
  // =======================================================================

  /// 用全局默认值补全请求的缺失字段。
  HttpRequest<T> _normalizeRequest<T>(HttpRequest<T> request) {
    return request.copyWith(
      headers: <String, String>{..._config.headers, ...?request.headers},
      connectTimeout: request.connectTimeout ?? _config.connectTimeout,
      retryPolicy: request.retryPolicy ?? _config.defaultRetryPolicy,
    );
  }

  /// 执行请求拦截器链（顺序）。
  Future<HttpRequest<T>> _applyRequestInterceptors<T>(
    HttpRequest<T> request,
  ) async {
    final chain = InterceptorChain(_allInterceptors);
    return (await chain.runRequest(request)) as HttpRequest<T>;
  }

  /// 执行响应拦截器链（逆序）。
  Future<HttpResponse<dynamic>> _applyResponseInterceptors(
    HttpRequest<dynamic> request,
    HttpResponse<dynamic> response,
  ) {
    return InterceptorChain(_allInterceptors).runResponse(request, response);
  }

  /// 执行错误拦截器链（逆序）。
  Future<HttpException> _applyErrorInterceptors(
    HttpRequest<dynamic> request,
    HttpException error,
  ) {
    return InterceptorChain(_allInterceptors).runError(request, error);
  }

  // =======================================================================
  // Dio Options 构建
  // =======================================================================

  Options _buildOptions(HttpRequest<dynamic> request) {
    return Options(
      method: request.method.name.toUpperCase(),
      responseType: request.responseType ?? ResponseType.json,
      headers: request.headers,
      extra: request.extra,
      sendTimeout: request.sendTimeout ?? _config.sendTimeout,
      receiveTimeout: request.receiveTimeout ?? _config.receiveTimeout,
      followRedirects: request.followRedirects ?? _config.followRedirects,
      receiveDataWhenStatusError:
          request.receiveDataWhenStatusError ??
          _config.receiveDataWhenStatusError,
      validateStatus: request.validateStatus ?? _config.validateStatus,
    );
  }

  // =======================================================================
  // 日志辅助
  // =======================================================================

  bool _isLoggingEnabled(HttpRequest<dynamic> request) {
    return request.loggingEnabled ?? _config.enableLogging;
  }

  void _logRequest(HttpRequest<dynamic> request) {
    if (!_isLoggingEnabled(request)) return;
    _logger.logRequest(request);
  }

  void _logResponse(HttpRequest<dynamic> request, HttpResponse<dynamic> resp) {
    if (!_isLoggingEnabled(request)) return;
    _logger.logResponse(request, resp);
  }

  void _logError(HttpRequest<dynamic> request, Object error) {
    if (!_isLoggingEnabled(request)) return;
    _logger.logError(request, error);
  }

  void _logRetry(
    HttpRequest<dynamic> request, {
    required Object error,
    required int retryCount,
    required Duration delay,
    required Duration elapsed,
    int? statusCode,
  }) {
    if (_logger case final DefaultHttpLogger logger) {
      logger.logRetry(
        request,
        error: error,
        retryCount: retryCount,
        delay: delay,
        elapsed: elapsed,
        statusCode: statusCode,
      );
      return;
    }
    _logError(request, error);
  }

  void _logFailure(
    HttpRequest<dynamic> request, {
    required HttpException error,
    required int retryCount,
    required Duration elapsed,
  }) {
    final observed = HttpException(
      type: error.type,
      message:
          '${error.message} (耗时: ${elapsed.inMilliseconds}ms, 重试: $retryCount次)',
      statusCode: error.statusCode,
      businessCode: error.businessCode,
      data: error.data,
      uri: error.uri,
      originalError: error.originalError,
      request: error.request,
    );
    _logError(request, observed);
  }

  // =======================================================================
  // 可观测性
  // =======================================================================

  HttpResponse<dynamic> _withObservability(
    HttpRequest<dynamic> request,
    HttpResponse<dynamic> response, {
    required Duration duration,
    required int retryCount,
    bool fromMock = false,
  }) {
    return HttpResponse<dynamic>(
      data: response.data,
      statusCode: response.statusCode,
      headers: response.headers,
      extra: <String, dynamic>{
        ...response.extra,
        'durationMs': duration.inMilliseconds,
        'retryCount': retryCount,
        'method': request.method.name.toUpperCase(),
        'path': request.path,
        'fromMock': fromMock,
      },
      fromCache: response.fromCache,
      requestOptions: response.requestOptions ?? request,
    );
  }

  // =======================================================================
  // 缓存
  // =======================================================================

  String _buildCacheKey(HttpRequest<dynamic> request) {
    final builder = _config.cacheKeyBuilder ?? defaultCacheKeyBuilder;
    return builder(request);
  }

  Duration? _cacheTtlFor(HttpRequest<dynamic> request) {
    if (request.cacheTtl != null) return request.cacheTtl;
    switch (request.cachePolicy) {
      case CachePolicy.noCache:
      case CachePolicy.networkOnly:
        return null;
      case CachePolicy.cacheFirst:
      case CachePolicy.networkFirst:
      case CachePolicy.cacheOnly:
      case CachePolicy.staleWhileRevalidate:
        return _config.defaultCacheTtl;
    }
  }

  Future<void> _cleanupExpiredCache() async {
    await _memoryCacheStore.clearExpired();
    await _diskCacheStore.clearExpired();
  }

  Future<HttpCacheEntry?> _readCache(String key) async {
    final mem = await _memoryCacheStore.read(key);
    if (mem != null && !mem.isExpired) return mem;
    final disk = await _diskCacheStore.read(key);
    if (disk != null && !disk.isExpired) {
      await _memoryCacheStore.write(disk); // 回填热数据到内存
      return disk;
    }
    return null;
  }

  Future<void> _writeCache(
    HttpRequest<dynamic> request,
    Response<dynamic> response,
    String key,
  ) async {
    final ttl = _cacheTtlFor(request);
    final entry = HttpCacheEntry(
      key: key,
      data: response.data,
      createdAt: DateTime.now(),
      expiresAt: ttl == null ? null : DateTime.now().add(ttl),
      statusCode: response.statusCode,
      headers: response.headers.map.map((k, v) => MapEntry(k, v.toList())),
      requestSignature: key,
      cachePolicy: request.cachePolicy.name,
    );
    await _memoryCacheStore.write(entry);
    await _diskCacheStore.write(entry);
  }

  // =======================================================================
  // 后台缓存刷新（stale-while-revalidate）
  // =======================================================================

  Future<void> _revalidateCache(HttpRequest<dynamic> request) async {
    try {
      final networkReq = request.copyWith(cachePolicy: CachePolicy.networkOnly);
      final resp = await _executeRawWith(networkReq, () async {
        final dioResp = await _dio.request<dynamic>(
          networkReq.path,
          data: networkReq.data,
          queryParameters: networkReq.queryParameters,
          options: _buildOptions(networkReq),
          cancelToken: networkReq.cancelToken,
          onSendProgress: networkReq.onSendProgress,
          onReceiveProgress: networkReq.onReceiveProgress,
        );
        return HttpResponse<dynamic>(
          data: dioResp.data,
          statusCode: dioResp.statusCode,
          headers: dioResp.headers.map.map((k, v) => MapEntry(k, v.toList())),
          extra: dioResp.extra,
          requestOptions: networkReq,
        );
      }, allowMock: false);
      await _writeCache(
        networkReq,
        Response<dynamic>(
          data: resp.data,
          requestOptions: RequestOptions(path: networkReq.path),
          statusCode: resp.statusCode,
          headers: Headers.fromMap(resp.headers),
        ),
        _buildCacheKey(networkReq),
      );
    } catch (_) {
      // 后台刷新静默失败
    }
  }

  // =======================================================================
  // 异常映射
  // =======================================================================

  HttpException _toHttpException(HttpRequest<dynamic> request, DioException e) {
    final response = e.response;
    final statusCode = response?.statusCode;
    final type = switch (e.type) {
      DioExceptionType.cancel => HttpErrorType.cancel,
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => HttpErrorType.timeout,
      DioExceptionType.badCertificate => HttpErrorType.network,
      DioExceptionType.badResponse => _mapStatusCode(statusCode),
      DioExceptionType.connectionError => HttpErrorType.network,
      DioExceptionType.unknown => HttpErrorType.unknown,
    };

    final hint = _config.hintConfig;
    String message;
    switch (type) {
      case HttpErrorType.timeout:
        message = hint?.timeoutHint ?? e.message ?? '请求超时';
        break;
      case HttpErrorType.network:
        message = hint?.networkErrorHint ?? e.message ?? '网络连接异常';
        break;
      default:
        message = e.message ?? e.error?.toString() ?? 'HTTP 请求失败';
    }

    return HttpException(
      type: type,
      message: message,
      statusCode: statusCode,
      data: response?.data,
      uri: e.requestOptions.uri,
      originalError: e,
      request: request,
    );
  }

  HttpErrorType _mapStatusCode(int? statusCode) {
    if (statusCode == 401) return HttpErrorType.unauthorized;
    if (statusCode == 403) return HttpErrorType.forbidden;
    if (statusCode == 404) return HttpErrorType.notFound;
    if (statusCode != null && statusCode >= 500) return HttpErrorType.server;
    return HttpErrorType.badResponse;
  }

  // =======================================================================
  // 数据解码
  // =======================================================================

  Future<T> _decodeResponse<T>(
    HttpRequest<T> request,
    HttpResponse<dynamic> response,
  ) async {
    if (request.parser != null) {
      return request.parser!(response.data);
    }
    if (response.data is T) return response.data as T;
    if (T == String) return response.data.toString() as T;
    return response.data as T;
  }

  Future<T> _handleResponse<T>(
    HttpRequest<T> request,
    HttpResponse<dynamic> response,
  ) async {
    try {
      // 响应拦截器链（逆序执行，BusinessStatusInterceptor 在此完成信封解包）
      final intercepted = await _applyResponseInterceptors(request, response);
      _logResponse(request, intercepted);
      return _decodeResponse(request, intercepted);
    } on HttpException catch (error) {
      throw await _applyErrorInterceptors(request, error);
    }
  }

  // =======================================================================
  // 缓存策略处理
  // =======================================================================

  Future<T> _handleCache<T>(HttpRequest<T> request) async {
    final cached = await _readCache(_buildCacheKey(request));
    if (cached == null) {
      throw HttpException(
        type: HttpErrorType.cache,
        message: _config.hintConfig?.dataParseHint ?? '缓存未命中',
        request: request,
      );
    }
    if (_logger case final DefaultHttpLogger logger) {
      logger.logCacheHit(request, statusCode: cached.statusCode);
    }
    return _decodeResponse(
      request,
      HttpResponse<dynamic>(
        data: cached.data,
        statusCode: cached.statusCode,
        headers: cached.headers,
        fromCache: true,
        requestOptions: request,
      ),
    );
  }

  // =======================================================================
  // 核心重试 + Mock 执行器
  // =======================================================================

  /// 带重试和 Mock 的统一执行循环。
  Future<HttpResponse<dynamic>> _executeRawWith(
    HttpRequest<dynamic> request,
    Future<HttpResponse<dynamic>> Function() executor, {
    bool allowMock = true,
  }) async {
    final retryPolicy =
        request.retryPolicy ??
        _config.defaultRetryPolicy ??
        const RetryPolicy();
    var attempt = 0;
    final stopwatch = Stopwatch()..start();

    while (true) {
      try {
        // ---- Mock 拦截 -------------------------------------------------
        if (allowMock &&
            _config.enableMock &&
            _mockAdapter != null &&
            _mockAdapter!.matches(request)) {
          final mocked = await _mockAdapter!.resolve(request);
          if (mocked != null) {
            if (mocked.delay != null) {
              await Future<void>.delayed(mocked.delay!);
            }
            return _withObservability(
              request,
              HttpResponse<dynamic>(
                data: mocked.data,
                statusCode: mocked.statusCode,
                headers: mocked.headers,
                extra: mocked.extra,
                requestOptions: request,
              ),
              duration: stopwatch.elapsed,
              retryCount: attempt,
              fromMock: true,
            );
          }
        }

        // ---- 真实请求 --------------------------------------------------
        return _withObservability(
          request,
          await executor(),
          duration: stopwatch.elapsed,
          retryCount: attempt,
        );
      } on DioException catch (error) {
        final httpEx = _toHttpException(request, error);
        if (retryPolicy.canRetry(
          request.method,
          httpEx.statusCode,
          error,
          attempt,
          stopwatch.elapsed,
        )) {
          attempt += 1;
          final delay = retryPolicy.nextDelay(attempt);
          _logRetry(
            request,
            error: error,
            retryCount: attempt,
            delay: delay,
            elapsed: stopwatch.elapsed,
            statusCode: httpEx.statusCode,
          );
          await Future<void>.delayed(delay);
          continue;
        }
        _logFailure(
          request,
          error: httpEx,
          retryCount: attempt,
          elapsed: stopwatch.elapsed,
        );
        throw await _applyErrorInterceptors(request, httpEx);
      } catch (error) {
        final httpEx = HttpException(
          type: HttpErrorType.unknown,
          message: _config.hintConfig?.unknownHint ?? error.toString(),
          originalError: error,
          request: request,
        );
        if (retryPolicy.canRetry(
          request.method,
          null,
          error,
          attempt,
          stopwatch.elapsed,
        )) {
          attempt += 1;
          final delay = retryPolicy.nextDelay(attempt);
          _logRetry(
            request,
            error: error,
            retryCount: attempt,
            delay: delay,
            elapsed: stopwatch.elapsed,
          );
          await Future<void>.delayed(delay);
          continue;
        }
        _logFailure(
          request,
          error: httpEx,
          retryCount: attempt,
          elapsed: stopwatch.elapsed,
        );
        throw await _applyErrorInterceptors(request, httpEx);
      }
    }
  }

  // =======================================================================
  // 统一请求入口（缓存策略调度）
  // =======================================================================

  Future<T> _requestInternal<T>(HttpRequest<T> request) async {
    if (_isDisposed) throw StateError('HttpClient 已释放');

    // 1. 请求拦截器链
    final normalized = await _applyRequestInterceptors(
      _normalizeRequest(request),
    );
    _logRequest(normalized);

    // 2. 仅缓存模式
    if (normalized.cachePolicy == CachePolicy.cacheOnly) {
      return _handleCache(normalized);
    }

    // 3. 缓存优先 / SWR（先尝试缓存）
    if (normalized.method == HttpMethod.get &&
        (normalized.cachePolicy == CachePolicy.cacheFirst ||
            normalized.cachePolicy == CachePolicy.staleWhileRevalidate)) {
      final cached = await _readCache(_buildCacheKey(normalized));
      if (cached != null) {
        if (normalized.cachePolicy == CachePolicy.staleWhileRevalidate) {
          unawaited(_revalidateCache(normalized));
        }
        return _decodeResponse(
          normalized,
          HttpResponse<dynamic>(
            data: cached.data,
            statusCode: cached.statusCode,
            headers: cached.headers,
            fromCache: true,
            requestOptions: normalized,
          ),
        );
      }
    }

    // 4. 网络请求
    try {
      final raw = await _executeRawWith(normalized, () async {
        final dioResp = await _dio.request<dynamic>(
          normalized.path,
          data: normalized.data,
          queryParameters: normalized.queryParameters,
          options: _buildOptions(normalized),
          cancelToken: normalized.cancelToken,
          onSendProgress: normalized.onSendProgress,
          onReceiveProgress: normalized.onReceiveProgress,
        );
        return HttpResponse<dynamic>(
          data: dioResp.data,
          statusCode: dioResp.statusCode,
          headers: dioResp.headers.map.map((k, v) => MapEntry(k, v.toList())),
          extra: dioResp.extra,
          requestOptions: normalized,
        );
      });

      // 5. 写入缓存（GET + 允许缓存）
      if (normalized.method == HttpMethod.get &&
          normalized.cachePolicy != CachePolicy.noCache &&
          normalized.cachePolicy != CachePolicy.networkOnly) {
        await _cleanupExpiredCache();
        await _writeCache(
          normalized,
          Response<dynamic>(
            data: raw.data,
            requestOptions: RequestOptions(path: normalized.path),
            statusCode: raw.statusCode,
            headers: Headers.fromMap(raw.headers),
          ),
          _buildCacheKey(normalized),
        );
      }

      return _handleResponse(normalized, raw);
    } catch (error) {
      // 6. 网络失败 → 回退缓存
      if (normalized.method == HttpMethod.get &&
          normalized.cachePolicy == CachePolicy.networkFirst) {
        return _handleCache(normalized);
      }
      _logError(normalized, error);
      rethrow;
    }
  }

  // =======================================================================
  // 公开 API
  // =======================================================================

  @override
  Future<T> request<T>(HttpRequest<T> request) => _requestInternal(request);

  @override
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
  }) {
    return request<T>(
      HttpRequest<T>(
        method: HttpMethod.get,
        path: path,
        queryParameters: queryParameters,
        headers: headers,
        cancelToken: cancelToken,
        responseType: responseType,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
        followRedirects: followRedirects,
        receiveDataWhenStatusError: receiveDataWhenStatusError,
        validateStatus: validateStatus,
        loggingEnabled: loggingEnabled,
        cachePolicy: cachePolicy,
        cacheTtl: cacheTtl,
        retryPolicy: retryPolicy,
        parser: parser,
      ),
    );
  }

  @override
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
  }) {
    return request<T>(
      HttpRequest<T>(
        method: HttpMethod.post,
        path: path,
        data: data,
        queryParameters: queryParameters,
        headers: headers,
        cancelToken: cancelToken,
        responseType: responseType,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
        followRedirects: followRedirects,
        receiveDataWhenStatusError: receiveDataWhenStatusError,
        validateStatus: validateStatus,
        loggingEnabled: loggingEnabled,
        retryPolicy: retryPolicy,
        parser: parser,
      ),
    );
  }

  @override
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
  }) {
    return request<T>(
      HttpRequest<T>(
        method: HttpMethod.put,
        path: path,
        data: data,
        queryParameters: queryParameters,
        headers: headers,
        cancelToken: cancelToken,
        responseType: responseType,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
        followRedirects: followRedirects,
        receiveDataWhenStatusError: receiveDataWhenStatusError,
        validateStatus: validateStatus,
        loggingEnabled: loggingEnabled,
        retryPolicy: retryPolicy,
        parser: parser,
      ),
    );
  }

  @override
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
  }) {
    return request<T>(
      HttpRequest<T>(
        method: HttpMethod.delete,
        path: path,
        data: data,
        queryParameters: queryParameters,
        headers: headers,
        cancelToken: cancelToken,
        responseType: responseType,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
        followRedirects: followRedirects,
        receiveDataWhenStatusError: receiveDataWhenStatusError,
        validateStatus: validateStatus,
        loggingEnabled: loggingEnabled,
        retryPolicy: retryPolicy,
        parser: parser,
      ),
    );
  }

  @override
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
  }) {
    return request<T>(
      HttpRequest<T>(
        method: HttpMethod.patch,
        path: path,
        data: data,
        queryParameters: queryParameters,
        headers: headers,
        cancelToken: cancelToken,
        responseType: responseType,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
        followRedirects: followRedirects,
        receiveDataWhenStatusError: receiveDataWhenStatusError,
        validateStatus: validateStatus,
        loggingEnabled: loggingEnabled,
        retryPolicy: retryPolicy,
        parser: parser,
      ),
    );
  }

  @override
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
  }) {
    return request<T>(
      HttpRequest<T>(
        method: HttpMethod.post,
        path: path,
        data: FormData.fromMap(<String, dynamic>{...?data, 'files': files}),
        headers: headers,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
        followRedirects: followRedirects,
        receiveDataWhenStatusError: receiveDataWhenStatusError,
        validateStatus: validateStatus,
        loggingEnabled: loggingEnabled,
        retryPolicy: retryPolicy,
        parser: parser,
      ),
    );
  }

  @override
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
  }) async {
    final req = HttpRequest<T>(
      method: HttpMethod.get,
      path: path,
      queryParameters: queryParameters,
      headers: headers,
      cancelToken: cancelToken,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      followRedirects: followRedirects,
      receiveDataWhenStatusError: receiveDataWhenStatusError,
      validateStatus: validateStatus,
      loggingEnabled: loggingEnabled,
      retryPolicy: retryPolicy,
      parser: parser,
      responseType: ResponseType.bytes,
    );
    final normalized = await _applyRequestInterceptors(_normalizeRequest(req));
    final raw = await _executeRawWith(normalized, () async {
      final dioResp = await _dio.download(
        path,
        savePath,
        queryParameters: queryParameters,
        options: _buildOptions(normalized),
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return HttpResponse<dynamic>(
        data: savePath,
        statusCode: dioResp.statusCode,
        headers: dioResp.headers.map.map((k, v) => MapEntry(k, v.toList())),
        extra: dioResp.extra,
        requestOptions: normalized,
      );
    }, allowMock: false);
    return _decodeResponse(normalized, raw);
  }

  @override
  Future<List<T>> sendAll<T>(List<NetworkBatchRequest<T>> requests) async {
    return Future.wait(
      requests.map((batchReq) {
        final httpReq = batchReq.request;
        if (httpReq != null) return request(httpReq);
        final exec = batchReq.execute;
        if (exec != null) return exec();
        throw StateError('NetworkBatchRequest 必须提供 request 或 execute');
      }),
    );
  }

  // =======================================================================
  // 拦截器管理
  // =======================================================================

  @override
  void addInterceptor(HttpInterceptor interceptor) =>
      _interceptors.add(interceptor);

  @override
  void addInterceptors(List<HttpInterceptor> interceptors) =>
      _interceptors.addAll(interceptors);

  @override
  void removeInterceptor(HttpInterceptor interceptor) =>
      _interceptors.remove(interceptor);

  // =======================================================================
  // 配置管理
  // =======================================================================

  @override
  void updateConfig(HttpConfig config) {
    _config = config;
    _applyConfig();
  }

  @override
  void setBaseUrl(String baseUrl) {
    _config = _config.copyWith(baseUrl: baseUrl);
    _applyConfig();
  }

  @override
  void setHeaders(Map<String, String> headers) {
    _config = _config.copyWith(headers: headers);
    _applyConfig();
  }

  @override
  void setTimeout(Duration connectTimeout, Duration receiveTimeout) {
    _config = _config.copyWith(
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
    );
    _applyConfig();
  }

  @override
  void setSecurityConfig(HttpSecurityConfig securityConfig) {
    _config = _config.copyWith(securityConfig: securityConfig);
    _applyConfig();
  }

  @override
  void setRetryPolicy(RetryPolicy retryPolicy) =>
      _config = _config.copyWith(defaultRetryPolicy: retryPolicy);

  @override
  void setLoggingEnabled(bool enabled) =>
      _config = _config.copyWith(enableLogging: enabled);

  @override
  void setMockEnabled(bool enabled) =>
      _config = _config.copyWith(enableMock: enabled);

  @override
  void setMockAdapter(HttpMockAdapter? adapter) => _mockAdapter = adapter;

  @override
  void cancelRequests({CancelToken? token}) => token?.cancel('客户端取消请求');

  @override
  CancelToken createCancelToken() => CancelToken();

  @override
  Future<void> clearCache({String? key}) async {
    if (key == null) {
      await _memoryCacheStore.clear();
      await _diskCacheStore.clear();
      return;
    }
    await _memoryCacheStore.remove(key);
    await _diskCacheStore.remove(key);
  }

  @override
  Future<Map<String, dynamic>> getCacheInfo() async {
    await _cleanupExpiredCache();
    return <String, dynamic>{
      'memory': await _memoryCacheStore.count(),
      'disk': await _diskCacheStore.count(),
    };
  }
}
