# 路由规则

## 核心原则

- 业务层不直接依赖 `go_router`。
- 业务导航通过 `BaseNavigator` 与 `appRouterProvider` 完成。
- 一个 Route class 表达一个路由目标和页面构建方式。
- 页面 Route class 继承 `AppPageRoute`，Shell/Redirect 使用对应的 `AppRouteNode` 子类。
- Feature 通过 `XxxFeature extends AppFeature` 暴露路由。
- `features/features.dart` 汇聚普通业务路由与可选底部 Tab 入口。
- App 组合层通过 `lib/app/router/app_router_config.dart` 组装 Splash、Root/Shell 与 Feature 路由，并以 `AppRouterConfig` 注入 `core/router`。
- `core/router` 只提供路由定义、GoRouter 适配、守卫和导航 Provider，不 import `app/` 或 `features/`。

## 新增路由流程

1. 在 `lib/features/<feature>/presentation/<feature>_routes.dart` 创建 `XxxRoute extends AppPageRoute`。
2. 在 `lib/features/<feature>/<feature>_feature.dart` 创建 `XxxFeature extends AppFeature`。
3. 在 `XxxFeature.routes` 中返回当前 Feature 的路由列表。
4. 如需底部 Tab，在 `XxxFeature.tabs` 中返回 `AppTabEntry`，由 `RootShellRoute` 自动装配。
5. 在 `XxxFeature` 中 export 当前 Feature 的 route 文件。
6. 在 `lib/features/features.dart` import/export `XxxFeature` 并加入 `appFeatures`。
7. `lib/app/router/app_router_config.dart` 会从 `appFeatures` 自动组合到 App 路由图，通常无需修改 `core/router/router_provider.dart`。
8. 业务页面通过 `package:flutter_starter_app/header.dart` 使用 route class 和 `appRouterProvider`。

## 禁止事项

- 不要在 `core/router/router_provider.dart` 中逐个 import 业务 route 文件。
- 不要在 `core/router` 中 import `app/` 或 `features/` 来装配具体路由；应用路由图必须由 App 组合层注入。
- 不要在业务页面直接 import `go_router`。
- 不要在 `app/`、`core/`、`shared/` 内部通过 `header.dart` 获取路由或公共能力；这些层应使用精确 import。
- 不要把 `path` 和 `location` 混用：
  - `path` 用于路由匹配，例如 `/profile/:userId`；
  - `location` 用于实际跳转，例如 `/profile/42`。

## 导航示例

```dart
import 'package:flutter_starter_app/header.dart';

ref.read(appRouterProvider).push(const LoginRoute().location);
```

带参数路由：

```dart
ref.read(appRouterProvider).push(ProfileDetailRoute(userId: '42').location);
```

## 文档同步

- 修改路由核心规则时，同步检查 `lib/core/router/README.md`。
- 修改新增 Feature 的路由流程时，同步检查 `README.md` 和 `docs/template_usage.md`。
