import 'package:flutter_riverpod/flutter_riverpod.dart';

/// HTTP 层读取和失效认证会话所需的最小能力。
///
/// 网络层不关心具体会话模型、存储方式或认证模块实现；App 组合层负责把
/// 具体认证服务适配到该端口。
abstract interface class HttpAuthSessionAccess {
  /// 返回当前请求需要注入的 Authorization 值；没有有效会话时返回 null。
  String? get authorization;

  /// 清理当前认证会话。
  Future<void> clearSession();
}

/// HTTP 认证能力装配点。
///
/// App 组合层必须提供实现。未装配时直接失败，避免请求静默绕过认证策略。
final httpAuthSessionAccessProvider = Provider<HttpAuthSessionAccess>((ref) {
  throw StateError(
    'httpAuthSessionAccessProvider must be overridden by app composition.',
  );
});