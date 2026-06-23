import 'dart:async';
import 'package:exception_catcher/exception_catcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_starter_app/app/env.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppExceptionCatcher {
  AppExceptionCatcher._();

  /// 启动应用
  static Future<void> runAppGuarded({
    required FutureOr<void> Function() appRunner,
    Future<Map<String, Object?>> Function()? contextProvider,
  }) async {
    ExceptionCatcher.runAppGuarded(
      appRunner,
      config: ExceptionCatcherConfig(
        handlers: <ExceptionHandler>[
          if (kDebugMode && appConfig.envTag != EnvTag.prod)
            ConsoleExceptionHandler(includeStackTrace: true),
        ],
        contextProvider: contextProvider ?? _defaultContextProvider,
      ),
    );
  }

  static Future<Map<String, Object?>> _defaultContextProvider() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return <String, Object?>{
      'env': appConfig.envTag.name,
      'appVersion': packageInfo.version,
      'buildNumber': packageInfo.buildNumber,
    };
  }

  /// 释放处理器资源并清理运行状态
  static Future<void> dispose() async {
    await ExceptionCatcher.dispose();
  }

  /// 记录异常
  static Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    ExceptionSource source = ExceptionSource.manual,
    bool fatal = false,
    Map<String, Object?> customContext = const <String, Object?>{},
    String? flutterLibrary,
    String? flutterContext,
  }) async {
    ExceptionCatcher.recordError(
      error,
      stackTrace,
      source: source,
      fatal: fatal,
      customContext: customContext,
      flutterLibrary: flutterLibrary,
      flutterContext: flutterContext,
    );
  }

  /// 记录网络请求链路主动捕获的异常。
  static Future<void> recordNetworkError(
    Object error,
    StackTrace stackTrace, {
    Map<String, Object?> customContext = const <String, Object?>{},
  }) async {
    await recordError(
      error,
      stackTrace,
      source: ExceptionSource.network,
      customContext: customContext,
    );
  }

  /// 添加一条异常前行为记录。
  static void addBreadcrumb(
    String message, {
    String? category,
    Map<String, Object?> data = const <String, Object?>{},
  }) {
    ExceptionCatcher.addBreadcrumb(message, category: category, data: data);
  }

  /// 清空异常前行为记录。
  static void clearBreadcrumbs() {
    ExceptionCatcher.clearBreadcrumbs();
  }
}
