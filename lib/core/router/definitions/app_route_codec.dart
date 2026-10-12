import 'app_route_state.dart';

/// 路由参数的解析与导航地址编解码契约。
///
/// 同一个 Codec 同时服务路由注册侧和导航目标侧，避免 path/query 的编码
/// 规则在两个调用路径中重复实现。
abstract interface class AppRouteCodec<TArgs> {
  /// 路由匹配模板。
  String get path;

  /// 从实际导航状态解析业务参数。
  TArgs parse(AppRouteState state);

  /// 将业务参数编码为实际导航地址。
  String location(TArgs args);

  /// 将仅适用于当前进程的附加数据编码到导航请求。
  Object? extra(TArgs args) => null;
}
