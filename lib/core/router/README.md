# Router 模块

`core/router` 是业务层与 GoRouter 之间的隔离层。业务代码通过项目路由抽象和 `BaseNavigator` 导航，不直接 import `go_router`。

## 当前职责

- 对业务层暴露框架无关的路由定义：`AppPageRoute`、`AppRedirectRoute`、`AppShellRoute`。
- 对业务层暴露导航接口：`BaseNavigator` 与 `appRouterProvider`。
- 在基础设施层把 `AppRouteNode` 转换为 GoRouter 的 `RouteBase`。
- 在 `router_provider.dart` 汇总 App 装配路由、Feature 路由、认证守卫和导航 Provider。
- App Shell 的 Tab 入口由 Feature 显式声明，Shell 只做装配。

## 文件清单

| 文件 | 职责 | 引用 GoRouter? |
|:---|:---|:---:|
| `router.dart` | router 模块对外 barrel export | — |
| `definitions/router_definitions.dart` | 路由定义类型内部 barrel export | ❌ |
| `definitions/app_route_node.dart` | `AppRouteNode` 路由节点基类 | ❌ |
| `definitions/app_page_route.dart` | `AppPageRoute` 普通页面路由 | ❌ |
| `definitions/app_redirect_route.dart` | `AppRedirectRoute` 重定向路由 | ❌ |
| `definitions/app_shell_route.dart` | `AppShellRoute` Shell 路由 | ❌ |
| `definitions/app_shell_branch.dart` | `AppShellBranch` Shell 分支定义 | ❌ |
| `definitions/app_shell_navigator.dart` | `AppShellNavigator` Shell 分支导航接口 | ❌ |
| `definitions/app_route_state.dart` | `AppRouteState` 框架无关路由状态 | ❌ |
| `base_navigator.dart` | `BaseNavigator` 导航抽象接口 | ❌ |
| `router_navigator.dart` | `RouterNavigator` 的 GoRouter 导航实现 | ✅ |
| `app_router_transfor.dart` | `AppRouteNode` 到 `RouteBase` 的适配器 | ✅ |
| `router_provider.dart` | GoRouter、导航接口、路由表、守卫 Provider | ✅ |
| `router_guard.dart` | `createAuthGuard()` 认证守卫工具 | ✅ |

## 分层关系

```text
Feature / App Page
  import 'package:flutter_starter_app/header.dart'
  ref.read(appRouterProvider).push(const TodoRoute().location)
        │
        ▼
core/router definitions
  AppRouteNode / AppPageRoute / AppShellRoute / AppRouteState
        │
        ▼
core/router adapters
  toRouteBase() / RouterNavigator / createAuthGuard()
        │
        ▼
GoRouter
  GoRoute / StatefulShellRoute / GoRouterState
```

## 定义类型

### AppRouteNode

`AppRouteNode` 是路由注册表的统一节点类型，目前包含三类实现：

- `AppPageRoute`：普通页面路由。
- `AppRedirectRoute`：只做重定向的路由，例如 `/ -> /todo`。
- `AppShellRoute`：多分支 Shell 路由，例如底部 Tab 的独立导航栈。

### AppPageRoute

`AppPageRoute` 同时描述路由匹配、导航目标和页面构建。

```dart
final class SettingRoute extends AppPageRoute {
  const SettingRoute();

  @override
  String get path => '/mine/setting';

  @override
  Widget buildPage(BuildContext context, AppRouteState state) {
    return const SettingPage();
  }
}
```

- `path`：GoRouter 匹配模式，例如 `/ptt/member/:memberId`。
- `location`：实际跳转地址，默认等于 `path`，带参数路由应覆盖。
- `public`：是否无需登录即可访问，默认 `false`。
- `buildPage()`：构建页面，只接收框架无关的 `AppRouteState`。

### AppRouteState

`AppRouteState` 是 GoRouterState 的中立替代，Feature 路由不直接接触 GoRouterState。

```dart
class AppRouteState {
  final String location;
  final Map<String, String> pathParameters;
  final Map<String, String> queryParameters;
  final Object? extra;
}
```

### AppShellRoute

`AppShellRoute` 用来表达 App Shell 的分支结构。底层会在 `app_router_transfor.dart` 中转换为 `StatefulShellRoute.indexedStack`。

```dart
final class RootShellRoute extends AppShellRoute {
  RootShellRoute()
    : super(
        branches: const <AppShellBranch>[
          AppShellBranch(
            initialLocation: DemoRoute().location,
            routes: <AppPageRoute>[DemoRoute()],
          ),
        ],
        builder: _build,
      );
}
```

### AppShellNavigator

`AppShellNavigator` 是 Shell 页面切换分支的接口。`RootShellPage` 依赖它，不依赖 GoRouter 的 `StatefulNavigationShell`。

```dart
class RootShellPage extends BasePage {
  const RootShellPage({required this.shellNavigator, super.key});

  final AppShellNavigator shellNavigator;

  @override
  Widget page(PageScope scope) => shellNavigator.child;
}
```

## 路由注册流程

`router_provider.dart` 维护应用总路由表：

```dart
final List<AppRouteNode> _allRouteNodes = <AppRouteNode>[
  const SplashRoute(),
  ...buildRootRouteNodes(),
  ...appFeatureRoutes,
];
```

注册顺序含义：

- `SplashRoute`：启动展示页，属于 `lib/app/splash/`。
- `RootRoute`：`/` 重定向到默认 Tab。
- `RootShellRoute`：底部 Tab Shell，属于 `lib/app/shell/`。
- `appFeatureRoutes`：从 `features/features.dart` 汇聚的普通业务页面路由；已挂到 Shell Tab 的根路由不会重复注册到顶层。

同时，`RootShellRoute` 不再手写 tab 分支，而是从 `features/features.dart` 汇聚的 `appFeatureTabs` 自动装配：

```dart
final List<AppTabEntry> appFeatureTabs = [
  for (final feature in appFeatures) ...feature.tabs,
];
```

这样一个 Feature 可以：

- 提供多个 Tab 入口，例如 `ptt`。
- 只提供普通页面路由、不提供 Tab，例如 `auth`。
- 由 App Shell 统一决定展示顺序，而不是把业务页面写死在 Shell 内部。

`goRouterProvider` 负责创建 GoRouter；`appRouterProvider` 对外暴露 `BaseNavigator`。登录态变化只刷新 redirect，不重建 Router，避免重复应用 `initialLocation`。

## 导航用法

业务层优先从 `package:flutter_starter_app/header.dart` 获取路由与导航 Provider。

```dart
ref.read(appRouterProvider).push(const TodoRoute().location);
ref.read(appRouterProvider).go(const RootRoute().location);
ref.read(appRouterProvider).back();
```

带参数路由应让 `path` 和 `location` 分离：

```dart
final class MemberDetailRoute extends AppPageRoute {
  const MemberDetailRoute({required this.memberId});

  final String memberId;

  @override
  String get path => '/ptt/member/:memberId';

  @override
  String get location => '/ptt/member/$memberId';

  @override
  Widget buildPage(BuildContext context, AppRouteState state) {
    return MemberDetailPage(memberId: state.pathParameters['memberId']!);
  }
}
```

## 新增业务路由

新增业务页面时，路由由 Feature 自己声明，再通过 `AppFeature` 暴露给 App 汇聚入口。

### 1. 创建 Route

```dart
// lib/features/demo/presentation/demo_routes.dart
final class DemoRoute extends AppPageRoute {
  const DemoRoute();

  @override
  String get path => '/demo';

  @override
  Widget buildPage(BuildContext context, AppRouteState state) {
    return const DemoPage();
  }
}
```

### 2. 创建 Feature 声明

```dart
// lib/features/demo/demo_feature.dart
export 'presentation/demo_routes.dart';

final class DemoFeature extends AppFeature {
  const DemoFeature();

  @override
  String get name => 'demo';

  @override
  List<AppPageRoute> get routes => const [DemoRoute()];
}
```

如果该 Feature 还需要占用底部 Tab，再额外声明 `tabs`。`AppTabEntry` 是抽象协议，负责声明 tab 的稳定 key、文案、图标和根路由：

```dart
final class DemoFeature extends AppFeature {
  const DemoFeature();

  @override
  String get name => 'demo';

  @override
  List<AppPageRoute> get routes => const [DemoRoute()];

  @override
  List<AppTabEntry> get tabs => const [_DemoTabEntry()];
}

final class _DemoTabEntry extends AppTabEntry {
  const _DemoTabEntry();

  @override
  String get key => 'demo.root';

  @override
  String label(BuildContext context) => '示例';

  @override
  String icon(BuildContext context) => context.appAsset.navFunction;

  @override
  String selectedIcon(BuildContext context) {
    return context.appAsset.navFunctionSelected;
  }

  @override
  AppPageRoute get route => const DemoTabRoute();
}
```

没有 Tab 的 Feature 保持默认实现即可，不需要额外配置。

### 3. 注册到 Feature 汇聚入口

```dart
// lib/features/features.dart
import 'demo/demo_feature.dart';

export 'demo/demo_feature.dart';

const List<AppFeature> appFeatures = [
  AuthFeature(),
  TodoFeature(),
  ProfileFeature(),
  DemoFeature(),
];
```

完成后，`appFeatureRoutes` 会自动展开所有 Feature 的普通页面路由，`appFeatureTabs` 会自动汇聚底部 Tab 入口。已作为 Tab 根路由挂到 `RootShellRoute` 的页面不会再重复加入顶层路由表。

## App 装配路由

启动页、根重定向、底部 Tab Shell 属于 App 装配层，不属于某个业务 Feature。

```text
lib/app/host/
  app_host.dart
  app_bootstrap_coordinator.dart
  app_session_coordinator.dart

lib/app/splash/
  splash_page.dart
  splash_route.dart

lib/app/shell/
  root_shell_page.dart
  root_shell_route.dart
```

当前 Shell 结构：

- `/` 由 `RootRoute` 重定向到默认 Feature Tab。
- `RootShellRoute` 从 `appFeatureTabs` 自动装配底部 Tab 分支；没有 Tab 时不会注册 Shell。
- GoRouter 的 `StatefulShellRoute` 只存在于 `app_router_transfor.dart`，不会暴露给业务 Feature。

## 认证守卫

`createAuthGuard()` 接收登录页路径和 public route pattern 列表。`router_provider.dart` 会递归扫描 `_allRouteNodes`，收集 `public == true` 的页面或重定向路径。

```dart
redirect: createAuthGuard(
  loginPath: const LoginRoute().location,
  publicPaths: collectPublicRoutePatterns(_allRouteNodes),
),
```

需要免登录访问的页面在 Route 中覆盖 `public`：

```dart
@override
bool get public => true;
```

公开路由支持动态路径片段匹配。例如 `path = '/article/:id'` 时，实际访问 `/article/42` 也会被识别为公开路由。

模板默认保留根路径 `/` 作为重定向入口，但未登录访问 `/` 时会先进入登录页。需要根路径免登录访问时，应显式将对应重定向路由标记为 `public`。

## 设计约束

- 业务层不直接 import `go_router`，统一通过 `AppPageRoute`、`AppRouteState`、`BaseNavigator` 解耦。
- Feature 只暴露稳定 route class，不让一个 Feature 的 presentation 直接依赖另一个 Feature 的 presentation。
- App Shell、Splash、Root redirect 放在 `lib/app/`，由 App 层组合 Feature 入口。
- `RouterNavigator` 是唯一调用 GoRouter 导航 API 的类。
- `app_router_transfor.dart` 是唯一把项目路由定义转换为 GoRouter RouteBase 的适配层。
- `router.dart` 是 router 模块对外入口；业务常用导出再由 `header.dart` 汇总。

## 修改后验证

路由定义、注册流程或导航行为变更后，优先运行：

```sh
dart format lib/core/router lib/app lib/features
flutter analyze
```

涉及页面跳转行为时，再补充对应页面或集成路径验证。
