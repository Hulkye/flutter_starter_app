/// 路由模块对业务开放的框架无关 API。
///
/// ## 架构
///
/// ```
/// 业务层                               Infrastructure 层
/// ═══════                             ═════════════════
/// AppPageRoute (注册描述)                       GoRoute (配置)
/// AppRouteTarget (导航目标)
/// AppRouteState (路由状态)        ──→    GoRouterState
///
/// BaseNavigator (导航接口)       ──→    RouterNavigator (稳定门面)
/// appRouterProvider                      GoRouter runtime binding
/// App 路由配置                    ──→    GoRouter routes
/// ```
///
/// ## 导航方式
///
/// ```dart
/// // Widget / ViewModel 中
/// ref.read(appRouterProvider).push(const ProfileTarget());
/// ref.read(appRouterProvider).back();
///
/// // Controller 中（无 BuildContext）
/// ref.read(appRouterProvider).back();
/// ```
///
/// ## 新增路由步骤
///
/// 1. `features/xxx/presentation/xxx_routes.dart` — 创建 `XxxRoute extends AppPageRoute`
/// 2. `features/xxx/xxx_feature.dart` — 创建 `XxxFeature extends AppFeature`
/// 3. `features/features.dart` — 注册 `XxxFeature()`
/// 4. App 层 `app_router_config.dart` 会通过 `appFeatures` 自动组合到路由图
library;

export 'navigation/base_navigator.dart';
export 'navigation/router_provider.dart';
export 'adapters/router_navigator.dart';
export 'definitions/router_definitions.dart';
export 'config/app_router_definition.dart';
export 'config/router_runtime.dart';
export 'guards/route_redirect_resolver.dart';
export 'guards/route_access_decision.dart';
export 'guards/app_route_guard.dart';
export 'guards/app_route_request.dart';
