import 'package:flutter/foundation.dart';

import '../../../app/env.dart';

/// 轻量日志服务，模板默认输出到 debug console。
///
/// 后续可在此处接入 logger、talker、Sentry 或自研远程日志。
class AppLogger {
  AppLogger._();

  static bool get _enabled => appConfig.httpLogEnable;

  static void debug(String message, {Object? error, StackTrace? stackTrace}) {
    _log('DEBUG', message, error: error, stackTrace: stackTrace);
  }

  static void info(String message, {Object? error, StackTrace? stackTrace}) {
    _log('INFO', message, error: error, stackTrace: stackTrace);
  }

  static void warning(String message, {Object? error, StackTrace? stackTrace}) {
    _log('WARN', message, error: error, stackTrace: stackTrace);
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    _log('ERROR', message, error: error, stackTrace: stackTrace);
  }

  static void _log(
    String level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_enabled && level != 'ERROR') {
      return;
    }
    final buffer = StringBuffer('[${appConfig.envTag.name}][$level] $message');
    if (error != null) {
      buffer.write(' | error=$error');
    }
    debugPrint(buffer.toString());
    if (stackTrace != null && (kDebugMode || level == 'ERROR')) {
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
