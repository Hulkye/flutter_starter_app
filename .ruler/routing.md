# 路由规则

## 核心原则

- 业务层不直接依赖 `go_router`。
- 业务导航通过 `BaseNavigator` 与 `appRouterProvider` 完成。
- `AppPageRoute` 只描述无状态注册信息：`path`、`metadata`、`parse(state)`、`buildPage(context, args)`。
- 实际跳转使用独立的 `AppRouteTarget`；不要把 Route 对象或 `.location` 字符串当成正式导航 API。
- 页面 Route class 继承 `AppPageRoute`，Shell/Redirect 使用对应的 `AppRouteNode` 子类。
- Feature 通过 `XxxFeature extends AppFeature` 暴露路由、Tab、外部入口、Feature Guards 与默认依赖装配。
- `features/features.dart` 保留候选 Feature，`AppFeatureRegistry` 按环境筛选并统一派生普通业务路由、可选底部 Tab 入口、外部入口、Feature Guards、route indexes 与 Provider 覆盖项。
- Feature 必须声明唯一 key 和显式 priority；priority 越小越靠前，相同时按 key 稳定排序。
- 注册表必须 fail-fast 校验 Feature key、route key/path、Tab key 唯一，并校验 Tab route 由所属 Feature 声明。
- `features/exports.dart` 汇聚业务页面需要通过 `header.dart` 使用的 route class 和公开类型。
- App 组合层通过 `lib/app/navigation/app_router_config.dart` 组装 Splash、Root/Shell、Feature 路由与 App 公共路由，并以 `AppRouterConfig` 注入 `core/router`。
- 通用页面能力的公共路由可由 App 组合层直接注册，例如 `shared/webview` 的 `WebPageRoute` / `AuthWebPageRoute`；不要为这类非业务能力创建 `AppFeature`。
- `core/router` 只提供路由定义、GoRouter 适配、守卫和导航 Provider，不 import `app/`、`features/` 或 Toast。
- Toast 等 NavigatorObserver 由 App 组合层通过 `AppRouterConfig.observers` 注入。
- 无底部 Tab 时不要创建 `/` 的 Root redirect 或 Root Shell；应提供明确首页路由或自定义登录后的目标页。

## 新增路由流程

1. 在 `lib/features/<feature>/presentation/<feature>_routes.dart` 创建 `XxxRoute extends AppPageRoute`。
2. 覆盖 `parse(state)` 解析类型化参数，`buildPage(context, args)` 只接收已解析参数。
3. 定义独立的 `XxxTarget extends AppRouteTargetBase`；带参数地址使用 `AppRouteLocation.withPathParameters`。
4. 在 `lib/features/<feature>/<feature>_feature.dart` 创建 `XxxFeature extends AppFeature`，声明 `AppFeatureMetadata` 的唯一 key、priority 与允许环境。
5. 在 `XxxFeature.routes` 中返回当前 Feature 的路由列表。
6. 如需底部 Tab，在 `XxxFeature.tabs` 中返回 `AppTabEntry`，必须同时声明 `route` 和 `initialTarget`，由 `RootShellRoute` 自动装配。
7. 免登录页面通过 `XxxFeature.routePolicies` 声明 `AppRoutePolicy(requiresAuthentication: false)`，不要在 Route 上写 `public`。
8. 如存在默认 data 实现，在 `XxxFeature.providerOverrides` 中装配 domain binding Provider。
9. 在 `lib/features/features.dart` import `XxxFeature` 并加入 `appFeatures`。
10. `lib/app/navigation/app_router_config.dart` 会从 `appFeatures` 自动组合到 App 路由图，通常无需修改 `core/router/config/router_provider.dart`。
11. 如 route class 需要给业务页面使用，在 `lib/features/exports.dart` 导出。
12. 业务页面通过 `package:flutter_starter_app/header.dart` 使用 route class、Target 和 `appRouterProvider`。

## 禁止事项

- 不要在 `core/router/config/router_provider.dart` 中逐个 import 业务 route 文件。
- 不要在 `core/router` 中 import `app/`、`features/` 或 Toast 来装配具体路由或 UI；应用路由图必须由 App 组合层注入。
- 不要在业务页面直接 import `go_router`。
- 不要在 `app/`、`core/`、`shared/` 内部通过 `header.dart` 获取路由或公共能力；这些层应使用精确 import。
- 不要把路由匹配定义和导航目标混用：
  - `path` 用于路由匹配，例如 `/profile/:userId`；
  - `AppRouteTarget` 用于实际跳转，例如 `ProfileDetailTarget(userId: '42')`。
- 不要再使用 `createAuthGuard` / `createStrictAuthGuard`；正式入口是 `createAccessGuard`。
- 不要再使用 `AppPageRoute.public`、`XxxRouteArgs.fromState` 或 `push(XxxRouteTarget.location)`。

## 导航示例

```dart
import 'package:flutter_starter_app/header.dart';

ref.read(appRouterProvider).push(const LoginTarget());
```

带参数路由：

```dart
ref.read(appRouterProvider).push(
  const ProfileDetailTarget(userId: '42'),
);
```

WebView：

```dart
ref.read(appRouterProvider).push(
  const WebPageTarget(
    WebPageConfig(url: 'https://example.com/privacy'),
  ),
);
```

## 守卫规则

- `core/router` 守卫只消费 `RouteAccessDecision`，不直接读取具体业务状态。
- App 组合层监听会话、启动、升级、资料、权限或租户 Provider，并按业务优先级生成最终决策。
- 模板默认 Guard 顺序为 Bootstrap → Authentication → Feature Guards；`AppRouteGuardChain` 遇到第一个 `RedirectRoute` 立即返回。
- 使用 `RedirectRoute.appliesToPublicRoutes` 显式声明强制升级等全局门禁是否覆盖公开路由。
- 使用 `RedirectRoute.preserveTarget` 显式声明登录后是否返回原始目标页。
- 公开路由通过 Feature 的 `AppRoutePolicy` 声明，再由 `AppFeatureRegistry.publicRoutePatterns` 派生。
- 登录目标应使用 `const LoginTarget()`，避免硬编码分散。

## 文档同步

- 仅当路由使用方式或对外契约变化时，更新 `lib/core/router/README.md`、`README.md` 或 `docs/template_usage.md` 中直接受影响的说明。
- 路由实现或规则内部调整但不改变使用方式时，不要求在多份文档重复维护规则。
