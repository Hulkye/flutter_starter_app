---
name: route-module
description: "Use when: adding, changing, reviewing, or documenting app routes, AppPageRoute/AppRouteNode classes, AppFeature route aggregation, router_provider, navigation, auth guards, or route exports."
---

# 路由模块工作流

当任务涉及路由、新页面跳转、认证守卫或 route export 时，遵循本技能。

## 路由新增流程

1. 在对应 Feature 的 `presentation/<feature>_routes.dart` 中创建 Route class。
2. 页面 Route class 继承 `AppPageRoute`。
3. `path` 表示 GoRoute 匹配路径；`metadata` 提供稳定 `key`。
4. 覆盖 `parse(state)` 解析类型化参数；`buildPage(context, args)` 只接收已解析参数。
5. 定义独立的 `XxxTarget extends AppRouteTargetBase`；带参数地址使用 `AppRouteLocation.withPathParameters`。
6. 在 `<feature>_feature.dart` 的 `routes` 中暴露该路由。
7. 如果该路由是底部 Tab 根路由，在 `<feature>_feature.dart` 的 `tabs` 中暴露 `AppTabEntry`，必须同时声明 `route` 和 `initialTarget`。
8. 免登录页面通过 `routePolicies` 声明 `AppRoutePolicy(requiresAuthentication: false)`，不要在 Route 上写 `public`。
9. 为 Feature 声明唯一 key、显式 priority 与允许环境，并在 `features/features.dart` 注册；如 route class 需要给业务页面使用，在 `features/exports.dart` 导出。
10. App 层会按当前环境构建唯一 `AppFeatureRegistry`，从同一实例组合 routes、tabs、policies、guards 与 Provider overrides；不要为新增 Feature 修改 `core/router/config/router_provider.dart`。
11. 确认 Feature key、route key/path、Tab key 唯一，且每个 Tab route 都由所属 Feature 的 routes 声明。
12. 如果项目没有任何底部 Tab，不创建 `/` 的 Root redirect 或 Root Shell；应提供明确首页路由或自定义登录后的目标页。

## 导航使用

业务页面优先：

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

## 禁止事项

- 业务代码不要直接 import `go_router`。
- `router_provider.dart` 不要逐个 import 业务 route 文件。
- `core/router` 不要 import `app/`、`features/` 或 Toast 来装配具体路由或 UI。
- 不要让业务页面重复 import 深层 route 文件。
- 不要把 `path` 当作带真实参数的跳转地址。
- 不要再使用 `createAuthGuard` / `createStrictAuthGuard`、`AppPageRoute.public` 或 `push(XxxRouteTarget.location)`。

## 守卫规则

- `core/router` 守卫只消费 `RouteAccessDecision`，不直接读取具体业务状态。
- App 组合层监听会话、启动、升级、资料、权限或租户 Provider，并按业务优先级生成最终决策。
- 模板默认 Guard 顺序为 Bootstrap → Authentication → Feature Guards。
- 使用 `RedirectRoute.appliesToPublicRoutes` 显式声明强制升级等全局门禁是否覆盖公开路由。
- 使用 `RedirectRoute.preserveTarget` 显式声明登录后是否返回原始目标页。
- 公开路由通过 Feature 的 `AppRoutePolicy` 声明，再由注册表派生 `publicRoutePatterns`。
- 登录目标应使用 `const LoginTarget()`，避免硬编码分散。
- Toast 等 NavigatorObserver 由 App 组合层通过 `AppRouterConfig.observers` 注入。

## 文档同步

- 修改核心路由设计后更新 `lib/core/router/README.md`。
- 修改新增路由流程后更新 `README.md` 和 `docs/template_usage.md`。
