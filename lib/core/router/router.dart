/// 路由模块 —— 业务层与 GoRouter 之间的隔离层。
///
/// ## 架构
///
/// ```
/// 业务层                               Infrastructure 层
/// ═══════                             ═════════════════
/// AppRouteDefine (注册描述 + location helper)   GoRoute (配置)
/// RouteState (路由状态)           ──→    GoRouterState
///
/// BaseNavigator (导航接口)       ──→    RouterNavigator (GoRouter 实现)
/// appRouterProvider                      goRouterProvider
/// ```
///
/// ## 导航方式
///
/// ```dart
/// // Widget / Page 中
/// ref.read(appRouterProvider).push(const ProfileRoute().location);
/// ref.read(appRouterProvider).go('/profile/42?tab=posts');
/// ref.read(appRouterProvider).back();
/// ```
///
/// ## 新增路由步骤
///
/// 1. `features/xxx/xxx_routes.dart` — 创建 `XxxRoute extends AppRouteDefine`
/// 2. `features/xxx/xxx_feature.dart` — 创建 `XxxFeature extends AppFeature`
/// 3. `features/features.dart` — 注册 `XxxFeature()` 并导出该 Feature
library;

export 'base_navigator.dart';
export 'app_route_define.dart';
export 'app_router_transfor.dart';
export 'router_provider.dart';
export 'router_navigator.dart';
export 'router_guard.dart';
