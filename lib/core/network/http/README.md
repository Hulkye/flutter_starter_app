# HTTP 模块说明

`lib/core/network/http` 是项目的统一网络基础设施，基于 Dio 封装，但向上层暴露 `BaseHttpClient`、`HttpRequest<T>`、`HttpResponse<T>`、`HttpException`、缓存、重试、业务状态码、认证注入、抓包事件和 Mock 能力。

业务代码优先依赖 `BaseHttpClient` 或 `httpClientProvider`，不要在 Feature 中直接散落 Dio 实例。

## 入口

常用类型由 `http.dart` 汇总导出：

```dart
import 'package:flutter_starter_app/core/network/http/http.dart';
```

项目运行时客户端由 `http_provider.dart` 提供：

```dart
import 'package:flutter_starter_app/core/network/http/http_provider.dart';

final client = ref.read(httpClientProvider);
```

`httpClientProvider` 会读取 `appConfig`、国际化错误文案和 `authSessionProvider`，生成当前环境的 `HttpConfig`。认证 Header 在每次请求前懒读取会话状态，401 或业务 token 过期会通过 `authSessionControllerProvider` 清理会话。

## 目录职责

| 路径 | 职责 |
|---|---|
| `base_http_client.dart` | 网络客户端抽象接口 |
| `http_client.dart` | Dio 适配实现，集中处理请求、缓存、重试、下载、异常映射 |
| `http_provider.dart` | Riverpod Provider 装配，连接环境配置、认证会话和 HTTP 客户端 |
| `config/` | `HttpConfig`、认证、业务状态码、提示文案、重试、证书配置 |
| `request/` | `HttpRequest<T>` 一等请求模型 |
| `response/` | `HttpResponse<T>` 与业务 `ApiResponse` 模型 |
| `error/` | `HttpException` 与错误分类 |
| `interceptor/` | Dio 无关拦截器链及内置拦截器 |
| `cache/` | 内存缓存、文件缓存和缓存条目 |
| `mock/` | 请求级 Mock 适配器 |
| `logging/` | 结构化日志抽象和默认实现 |
| `batch/` | 批量并发请求描述 |
| `shared/` | 缓存键和序列化工具 |

## 快速使用

Feature 或 Repository 中建议通过 Provider 注入客户端：

```dart
final client = ref.read(httpClientProvider);

final user = await client.get<User>(
  '/user/me',
  parser: (data) => User.fromJson(data as Map<String, dynamic>),
);
```

测试或独立场景可以直接构造：

```dart
final client = HttpClient(
  config: HttpConfig(
    baseUrl: 'https://api.example.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    sendTimeout: const Duration(seconds: 10),
    defaultRetryPolicy: const RetryPolicy(maxAttempts: 2),
    responseConfig: const HttpResponseConfig(
      enableBusinessStatusCheck: true,
      defaultSuccessCode: 0,
    ),
    authConfig: HttpAuthConfig(
      headerMapProvider: () async => <String, dynamic>{
        'Authorization': 'Bearer $token',
      },
      onAuthFailed: () async => logout(),
    ),
  ),
);
```

## 请求模型

快捷方法覆盖常见场景：

```dart
await client.get<User>(
  '/users/1',
  queryParameters: <String, dynamic>{'expand': 'profile'},
  headers: <String, String>{'Accept-Language': 'zh-CN'},
  connectTimeout: const Duration(seconds: 3),
  retryPolicy: const RetryPolicy(maxAttempts: 1),
  parser: (data) => User.fromJson(data as Map<String, dynamic>),
);

await client.post<Result>(
  '/orders',
  data: <String, dynamic>{'sku': 'A001'},
  parser: (data) => Result.fromJson(data as Map<String, dynamic>),
);
```

需要 `extra`、一次性关闭业务状态码或异常采集时，使用 `request()`：

```dart
final data = await client.request<Map<String, dynamic>>(
  HttpRequest<Map<String, dynamic>>(
    method: HttpMethod.get,
    path: '/public/config',
    extra: const <String, dynamic>{
      '_check_business_status': false,
      ExceptionCaptureInterceptor.skipCaptureExtraKey: true,
    },
  ),
);
```

## 执行链路

`HttpClient` 构造时安装内置拦截器，顺序如下：

1. `PacketCaptureInterceptor`
2. `AuthInterceptor`，仅当 `HttpConfig.authConfig != null`
3. `BusinessStatusInterceptor`
4. `ExceptionCaptureInterceptor`
5. 用户传入的自定义拦截器

请求阶段按列表顺序执行，响应和错误阶段按逆序执行。

普通请求的主流程：

1. 用 `HttpConfig` 补齐 Header、连接超时和默认重试策略。
2. 执行请求拦截器，认证 Header 在这里注入。
3. 按缓存策略决定是否先读缓存。
4. 通过 `_executeRawWith` 执行 Mock、真实请求和重试。
5. GET 且允许缓存时写入内存和磁盘缓存。
6. 执行响应拦截器，业务状态码成功时解包 `data`，失败时抛出 `HttpException`。
7. 通过 `parser` 转换为调用方声明的泛型结果。

## 业务状态码

默认响应信封格式：

```json
{ "code": 0, "data": {}, "msg": "ok" }
```

配置示例：

```dart
const responseConfig = HttpResponseConfig(
  enableBusinessStatusCheck: true,
  defaultSuccessCode: 0,
);
```

自定义信封：

```dart
final responseConfig = HttpResponseConfig(
  codeGetter: (raw) => raw is Map<String, dynamic> ? raw['errno'] as int? : null,
  dataGetter: (raw) => raw is Map<String, dynamic> ? raw['payload'] : raw,
  msgGetter: (raw) => raw is Map<String, dynamic> ? raw['errmsg']?.toString() : null,
  successChecker: (code, raw) => code == 200,
  tokenExpiredChecker: (code, raw) => code == 40101,
);
```

单请求关闭业务状态码检查：

```dart
await client.request<Object?>(
  const HttpRequest<Object?>(
    method: HttpMethod.get,
    path: '/plain-text',
    extra: <String, dynamic>{'_check_business_status': false},
  ),
);
```

## 认证

`AuthInterceptor` 在请求阶段调用 `HttpAuthConfig.headerMapProvider`，把返回的动态 Header 合并到请求 Header。默认不覆盖请求中已有同名 Header，除非设置 `overrideIfHeaderExists: true`。

```dart
HttpAuthConfig(
  headerMapProvider: () async => <String, dynamic>{
    'Authorization': 'Bearer $token',
    'X-App-Env': 'sit',
  },
  onAuthFailed: () async {
    await clearSession();
  },
)
```

当前项目的 `httpConfigProvider` 已内置：

- `X-App-Channel: flutter_starter_app`
- `X-App-Env: appConfig.envTag.name`
- 有 token 时注入 `Authorization: Bearer ...`
- 认证失败时通过 `authSessionControllerProvider` 清空会话

## 缓存

缓存策略只对 GET 请求写入缓存。快捷 `get()` 默认是 `CachePolicy.noCache`，需要缓存时应在单次请求显式传入 `cachePolicy`。

| 策略 | 行为 |
|---|---|
| `noCache` | 不读写缓存 |
| `networkOnly` | 只走网络，不写缓存 |
| `cacheOnly` | 只读缓存，未命中抛出 `HttpErrorType.cache` |
| `cacheFirst` | 先读缓存，未命中走网络 |
| `networkFirst` | 先走网络，失败后回退缓存 |
| `staleWhileRevalidate` | 命中缓存时立即返回缓存，并在后台静默刷新 |

示例：

```dart
final feed = await client.get<Feed>(
  '/feed',
  cachePolicy: CachePolicy.staleWhileRevalidate,
  cacheTtl: const Duration(minutes: 5),
  parser: (data) => Feed.fromJson(data as Map<String, dynamic>),
);
```

存储实现：

- `MemoryHttpCacheStore`：热数据缓存。
- `FileHttpCacheStore`：磁盘缓存，默认位于应用 cache 目录的 `http_cache/` 子目录。
- `FileHttpCacheStore(directory: ...)` 或 `directoryProvider: ...` 可用于测试和特殊目录。

缓存键由 `cacheKeyBuilder` 决定，默认使用 method、path、queryParameters、部分 vary headers、data、extra 生成稳定 JSON 字符串。按 key 清缓存时必须传入同一套缓存键：

```dart
final request = HttpRequest<Feed>(
  method: HttpMethod.get,
  path: '/feed',
  cachePolicy: CachePolicy.cacheFirst,
);

final key = defaultCacheKeyBuilder(request);
await client.clearCache(key: key);
```

注意：当前缓存命中后直接解码缓存数据，不重新执行响应拦截器。若接口开启业务信封解包，缓存中保存的是网络原始响应数据，parser 需要与实际缓存数据结构匹配。

## 重试

默认没有重试；`RetryPolicy(maxAttempts: 0)` 表示不重试。可在 `HttpConfig.defaultRetryPolicy` 设置全局默认，也可在单次请求覆盖。

```dart
const retry = RetryPolicy(
  maxAttempts: 2,
  delay: Duration(milliseconds: 300),
  backoffFactor: 1.6,
  maxDelay: Duration(seconds: 5),
  retryOnStatusCodes: <int>{408, 429, 500, 502, 503, 504},
  retryOnMethods: <HttpMethod>{
    HttpMethod.get,
    HttpMethod.head,
    HttpMethod.options,
  },
);
```

重试发生在 `_executeRawWith` 内，Mock 命中、真实请求、DioException、普通异常都会进入统一重试判断。`maxAttempts` 表示最多重试次数，不包含第一次请求。

## 异常

网络层统一抛出 `HttpException`：

```dart
try {
  await client.get<User>('/user/me');
} on HttpException catch (error) {
  switch (error.type) {
    case HttpErrorType.unauthorized:
      break;
    case HttpErrorType.timeout:
      break;
    default:
      break;
  }
}
```

主要错误类型：

| 类型 | 来源 |
|---|---|
| `timeout` | Dio 连接、发送或接收超时 |
| `network` | 连接失败、证书失败等网络异常 |
| `unauthorized` | HTTP 401 或业务 token 过期 |
| `forbidden` | HTTP 403 |
| `notFound` | HTTP 404 |
| `server` | HTTP 5xx 或业务状态码错误 |
| `badResponse` | 其他非成功 HTTP 响应 |
| `parse` | 业务信封 code 解析失败 |
| `cache` | cacheOnly 或 networkFirst 回退时缓存未命中 |
| `cancel` | 请求取消 |
| `unknown` | 未知异常 |

`ExceptionCaptureInterceptor` 会记录面包屑，并对 5xx、parse、server、unknown、unauthorized 等错误上报到 `AppExceptionCatcher`。单请求跳过异常采集：

```dart
HttpRequest<Object?>(
  method: HttpMethod.get,
  path: '/health',
  extra: const <String, dynamic>{
    ExceptionCaptureInterceptor.skipCaptureExtraKey: true,
  },
);
```

## 文件上传与下载

上传走普通请求链路，支持业务状态码、重试、认证、日志和 parser：

```dart
final url = await client.upload<String>(
  '/upload',
  files: <MultipartFile>[
    await MultipartFile.fromFile('./avatar.png', filename: 'avatar.png'),
  ],
  onSendProgress: (sent, total) {},
  parser: (data) => (data as Map<String, dynamic>)['url'] as String,
);
```

下载会执行请求拦截器、认证、重试、错误拦截器和单请求超时，成功后把响应流写入 `savePath`，默认返回 `savePath`：

```dart
final path = await client.download<String>(
  '/files/report.pdf',
  './downloads/report.pdf',
  connectTimeout: const Duration(seconds: 5),
  onReceiveProgress: (received, total) {},
);
```

下载当前不走 Mock，也不执行响应业务信封解包。

## Mock

```dart
class UserMock extends HttpMockAdapter {
  @override
  bool matches(HttpRequest<dynamic> request) {
    return request.method == HttpMethod.get && request.path == '/user/me';
  }

  @override
  Future<HttpMockResponse<dynamic>?> resolve(
    HttpRequest<dynamic> request,
  ) async {
    return const HttpMockResponse<dynamic>(
      data: <String, dynamic>{'id': 1, 'name': 'Test User'},
      statusCode: 200,
    );
  }
}

final client = HttpClient(
  config: const HttpConfig(enableMock: true),
  mockAdapter: UserMock(),
);
```

也可以运行时切换：

```dart
client.setMockAdapter(UserMock());
client.setMockEnabled(true);
```

## 抓包、代理与证书

抓包事件：

```dart
final client = HttpClient(
  config: const HttpConfig(enablePacketCapture: true),
  onPacketCapture: (event) {
    debugPrint('${event.stage} ${event.request.path}');
  },
);
```

代理与证书：

```dart
const config = HttpConfig(
  proxyHost: '192.168.1.100',
  proxyPort: 8888,
  allowBadCertificate: true,
  securityConfig: HttpSecurityConfig(allowInvalidCertificates: true),
);
```

`httpConfigProvider` 已根据 `appConfig.proxyEnable`、`caughtAddress`、`httpAllowBadCertificate` 自动装配代理和证书策略。

## 批量请求

`sendAll` 使用 `Future.wait` 并发执行，支持标准 `HttpRequest` 和自定义闭包：

```dart
final results = await client.sendAll<User>(<NetworkBatchRequest<User>>[
  NetworkBatchRequest<User>.request(
    HttpRequest<User>(
      method: HttpMethod.get,
      path: '/users/1',
      parser: (data) => User.fromJson(data as Map<String, dynamic>),
    ),
  ),
  NetworkBatchRequest<User>.execute(loadUserFromLocalCache),
]);
```

自定义闭包不走 HTTP 请求链路、拦截器、缓存或重试。

## 运行时配置

```dart
client.setBaseUrl('https://api-v2.example.com');
client.setHeaders(<String, String>{'X-Version': '2.0'});
client.setTimeout(
  const Duration(seconds: 10),
  const Duration(seconds: 10),
);
client.setRetryPolicy(const RetryPolicy(maxAttempts: 2));
client.setLoggingEnabled(false);
client.updateConfig(const HttpConfig(baseUrl: 'https://new.example.com'));
```

`cancelRequests(token: token)` 只取消传入的 `CancelToken`；当前没有全局取消所有请求的 token 池。

## 测试建议

已有网络层测试位于 `test/core/network/http/`，覆盖：

- 单请求连接超时传入 Dio `RequestOptions`
- 下载连接超时和进度回调
- 重试
- `networkFirst` 失败回退缓存
- 业务状态码成功解包和错误映射
- HTTP 401 认证失败回调
- 文件缓存目录注入
- `httpConfigProvider` 与 `authSessionProvider` 集成

常用命令：

```bash
flutter test test/core/network/http
flutter analyze
```

## 依赖

当前项目依赖版本以 `pubspec.yaml` 为准：

| 包 | 当前版本 | 用途 |
|---|---|---|
| `dio` | `5.9.0` | 底层 HTTP 客户端 |
| `logger` | `2.6.1` | 默认日志输出 |
| `path_provider` | `2.1.5` | 获取应用 cache 目录 |
| `flutter_riverpod` | `2.6.1` | Provider 装配 |
