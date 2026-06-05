# 路由规则

## 核心原则

- 业务层不直接依赖 `go_router`。
- 业务导航通过 `BaseNavigator` 与 `appRouterProvider` 完成。
- 一个 Route class 表达一个路由目标和页面构建方式。
- Route class 继承 `AppRouteDefine`。
- Feature 通过 `XxxFeature extends AppFeature` 暴露路由。
- App 通过 `features/features.dart` 汇聚全部业务路由。

## 新增路由流程

1. 在 `lib/features/<feature>/presentation/<feature>_routes.dart` 创建 `XxxRoute extends AppRouteDefine`。
2. 在 `lib/features/<feature>/<feature>_feature.dart` 创建 `XxxFeature extends AppFeature`。
3. 在 `XxxFeature.routes` 中返回当前 Feature 的路由列表。
4. 在 `XxxFeature` 中 export 当前 Feature 的 route 文件。
5. 在 `lib/features/features.dart` import/export `XxxFeature` 并加入 `appFeatures`。
6. 业务页面通过 `package:flutter_starter_app/header.dart` 使用 route class 和 `appRouterProvider`。

## 禁止事项

- 不要在 `core/router/router_provider.dart` 中逐个 import 业务 route 文件。
- 不要在业务页面直接 import `go_router`。
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
