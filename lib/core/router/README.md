# Router 模块

`core/router` 是业务层与 GoRouter 之间的隔离层。业务代码通过项目路由抽象和 `BaseNavigator` 导航，不直接 import `go_router`。

## 当前职责

- 对业务层暴露框架无关的路由定义：`AppPageRoute`、`AppRouteTarget`、`AppRedirectRoute`、`AppShellRoute`。
- 对业务层暴露导航接口：`BaseNavigator` 与 `appRouterProvider`。
- 在基础设施层把 `AppRouteNode` 转换为 GoRouter 的 `RouteBase`。
- 通过 `AppRouterConfig` 接收 App 组合层注入的路由图、公开路由模板、NavigatorObserver 和错误页。
- 通过 GoRouter Guard adapter 执行 App 组合层注入的 `RouteAccessDecision`，不枚举登录、升级、租户等业务状态。
- App Shell 的 Tab 入口由 Feature 显式声明，Shell 只做装配。

## 文件清单

| 文件 | 职责 | 引用 GoRouter? |
|:---|:---|:---:|
| `router.dart` | router 模块对外 barrel export | — |
| `definitions/router_definitions.dart` | 路由定义类型内部 barrel export | ❌ |
| `definitions/app_route_node.dart` | `AppRouteNode` 路由节点基类 | ❌ |
| `definitions/app_page_route.dart` | `AppPageRoute` 普通页面路由 | ❌ |
| `definitions/app_route_target.dart` | `AppRouteTarget` 导航目标与 location 工具 | ❌ |
| `definitions/app_route_metadata.dart` | `AppRouteMetadata` 稳定 key 与匹配模板 | ❌ |
| `definitions/app_redirect_route.dart` | `AppRedirectRoute` 重定向路由 | ❌ |
| `definitions/app_shell_route.dart` | `AppShellRoute` Shell 路由 | ❌ |
| `definitions/app_shell_branch.dart` | `AppShellBranch` Shell 分支定义 | ❌ |
| `definitions/app_shell_navigator.dart` | `AppShellNavigator` Shell 分支导航接口 | ❌ |
| `definitions/app_route_state.dart` | `AppRouteState` 框架无关路由状态 | ❌ |
| `definitions/app_route_error.dart` | `AppRouteError` 框架无关路由错误上下文 | ❌ |
| `navigation/base_navigator.dart` | `BaseNavigator` 导航抽象接口 | ❌ |
| `adapters/router_navigator.dart` | 对外稳定的 `RouterNavigator` 门面 | ❌ |
| `adapters/go_router/router_navigator.dart` | `RouterNavigator` 的 GoRouter 导航实现 | ✅ |
| `adapters/go_router/route_transform.dart` | `AppRouteNode` 到 `RouteBase` 的适配器 | ✅ |
| `adapters/go_router/access_guard.dart` | GoRouter 状态到访问请求及 redirect 的适配器 | ✅ |
| `config/router_provider.dart` | `AppRouterConfig`、GoRouter、导航接口 Provider | ✅ |
| `guards/route_access_decision.dart` | `AllowRoute` / `RedirectRoute` 最终访问决策 | ❌ |
| `guards/app_route_guard.dart` | `AppRouteGuard` / `AppRouteGuardChain` | ❌ |
| `guards/app_route_request.dart` | Guard 判断当前访问时的路由上下文 | ❌ |
| `guards/router_guard.dart` | 框架无关的访问决策与重定向计算 | ❌ |
| `guards/internal_route_location.dart` | 应用内 location 校验，供导航与重定向共用 | ❌ |

## 分层关系

```text
Feature / App Page
  import 'package:flutter_starter_app/header.dart'
  ref.read(appRouterProvider).push(const TodoTarget())
        │
        ▼
core/router definitions
  AppRouteNode / AppPageRoute / AppRouteTarget / AppShellRoute / AppRouteState
        │
        ▼
core/router/adapters/go_router
  toRouteBase() / RouterNavigator / createGoRouterAccessGuard()
        │
        ▼
GoRouter
  GoRoute / StatefulShellRoute / GoRouterState
```

`core/router` 不 import `app/`、`features/` 或具体 UI 组件。Toast 这类 NavigatorObserver 由 App 组合层通过 `AppRouterConfig.observers` 注入。GoRouter adapter 不经 `router.dart` 导出；Router 配置实现通过具体文件路径引用它们。

业务代码通过 `BaseNavigator` 的类型化 `AppRouteTarget` 方法导航。对外稳定门面 `adapters/router_navigator.dart` 中的 `RouterNavigator` 委托给具体实现；GoRouter 的同名实现位于 `adapters/go_router/router_navigator.dart`，不经 `router.dart` 公共 barrel 导出。组合层负责选择并注入实现，通用访问决策与内部 location 校验仍位于 `guards/`。

## 定义类型

### AppRouteNode

`AppRouteNode` 是路由注册表的统一节点类型，目前包含三类实现：

- `AppPageRoute`：普通页面路由。
- `AppRedirectRoute`：只做重定向的路由，例如 `/ -> /todo`。
- `AppShellRoute`：多分支 Shell 路由，例如底部 Tab 的独立导航栈。

### AppPageRoute 与 AppRouteTarget

`AppPageRoute<TArgs>` 是无状态路由注册定义：`path` 用于匹配，`parse(state)` 解析页面参数，`buildPage(context, args)` 构建页面。导航使用独立的 `AppRouteTarget`，不要把 Route 对象当成跳转地址。

```dart
final class SettingRoute extends AppPageRoute<void> {
  const SettingRoute();

  @override
  String get path => '/mine/setting';

  @override
  void parse(AppRouteState state) {}

  @override
  Widget buildPage(BuildContext context, void args) {
    return const SettingPage();
  }
}

final class SettingTarget extends AppRouteTargetBase {
  const SettingTarget();

  @override
  String get location => const SettingRoute().path;
}
```

- `path`：GoRouter 匹配模式，例如 `/ptt/member/:memberId`。
- `metadata`：稳定 `key` 与匹配模板；未覆盖时默认 `key = path`。
- `parse()`：把 `AppRouteState` 解析成类型化参数。
- `buildPage()`：只接收 `BuildContext` 和已解析的 `TArgs`。

页面入参通过类型化 Target 传递。Route 声明匹配路径并在 `parse()` 中从
`AppRouteState` 读取参数，最后把解析后的 Args 交给 `buildPage()`。多个参数应收敛到
一个 Args 类型中，避免页面构建接口随着参数增加而膨胀。

参数位置建议按用途选择：

- 必需的资源标识、层级关系放在 path，例如 `/members/:memberId`。
- 可选筛选、分页、展示状态等可分享参数放在 query，例如 `?tab=posts&page=2`。
- 仅当前进程内使用、无需深链或冷启动恢复的对象可通过 `extra` 传递；恢复所需数据不要只放在 `extra` 中。

下面示例展示多个 path/query 参数的完整传递：

```dart
final class MemberDetailArgs {
  const MemberDetailArgs({
    required this.memberId,
    required this.from,
    this.tab,
  });

  final String memberId;
  final String from;
  final String? tab;
}

final class MemberDetailRoute extends AppPageRoute<MemberDetailArgs> {
  const MemberDetailRoute();

  static const String routeKey = 'member.detail';
  static const String pathValue = '/ptt/member/:memberId';

  @override
  String get path => pathValue;

  @override
  AppRouteMetadata get metadata =>
      const AppRouteMetadata(key: routeKey, path: pathValue);

  @override
  MemberDetailArgs parse(AppRouteState state) => MemberDetailArgs(
    memberId: state.requiredPathParameter('memberId'),
    from: state.requiredQueryParameter('from'),
    tab: state.queryParameter('tab'),
  );

  @override
  Widget buildPage(BuildContext context, MemberDetailArgs args) {
    return MemberDetailPage(args: args);
  }
}

final class MemberDetailTarget extends AppRouteTargetBase {
  const MemberDetailTarget({
    required this.memberId,
    required this.from,
    this.tab,
  });

  final String memberId;
  final String from;
  final String? tab;

  @override
  String get location {
    final path = AppRouteLocation.withPathParameters(
      MemberDetailRoute.pathValue,
      {'memberId': memberId},
    );
    return AppRouteLocation.withQuery(path, {
      'from': from,
      if (tab != null) 'tab': tab!,
    });
  }
}
```

页面或 ViewModel 通过统一导航接口跳转：

```dart
ref.read(appRouterProvider).push(
  const MemberDetailTarget(
    memberId: '42',
    from: 'search',
    tab: 'posts',
  ),
);
```

`AppRouteState` 提供 `pathParameter()` / `requiredPathParameter()` 和
`queryParameter()` / `requiredQueryParameter()`；必需参数缺失或为空时会显式抛出
`FormatException`。Target 侧使用 `AppRouteLocation.withPathParameters()` 编码 path 参数，
使用 `AppRouteLocation.withQuery()` 编码 query 参数，避免手动拼接和遗漏 URI 编码。

对于只在当前进程内传递的附加对象，可在 Target 中覆写 `extra`：

```dart
final class EditMemberTarget extends AppRouteTargetBase {
  const EditMemberTarget({required this.member});

  final Member member;

  @override
  String get location => '/members/${member.id}/edit';

  @override
  Object get extra => member;
}
```

Route 可通过 `state.extra` 读取该对象，并应在 `parse()` 中校验类型。由于 `extra` 不适合作为
可分享 URL 或冷启动恢复数据的唯一来源，编辑页若可从成员 ID 重新加载数据，应仍将 ID 放在 path 中。

公开路由不在 `AppPageRoute` 上标记。Feature 通过 `AppRoutePolicy(requiresAuthentication: false)` 声明，再由 `AppFeatureRegistry.publicRoutePatterns` 派生匹配模板。

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

### 路由错误页面

未知路径、路由解析失败等错误由 `core/router` 转换为框架无关的 `AppRouteError`。App 组合层可以通过 `AppRouterConfig.errorBuilder` 注入业务错误页：

```dart
AppRouterConfig(
  routeNodes: routes,
  initialLocation: const SplashTarget().location,
  errorBuilder: (context, error) => AppRouteErrorPage(
    location: error.location,
  ),
)
```

`core/router` 不依赖具体业务错误页面；未注入构建器时使用通用错误页。错误页构建器只负责展示，错误恢复、日志上报和返回目标由 App 组合层决定。

### AppShellRoute

`AppShellRoute` 用来表达 App Shell 的分支结构。底层会在 `route_transform.dart` 中转换为 `StatefulShellRoute.indexedStack`。

```dart
final class RootShellRoute extends AppShellRoute {
  RootShellRoute({required List<AppTabEntry> tabs})
    : super(
        branches: <AppShellBranch>[
          for (final tab in tabs)
            AppShellBranch(
              initialLocation: tab.initialTarget.location,
              routes: <AppPageRoute<dynamic>>[tab.route],
            ),
        ],
        builder: (context, state, shellNavigator) =>
            RootShellPage(shellNavigator: shellNavigator, tabs: tabs),
      );
}
```

`AppTabEntry` 必须同时声明 `route` 和 `initialTarget`。没有底部 Tab 时不要创建 `/` 的 Root redirect 或 Root Shell。

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
    initialLocation: const SplashTarget().location,
    publicRoutePatterns: <String>[
      ...featureRegistry.publicRoutePatterns,
      const SplashRoute().path,
      WebPageRoute.pathValue,
    ],
    observers: <NavigatorObserver>[ToastUtil.navigatorObserver],
  );
}
```

注册顺序含义：

- `SplashRoute`：启动展示页，属于 `lib/app/navigation/splash/`。
- `RootRoute`：有 Tab 时才注册，`/` 重定向到默认 Tab。
- `RootShellRoute`：有 Tab 时才注册的底部 Tab Shell，属于 `lib/app/navigation/shell/`。
- `featureRegistry.routes`：当前环境启用的普通业务页面路由；已挂到 Shell Tab 的根路由不会重复注册到顶层。
- `WebPageRoute` / `AuthWebPageRoute`：来自 `shared/webview` 的通用 WebView 公共路由，由 App 组合层注册，不作为业务 Feature。
- `observers`：App 组合层注入的 NavigatorObserver；`core/router` 不绑定 Toast 或其他 UI 组件。

外部链接由可选 package `app_deep_link` 和 App 层宿主适配共同处理。业务 Deep Link 目标由所属 Feature 通过 `AppExternalRoute` 显式声明，并由当前环境的 `AppFeatureRegistry.externalRoutes` 汇总。App 集成适配层只把这份注册结果转换为 `DeepLinkRoute`，不得重新 import 或硬编码业务 Feature 路由。页面路由本身不感知具体 Deep Link package。Deep Link、Push 和其他入口最终统一转换为 `AppNavigationCommand`；页面不应自行解析外部 URI。

同时，`RootShellRoute` 不再手写 tab 分支，而是从当前环境的 Feature 注册表自动装配：

```dart
buildRootRouteNodes(tabs: featureRegistry.tabs);
```

这样一个 Feature 可以：

- 提供多个 Tab 入口。
- 只提供普通页面路由、不提供 Tab，例如 `auth`。
- 通过 `providerOverrides` 提供默认 data 实现装配。
- 通过 `externalRoutes` 声明允许外部入口打开的页面。
- 通过 `routePolicies` 声明静态访问策略，例如免登录页面。
- 通过 `guards` 声明 Feature 级运行态访问规则。
- 由 App Shell 统一决定展示顺序，而不是把业务页面写死在 Shell 内部。

`Application.run()` 会按当前环境构建一次 `AppFeatureRegistry`，把其中的 routes、tabs、externalRoutes、guards、routePolicies、providerOverrides 分别交给 App 路由、外部入口适配层和根 `ProviderScope`。这些能力因此始终来自同一批启用 Feature。`goRouterProvider` 只消费注入后的 `AppRouterConfig` 创建 GoRouter；`appRouterProvider` 对外暴露 `BaseNavigator`。

## 导航用法

业务层优先从 `package:flutter_starter_app/header.dart` 获取路由与导航 Provider。App/Core/Shared 内部不要通过 `header.dart` 获取依赖，应直接 import 所需模块。

```dart
ref.read(appRouterProvider).push(const TodoTarget());
ref.read(appRouterProvider).go(const RootTarget());
ref.read(appRouterProvider).back();
```

带参数路由直接构造 Target：

```dart
ref.read(appRouterProvider).push(
  const MemberDetailTarget(memberId: '42'),
);
```

需要传递无法放入 query 的高级配置时，把类型化对象放在 Target 的 `extra` 上。WebView 示例：

```dart
ref.read(appRouterProvider).push(
  const AuthWebPageTarget(
    WebPageConfig(url: 'https://example.com/member'),
  ),
);
```

`BaseNavigator` 的正式 API 接收 `AppRouteTarget`。`goLocation` / `pushLocation` 只作为兼容期字符串 API，新代码不要再传 `.location` 字符串。

## 新增业务路由

新增业务页面时，路由由 Feature 自己声明，再通过 `AppFeature` 暴露给 App 汇聚入口。

### 1. 创建 Route 与 Target

```dart
// lib/features/demo/presentation/demo_routes.dart
final class DemoRoute extends AppPageRoute<void> {
  const DemoRoute();

  static const String routeKey = 'demo.home';
  static const String pathValue = '/demo';

  @override
  String get path => pathValue;

  @override
  AppRouteMetadata get metadata =>
      const AppRouteMetadata(key: routeKey, path: pathValue);

  @override
  void parse(AppRouteState state) {}

  @override
  Widget buildPage(BuildContext context, void args) {
    return const DemoPage();
  }
}

final class DemoTarget extends AppRouteTargetBase {
  const DemoTarget();

  @override
  String get location => DemoRoute.pathValue;
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
  List<AppPageRoute<dynamic>> get routes => const [DemoRoute()];
}
```

如果该 Feature 还需要占用底部 Tab，再额外声明 `tabs`。若页面需要接受 Deep Link 等 App 外部入口，再声明 `externalRoutes`；只将确实允许外部打开的路由加入，不要把所有页面默认暴露。`AppExternalRoute` 负责声明外部入口稳定 key 与所属页面路由，不依赖具体外部入口 package。

免登录页面通过 `routePolicies` 声明，而不是在 Route 上写 `public`：

```dart
@override
List<AppRoutePolicy> get routePolicies => const [
  AppRoutePolicy(
    routeKey: DemoRoute.routeKey,
    requiresAuthentication: false,
  ),
];
```

`AppTabEntry` 是抽象协议，负责声明 tab 的稳定 key、文案、图标、根路由和初始 Target：

```dart
final class DemoFeature extends AppFeature {
  const DemoFeature();

  @override
  AppFeatureMetadata get metadata =>
      const AppFeatureMetadata(key: 'demo', priority: 400);

  @override
  List<AppPageRoute<dynamic>> get routes => const [DemoRoute()];

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
  AppPageRoute<dynamic> get route => const DemoRoute();

  @override
  AppRouteTarget get initialTarget => const DemoTarget();
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

完成后，`AppFeatureRegistry` 会按环境筛选、按 priority 和 key 排序，并展开普通页面路由、Tab、外部入口、访问策略、Feature Guards 与 Provider overrides。已作为 Tab 根路由挂到 `RootShellRoute` 的页面不会再重复加入顶层路由表。Feature key、route key/path、Tab key、外部入口 key/path 冲突以及 Tab/外部入口引用非所属 Feature 路由时，会在注册表构建时立即失败。

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
- GoRouter 的 `StatefulShellRoute` 只存在于 `route_transform.dart`，不会暴露给业务 Feature。

## 访问决策守卫

访问控制分三层，不要混用：

| 层 | 类型 | 职责 |
|:---|:---|:---|
| 静态策略 | `AppRoutePolicy` | Feature 声明某条路由是否要求登录 |
| 运行态规则 | `AppRouteGuard` / `AppRouteGuardChain` | 按请求计算 `AllowRoute` 或 `RedirectRoute` |
| 执行器 | `createAccessGuard` | 只消费最终决策，不读取业务 Provider |

`RouteAccessDecision` 仅包含两种结果：

- `AllowRoute`：允许当前访问，也可声明已登录访问登录页等少量入口替代规则。
- `RedirectRoute`：重定向到明确 `AppRouteTarget`，可选择保留原始目标，或覆盖公开路由。

Guard 使用 GoRouter 已匹配的 `GoRouterState.fullPath` 作为唯一当前路由模板。例如访问 `/article/42` 时，Guard 接收到的模板是 `/article/:id`；公开路由判断、路由元数据查找和入口替代规则都基于该模板精确比较。`core/router` 不再维护第二套路径语法或自行解释动态参数、通配符和嵌套路由。

core/router 不枚举启动、Token、资料、升级、权限或租户等业务状态，也不维护状态到 location 的映射。App 组合层监听各业务 Provider，按产品优先级生成最终决策，并通过 `routeAccessDecisionProvider` override 注入。

模板默认 Guard 顺序：

```text
Bootstrap（未完成时直接 Redirect Splash，覆盖公开路由）
  ↓
Authentication
  ↓
Feature Guards
```

`AppRouteGuardChain` 遇到第一个 `RedirectRoute` 立即返回。因此认证必须排在 Feature Guards 之前，避免未登录用户先被 Feature 规则送到升级页、资料页或其他业务门禁。

模板默认的 App 组合只处理登录态：未登录时跳登录页并保留原目标；已登录时允许访问，但访问登录页会返回首页。

```dart
redirect: createAccessGuard(
  accessDecision: (request) => ref.read(routeAccessDecisionProvider)(request),
  routeNodes: routerConfig.routeNodes,
  publicPaths: routerConfig.publicRoutePatterns,
),
```

需要增加强制升级时，应在 App 决策 Provider 或 Feature Guard 中返回：

```dart
const RedirectRoute(
  target: UpgradeTarget(),
  appliesToPublicRoutes: true,
)
```

目标页已是升级页时守卫会放行，避免重定向循环。资料补充、重新认证、权限不足和租户选择采用同一决策类型，不需要修改 core/router。

需要免登录访问的页面在 Feature 中覆盖 `routePolicies`：

```dart
@override
List<AppRoutePolicy> get routePolicies => const [
  AppRoutePolicy(
    routeKey: ArticleRoute.routeKey,
    requiresAuthentication: false,
  ),
];
```

公开路由按 `path` 模板精确比较。例如 `path = '/article/:id'` 时，实际访问 `/article/42` 的匹配模板仍是 `/article/:id`，会被识别为公开路由。

模板在存在底部 Tab 时保留根路径 `/` 作为重定向入口，但未登录访问 `/` 时会先进入登录页。无 Tab 时不会创建 Root redirect，需要由业务显式提供首页路由或自定义启动后的目标页。

### 登录后的目标页

未登录访问受保护路由时，守卫将完整内部 location 放入登录页的 `redirect` query 参数，例如：

```text
/login?redirect=%2Ftodo%3Ffilter%3Dopen
```

登录成功后，登录页只接受根路径形式的内部 location，并使用 `replaceAll()` 返回目标页。带 scheme 或 authority 的外部 URL 会被拒绝；没有目标参数时由 App 组合层的 `AllowRoute.redirects` 决定默认首页。当前 `AllowRoute.redirects` 仍以匹配 path/location 为 key。

## 设计约束

- 业务层不直接 import `go_router`，统一通过 `AppPageRoute`、`AppRouteTarget`、`AppRouteState`、`BaseNavigator` 解耦。
- Feature 只暴露稳定 route class 和 Target，不让一个 Feature 的 presentation 直接依赖另一个 Feature 的 presentation。
- App Shell、Splash、Root redirect 放在 `lib/app/navigation/`，由 App 层组合 Feature 入口；无 Tab 时不注册 Root redirect。
- `core/router` 不 import `app/`、`features/` 或 Toast；应用路由图、公开策略、observers 只能通过 `AppRouterConfig` 注入。
- `features/features.dart` 是 App 注册表，`features/exports.dart` 是业务公共导出入口；不要让 `header.dart` 间接导出 Feature 默认 data 装配。
- `header.dart` 只服务业务页面便捷导入，App/Core/Shared 内部使用精确 import，避免形成 `shared -> header -> features`。
- `RouterNavigator` 是唯一调用 GoRouter 导航 API 的类。
- `route_transform.dart` 是唯一把项目路由定义转换为 GoRouter RouteBase 的适配层。
- `createAccessGuard` 是正式守卫入口；不要再引入 `createAuthGuard` / `createStrictAuthGuard`。
- `router.dart` 是 router 模块对外入口；业务常用导出再由 `header.dart` 汇总。

## 修改后验证

路由定义、注册流程或导航行为变更后，优先运行：

```sh
dart format lib/core/router lib/app lib/features
flutter analyze
flutter test test/app/navigation/app_router_config_test.dart test/core/router
```

涉及页面跳转行为时，再补充对应页面或集成路径验证。
