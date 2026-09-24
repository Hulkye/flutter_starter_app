# Router 模块

`core/router` 是业务层与 GoRouter 之间的隔离层。业务代码通过项目路由抽象和 `BaseNavigator` 导航，不直接 import `go_router`。

## 当前职责

- 对业务层暴露框架无关的路由定义：`AppPageRoute`、`AppRedirectRoute`、`AppShellRoute`。
- 对业务层暴露导航接口：`BaseNavigator` 与 `appRouterProvider`。
- 在基础设施层把 `AppRouteNode` 转换为 GoRouter 的 `RouteBase`。
- 通过 `AppRouterConfig` 接收 App 组合层注入的路由图和初始页。
- 在 `router_provider.dart` 创建 GoRouter、状态机守卫和导航 Provider。
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
| `router_provider.dart` | `AppRouterConfig`、GoRouter、导航接口、守卫 Provider | ✅ |
| `route_access_decision.dart` | `AllowRoute` / `RedirectRoute` 最终访问决策 | ❌ |
| `router_guard.dart` | 访问决策执行、认证守卫和目标页安全校验 | ✅ |

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

`core/router` 不维护具体应用路由表；应用总路由图由 `lib/app/navigation/app_router_config.dart` 在 App 组合层创建，并通过 `appRouterConfigProvider` 注入：

```dart
AppRouterConfig createAppRouterConfig(AppFeatureRegistry featureRegistry) {
  return AppRouterConfig(
    routeNodes: <AppRouteNode>[
      const SplashRoute(),
      ...buildRootRouteNodes(tabs: featureRegistry.tabs),
      ...featureRegistry.routes,
      const WebPageRoute(),
      const AuthWebPageRoute(),
    ],
    initialLocation: const SplashRoute().location,
  );
}
注册顺序含义：

- `SplashRoute`：启动展示页，属于 `lib/app/navigation/splash/`。
- `RootRoute`：有 Tab 时才注册，`/` 重定向到默认 Tab。
- `RootShellRoute`：有 Tab 时才注册的底部 Tab Shell，属于 `lib/app/navigation/shell/`。
- `featureRegistry.routes`：当前环境启用的普通业务页面路由；已挂到 Shell Tab 的根路由不会重复注册到顶层。
- `WebPageRoute` / `AuthWebPageRoute`：来自 `shared/webview` 的通用 WebView 公共路由，由 App 组合层注册，不作为业务 Feature。

外部链接由可选 package `app_deep_link` 和 App 层宿主适配共同处理。
Deep Link 目标由 App 组合层的外部入口注册表显式声明，页面路由本身不感知 Deep Link。
Deep Link、Push 和其他入口最终统一转换为 `AppNavigationCommand`，其中的 path 参数和
query 参数由命令直接承载；页面不应自行解析外部 URI。

同时，`RootShellRoute` 不再手写 tab 分支，而是从当前环境的 Feature 注册表自动装配：

```dart
buildRootRouteNodes(tabs: featureRegistry.tabs);
```

这样一个 Feature 可以：

- 提供多个 Tab 入口，例如 `ptt`。
- 只提供普通页面路由、不提供 Tab，例如 `auth`。
- 通过 `providerOverrides` 提供默认 data 实现装配，例如 Repository binding。
- 由 App Shell 统一决定展示顺序，而不是把业务页面写死在 Shell 内部。

`Application.run()` 会按当前环境构建一次 `AppFeatureRegistry`，把其中的 `providerOverrides` 与 `createAppRouterOverrides(featureRegistry)` 加入 `ProviderScope.overrides`。路由、Tab 和依赖注入因此始终来自同一批启用 Feature。`goRouterProvider` 只消费注入后的 `AppRouterConfig` 创建 GoRouter；`appRouterProvider` 对外暴露 `BaseNavigator`。

## 导航用法

业务层优先从 `package:flutter_starter_app/header.dart` 获取路由与导航 Provider。
App/Core/Shared 内部不要通过 `header.dart` 获取依赖，应直接 import 所需模块。

```dart
ref.read(appRouterProvider).push(const TodoRoute().location);
ref.read(appRouterProvider).go(RootRoute.location);
ref.read(appRouterProvider).back();
```

需要传递无法放入 query 的高级配置时，可通过 `extra` 传入类型化对象。`AppRouteState.extra` 会在 Route 的 `buildPage()` 中暴露给页面：

```dart
ref.read(appRouterProvider).push(
  const AuthWebPageRoute().location,
  extra: const WebPageConfig(url: 'https://example.com/member'),
);
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
final class DemoFeature extends AppFeature {
  const DemoFeature();

  @override
  AppFeatureMetadata get metadata =>
      const AppFeatureMetadata(key: 'demo', priority: 400);

  @override
  List<AppPageRoute> get routes => const [DemoRoute()];
}
```

如果该 Feature 还需要占用底部 Tab，再额外声明 `tabs`。`AppTabEntry` 是抽象协议，负责声明 tab 的稳定 key、文案、图标和根路由：

```dart
final class DemoFeature extends AppFeature {
  const DemoFeature();

  @override
  AppFeatureMetadata get metadata =>
      const AppFeatureMetadata(key: 'demo', priority: 400);

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

const List<AppFeature> appFeatures = [
  AuthFeature(),
  TodoFeature(),
  ProfileFeature(),
  DemoFeature(),
];
```

完成后，`AppFeatureRegistry` 会按环境筛选、按 priority 和 key 排序，并展开普通页面路由、Tab 与 Provider overrides。已作为 Tab 根路由挂到 `RootShellRoute` 的页面不会再重复加入顶层路由表。Feature key、route path、Tab key 冲突以及 Tab route 来源不匹配会在注册表构建时立即失败。

如果业务页面需要通过 `header.dart` 使用新 route class，再把它加入公共导出文件：

```dart
// lib/features/exports.dart
export 'demo/presentation/demo_routes.dart';
```

## App 装配路由

启动页、根重定向、底部 Tab Shell 属于 App 装配层，不属于某个业务 Feature。

```text
lib/app/host/
  app_host.dart
  app_bootstrap_coordinator.dart
  app_session_coordinator.dart

lib/app/navigation/
  app_router_config.dart
  splash/
    splash_page.dart
    splash_route.dart
  shell/
    root_shell_page.dart
    root_shell_route.dart
```

当前 Shell 结构：

- 有 Tab 时，`/` 由 `RootRoute` 重定向到默认 Feature Tab。
- `RootShellRoute` 从当前环境 `AppFeatureRegistry.tabs` 自动装配底部 Tab 分支。
- 没有 Tab 时，不注册 `RootRoute` 和 `RootShellRoute`，避免 `/` 自重定向；模板使用者应提供明确的首页路由或自定义启动后的目标页。
- `app_router_config.dart` 负责把 Splash、Root/Shell、Feature 路由与 App 公共路由组合成 `AppRouterConfig` 并注入 core/router。
- GoRouter 的 `StatefulShellRoute` 只存在于 `app_router_transfor.dart`，不会暴露给业务 Feature。

## 访问决策守卫

`RouteAccessDecision` 是路由守卫消费的稳定契约，仅包含两种结果：

- `AllowRoute`：允许当前访问，也可声明已登录访问登录页等少量入口替代规则。
- `RedirectRoute`：重定向到明确 location，可选择保留原始目标，或覆盖公开路由。

core/router 不枚举启动、Token、资料、升级、权限或租户等业务状态，也不维护状态到
location 的映射。App 组合层监听各业务 Provider，按产品优先级生成一个最终决策，
并通过 `routeAccessDecisionProvider` override 注入。

模板默认的 App 组合只处理登录态：未登录时跳登录页并保留原目标；已登录时允许访问，
但访问登录页会返回首页。

```dart
redirect: createAccessGuard(
  accessDecision: () => ref.read(routeAccessDecisionProvider),
  publicPaths: collectPublicRoutePatterns(routerConfig.routeNodes),
),
```

需要增加强制升级时，应在 App 决策 Provider 中优先返回：

```dart
const RedirectRoute(
  location: '/upgrade',
  appliesToPublicRoutes: true,
)
```

目标页已是 `/upgrade` 时守卫会放行，避免重定向循环。资料补充、重新认证、权限不足
和租户选择采用同一决策类型，不需要修改 core/router。

需要免登录访问的页面在 Route 中覆盖 `public`：

```dart
@override
bool get public => true;
```

公开路由支持动态路径片段匹配。例如 `path = '/article/:id'` 时，实际访问 `/article/42` 也会被识别为公开路由。

模板在存在底部 Tab 时保留根路径 `/` 作为重定向入口，但未登录访问 `/` 时会先进入登录页。无 Tab 时不会创建 Root redirect，需要由业务显式提供首页路由或自定义启动后的目标页。

### 登录后的目标页

未登录访问受保护路由时，守卫将完整内部 location 放入登录页的 `redirect` query 参数，例如：

```text
/login?redirect=%2Ftodo%3Ffilter%3Dopen
```

登录成功后，登录页只接受根路径形式的内部 location，并使用 `replaceAll()` 返回目标页。
带 scheme 或 authority 的外部 URL 会被拒绝；没有目标参数时由 App 组合层的
`AllowRoute.redirects` 决定默认首页。

## 设计约束

- 业务层不直接 import `go_router`，统一通过 `AppPageRoute`、`AppRouteState`、`BaseNavigator` 解耦。
- Feature 只暴露稳定 route class，不让一个 Feature 的 presentation 直接依赖另一个 Feature 的 presentation。
- App Shell、Splash、Root redirect 放在 `lib/app/navigation/`，由 App 层组合 Feature 入口；无 Tab 时不注册 Root redirect。
- `core/router` 不 import `app/` 或 `features/`；应用路由图只能通过 `AppRouterConfig` 注入。
- `features/features.dart` 是 App 注册表，`features/exports.dart` 是业务公共导出入口；不要让 `header.dart` 间接导出 Feature 默认 data 装配。
- `header.dart` 只服务业务页面便捷导入，App/Core/Shared 内部使用精确 import，避免形成 `shared -> header -> features`。
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
