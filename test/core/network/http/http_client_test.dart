import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_starter_app/core/network/http/http.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HttpClient', () {
    test(
      'passes per-request connectTimeout into Dio request options',
      () async {
        final adapter = _FakeHttpClientAdapter()
          ..enqueueJson(<String, dynamic>{'ok': true});
        final client = _createClient(adapter);

        await client.get<Map<String, dynamic>>(
          '/connect-timeout',
          connectTimeout: const Duration(milliseconds: 123),
        );

        expect(adapter.requests.single.connectTimeout, 123.ms);
      },
    );

    test(
      'passes per-request connectTimeout into download request options',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'flutter_starter_http_download_test_',
        );
        addTearDown(() async {
          if (await tempDir.exists()) {
            await tempDir.delete(recursive: true);
          }
        });
        final savePath = '${tempDir.path}/report.txt';
        final progressEvents = <(int, int)>[];
        final adapter = _FakeHttpClientAdapter()
          ..enqueueBytes(utf8.encode('report'));
        final client = _createClient(adapter);

        final result = await client.download<String>(
          '/download',
          savePath,
          connectTimeout: const Duration(milliseconds: 234),
          onReceiveProgress: (received, total) {
            progressEvents.add((received, total));
          },
        );

        expect(result, savePath);
        expect(adapter.requests.single.connectTimeout, 234.ms);
        expect(await File(savePath).readAsString(), 'report');
        expect(progressEvents, <(int, int)>[(6, 6)]);
      },
    );

    test(
      'retries retryable status codes and returns the successful response',
      () async {
        final adapter = _FakeHttpClientAdapter()
          ..enqueueJson(<String, dynamic>{
            'message': 'server error',
          }, statusCode: 500)
          ..enqueueJson(<String, dynamic>{'ok': true});
        final client = _createClient(
          adapter,
          config: _httpConfig(
            defaultRetryPolicy: const RetryPolicy(
              maxAttempts: 1,
              delay: Duration.zero,
            ),
          ),
        );

        final result = await client.get<Map<String, dynamic>>('/retry');

        expect(result, <String, dynamic>{'ok': true});
        expect(adapter.requests, hasLength(2));
      },
    );

    test('networkFirst falls back to cached data when network fails', () async {
      final cacheDir = await Directory.systemTemp.createTemp(
        'flutter_starter_http_cache_test_',
      );
      addTearDown(() async {
        if (await cacheDir.exists()) {
          await cacheDir.delete(recursive: true);
        }
      });

      final adapter = _FakeHttpClientAdapter()
        ..enqueueJson(<String, dynamic>{'value': 1})
        ..enqueueDioException(DioExceptionType.connectionError);
      final client = _createClient(
        adapter,
        memoryCacheStore: MemoryHttpCacheStore(),
        diskCacheStore: FileHttpCacheStore(directory: cacheDir),
      );

      final first = await client.get<Map<String, dynamic>>(
        '/cached',
        cachePolicy: CachePolicy.networkFirst,
      );
      final second = await client.get<Map<String, dynamic>>(
        '/cached',
        cachePolicy: CachePolicy.networkFirst,
      );

      expect(first, <String, dynamic>{'value': 1});
      expect(second, <String, dynamic>{'value': 1});
      expect(adapter.requests, hasLength(2));
      expect(await cacheDir.list().where((entity) => entity is File).length, 1);
    });

    test(
      'business status interceptor unwraps payload and maps errors',
      () async {
        final adapter = _FakeHttpClientAdapter()
          ..enqueueJson(<String, dynamic>{
            'code': 0,
            'message': 'ok',
            'data': <String, dynamic>{'name': 'Ada'},
          })
          ..enqueueJson(<String, dynamic>{
            'code': 42,
            'message': 'business failed',
            'data': null,
          });
        final client = _createClient(
          adapter,
          config: _httpConfig(
            responseConfig: const HttpResponseConfig(
              enableBusinessStatusCheck: true,
            ),
          ),
        );

        final success = await client.get<Map<String, dynamic>>('/business-ok');

        expect(success, <String, dynamic>{'name': 'Ada'});
        await expectLater(
          _getSkippingExceptionCapture(client, '/business-error'),
          throwsA(
            isA<HttpException>()
                .having((error) => error.type, 'type', HttpErrorType.server)
                .having((error) => error.businessCode, 'businessCode', 42)
                .having((error) => error.message, 'message', 'business failed'),
          ),
        );
      },
    );

    test(
      'http 401 triggers auth failed callback and throws unauthorized',
      () async {
        var authFailed = false;
        final adapter = _FakeHttpClientAdapter()
          ..enqueueJson(<String, dynamic>{
            'message': 'unauthorized',
          }, statusCode: 401);
        final client = _createClient(
          adapter,
          config: _httpConfig(
            authConfig: HttpAuthConfig(
              onAuthFailed: () async {
                authFailed = true;
              },
            ),
          ),
        );

        await expectLater(
          _getSkippingExceptionCapture(client, '/private'),
          throwsA(
            isA<HttpException>()
                .having(
                  (error) => error.type,
                  'type',
                  HttpErrorType.unauthorized,
                )
                .having((error) => error.statusCode, 'statusCode', 401),
          ),
        );
        expect(authFailed, isTrue);
      },
    );

    test(
      'file cache store can use an injected app cache directory provider',
      () async {
        final cacheRoot = await Directory.systemTemp.createTemp(
          'flutter_starter_app_cache_root_',
        );
        addTearDown(() async {
          if (await cacheRoot.exists()) {
            await cacheRoot.delete(recursive: true);
          }
        });
        final appCacheDir = Directory('${cacheRoot.path}/app_cache/http_cache');
        final store = FileHttpCacheStore(
          directoryProvider: () async => appCacheDir,
        );

        await store.write(
          HttpCacheEntry(
            key: 'cache-key',
            data: <String, dynamic>{'cached': true},
            createdAt: DateTime.now(),
            expiresAt: DateTime.now().add(const Duration(minutes: 1)),
            statusCode: 200,
            headers: const <String, List<String>>{},
            requestSignature: 'cache-key',
          ),
        );

        expect(await appCacheDir.exists(), isTrue);
        expect(await store.count(), 1);
        expect((await store.read('cache-key'))?.data, <String, dynamic>{
          'cached': true,
        });
      },
    );
  });
}

Future<Map<String, dynamic>> _getSkippingExceptionCapture(
  HttpClient client,
  String path,
) {
  return client.request<Map<String, dynamic>>(
    HttpRequest<Map<String, dynamic>>(
      method: HttpMethod.get,
      path: path,
      extra: const <String, dynamic>{
        ExceptionCaptureInterceptor.skipCaptureExtraKey: true,
      },
    ),
  );
}

HttpClient _createClient(
  _FakeHttpClientAdapter adapter, {
  HttpConfig? config,
  HttpCacheStore? memoryCacheStore,
  HttpCacheStore? diskCacheStore,
}) {
  final dio = Dio()..httpClientAdapter = adapter;
  final client = HttpClient(
    dio: dio,
    config: config ?? _httpConfig(),
    memoryCacheStore: memoryCacheStore,
    diskCacheStore: diskCacheStore,
  );
  addTearDown(client.dispose);
  return client;
}

HttpConfig _httpConfig({
  RetryPolicy? defaultRetryPolicy,
  HttpResponseConfig responseConfig = const HttpResponseConfig(
    enableBusinessStatusCheck: false,
  ),
  HttpAuthConfig? authConfig,
}) {
  return HttpConfig(
    enableLogging: false,
    connectTimeout: const Duration(seconds: 2),
    defaultRetryPolicy: defaultRetryPolicy ?? const RetryPolicy(maxAttempts: 0),
    responseConfig: responseConfig,
    authConfig: authConfig,
  );
}

typedef _AdapterAction =
    FutureOr<ResponseBody> Function(RequestOptions options);

final class _FakeHttpClientAdapter implements HttpClientAdapter {
  final Queue<_AdapterAction> _actions = Queue<_AdapterAction>();
  final List<RequestOptions> requests = <RequestOptions>[];

  void enqueueJson(Object? data, {int statusCode = 200}) {
    _actions.add((options) {
      return ResponseBody.fromString(
        jsonEncode(data),
        statusCode,
        headers: const <String, List<String>>{
          Headers.contentTypeHeader: <String>['application/json'],
        },
      );
    });
  }

  void enqueueBytes(List<int> bytes, {int statusCode = 200}) {
    _actions.add((options) {
      return ResponseBody.fromBytes(
        bytes,
        statusCode,
        headers: <String, List<String>>{
          Headers.contentLengthHeader: <String>['${bytes.length}'],
        },
      );
    });
  }

  void enqueueDioException(DioExceptionType type) {
    _actions.add((options) {
      throw DioException(
        requestOptions: options,
        type: type,
        message: 'test ${type.name}',
      );
    });
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (_actions.isEmpty) {
      throw StateError('No fake response enqueued for ${options.path}.');
    }
    return _actions.removeFirst()(options);
  }

  @override
  void close({bool force = false}) {}
}

extension on int {
  Duration get ms => Duration(milliseconds: this);
}
