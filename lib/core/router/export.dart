/// Router 对业务层的统一导出入口。
///
/// 同时提供 Router 核心协议和当前 Riverpod 集成 API，业务层不需要感知
/// integrations/riverpod 的内部目录结构。Router 核心内部仍应使用精确 import，
/// 避免通过该 barrel 形成反向依赖。
library;

export 'router.dart';
export 'integrations/riverpod/router.dart';
