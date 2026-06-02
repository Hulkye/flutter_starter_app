/// 路由模块 —— 业务层与 GoRouter 之间的隔离层。
///
/// ## 架构
///
/// ```
/// 业务层                               Infrastructure 层
/// ═══════                             ═════════════════
/// AppRouteDefine (导航目标 + 注册描述)    GoRoute (配置)
/// RouteState (路由状态)           ──→    GoRouterState
///
/// BaseNavigator (导航接口)       ──→    RouterNavigator (GoRouter 实现)
/// appRouterProvider                      goRouterProvider
/// ```
///
/// ## 导航方式
///
/// ```dart
/// // Widget / ViewModel 中
/// ref.read(appRouterProvider).push(const ProfileRoute());
/// ref.read(appRouterProvider).back();
///
/// // Controller 中（无 BuildContext）
/// rootNavigatorKey.currentState?.pop();
/// ```
///
/// ## 新增路由步骤
///
/// 1. `features/xxx/xxx_routes.dart` — 创建 `XxxRoute` + `xxxRouteDefinition`
/// 2. `router_provider.dart` — 在 `_allRouteDefinitions` 列表中添加一行
library;

export 'base_navigator.dart';
export 'app_route_define.dart';
export 'app_router_transfor.dart';
export 'router_provider.dart';
export 'router_navigator.dart';
export 'router_guard.dart';
