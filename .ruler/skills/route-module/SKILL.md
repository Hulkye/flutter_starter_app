---
name: route-module
description: "Use when: adding, changing, reviewing, or documenting app routes, AppPageRoute/AppRouteNode classes, AppFeature route aggregation, router_provider, navigation, auth guards, or route exports."
---

# 路由模块工作流

当任务涉及路由、新页面跳转、认证守卫或 route export 时，遵循本技能。

## 路由新增流程

1. 在对应 Feature 的 `presentation/<feature>_routes.dart` 中创建 Route class。
2. 页面 Route class 继承 `AppPageRoute`。
3. `path` 表示 GoRoute 匹配路径。
4. `location` 表示实际跳转路径；带参数路由必须正确覆盖。
5. `buildPage` 只接收 `BuildContext` 和 `AppRouteState`。
6. 在 `<feature>_feature.dart` 的 `routes` 中暴露该路由。
7. 如果该路由是底部 Tab 根路由，在 `<feature>_feature.dart` 的 `tabs` 中暴露 `AppTabEntry`。
8. 在 `features/features.dart` 注册并导出 Feature。

## 导航使用

业务页面优先：

```dart
import 'package:flutter_starter_app/header.dart';

ref.read(appRouterProvider).push(const LoginRoute().location);
```

## 禁止事项

- 业务代码不要直接 import `go_router`。
- `router_provider.dart` 不要逐个 import 业务 route 文件。
- 不要让业务页面重复 import 深层 route 文件。
- 不要把 `path` 当作带真实参数的跳转地址。

## 守卫规则

- 登录守卫依赖稳定的会话 Provider/Service。
- 公开路由通过 `AppPageRoute.public` 标记。
- 登录路径应使用 `const LoginRoute().location`，避免硬编码分散。

## 文档同步

- 修改核心路由设计后更新 `lib/core/router/README.md`。
- 修改新增路由流程后更新 `README.md` 和 `docs/template_usage.md`。
