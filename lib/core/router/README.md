# Router 模块

业务层与 GoRouter 之间的隔离层。业务代码不直接引用 `go_router`。

## 文件清单

| 文件 | 职责 | 引用 GoRouter? |
|:---|:---|:---:|
| `router.dart` | Barrel export，对外唯一入口 | — |
| `app_route_define.dart` | `AppRouteDefine` + `RouteState` — 两个核心类型 | ❌ |
| `base_navigator.dart` | `BaseNavigator` — 导航抽象接口 | ❌ |
| `router_navigator.dart` | `RouterNavigator` — `BaseNavigator` 的 GoRouter 实现 | ✅ |
| `app_router_transfor.dart` | `toGoRoute()` — `AppRouteDefine` → `GoRoute` 适配器 | ✅ |
| `router_provider.dart` | `goRouterProvider` + `appRouterProvider` + 路由注册表 | ✅ |
| `router_guard.dart` | `createAuthGuard()` — 可选认证守卫工具 | ✅ |

## 分层架构

```
┌──────────────────────────────────────────────────────────┐
│  Presentation / Page                                    │
│                                                          │
│  import 'router.dart'  ← 唯一依赖                          │
│                                                          │
│  ref.read(appRouterProvider).push(const ProfileRoute().location); │
│  ref.read(appRouterProvider).back();                     │
└────────────────────────┬─────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────┐
│  接口层 (core/router)                                     │
│                                                          │
│  AppRouteDefine   — 路由定义（导航目标 + 页面构建，二合一）   │
│  RouteState       — 框架无关的路由状态                      │
│  BaseNavigator    — 导航接口（抽象契约）                     │
└────────────────────────┬─────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────┐
│  适配层 (core/router)                                     │
│                                                          │
│  RouterNavigator  — BaseNavigator 的 GoRouter 适配         │
│  toGoRoute()      — AppRouteDefine → GoRoute 转换         │
│  router_provider  — Riverpod Provider + 路由注册表         │
└──────────────────────────────────────────────────────────┘
```

## 核心概念

### AppRouteDefine — 路由定义（二合一）

一个 `AppRouteDefine` 同时表达"去哪"和"怎么构建页面"：

```dart
final class ProfileRoute extends AppRouteDefine {
  const ProfileRoute();

  @override String get path => '/profile';        // 路由匹配模式

  @override Widget buildPage(BuildContext context, RouteState state) {
    return ProfilePage(controller: ProfilePageController());
  }
}
```

- `path` — 路由匹配模式，对应 GoRoute 的 path
- `location` — 实际跳转路径，默认与 `path` 相同；带参数时可覆盖
- `public` — 是否无需登录，默认 `false`
- `buildPage()` — 构建页面，接收框架无关的 `RouteState`

### RouteState — 路由状态

```dart
class RouteState {
  final String location;                    // '/profile/42?tab=posts'
  final Map<String, String> pathParameters; // {userId: '42'}
  final Map<String, String> queryParameters;// {tab: 'posts'}
  final Object? extra;
}
```

GoRouterState 的中立替代。Feature 路由定义的 `buildPage` 只接触这个类型。

### BaseNavigator — 导航接口

```dart
abstract interface class BaseNavigator {
  void go(String location);
  Future<T?> push<T extends Object?>(String location);
  void replace(String location);
  void replaceAll(String location);
  void back<T extends Object?>([T? result]);
  bool canBack();
}
```

Presentation 层依赖这个接口，而非具体 GoRouter 实现。接口接收 location 字符串，`AppRouteDefine` 负责提供类型化的 `location` helper，测试时可直接 mock `BaseNavigator`。

## 使用方式

### 在 Widget 中导航

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/router/router.dart';
import '../profile/profile_routes.dart';

Consumer(
  builder: (context, ref, _) {
    return ElevatedButton(
      onPressed: () {
        ref.read(appRouterProvider).push(const ProfileRoute().location);
      },
      child: const Text('Go to Profile'),
    );
  },
)
```

### 返回上一页

```dart
ref.read(appRouterProvider).back();
```

在 `BasePage` 中，默认返回按钮和 Pop 拦截也会通过 `appRouterProvider` 执行返回。

### 带参数路由

```dart
// 路由定义（location 与 path 分离）
final class ProfileDetailRoute extends AppRouteDefine {
  const ProfileDetailRoute({required this.userId});
  final String userId;

  @override String get path => '/profile/:userId';    // GoRoute 匹配模式
  @override String get location => '/profile/$userId'; // 实际跳转路径

  @override Widget buildPage(BuildContext context, RouteState state) {
    return ProfileDetailPage(userId: state.pathParameters['userId']!);
  }
}

// 导航
ref.read(appRouterProvider).push(ProfileDetailRoute(userId: '42').location);
```

### 认证守卫

```dart
// router_provider.dart 内联守卫
redirect: (context, state) {
  final currentPath = state.uri.path;
  final isPublic = _allRoutes.any((r) => r.public && r.path == currentPath);
  if (isPublic) return null;
  if (AuthSessionStore.instance.hasValidSession) return null;
  return const LoginRoute().location;
},
```

或使用独立的 `createAuthGuard()` 工具函数。

## 新增路由

新增业务页面时，由 Feature 自己声明路由，再通过 `AppFeature` 暴露给 App 汇聚入口。

**1. 创建路由类：**

```dart
// lib/features/settings/presentation/settings_routes.dart
import 'package:flutter/widgets.dart';
import '../../../core/router/app_route_define.dart';

final class SettingsRoute extends AppRouteDefine {
  const SettingsRoute();

  @override String get path => '/settings';

  @override Widget buildPage(BuildContext context, RouteState state) {
    return const SettingsPage();
  }
}
```

**2. 创建 Feature 声明：**

```dart
// lib/features/settings/settings_feature.dart
import '../../core/feature/app_feature.dart';
import '../../core/router/app_route_define.dart';
import 'presentation/settings_routes.dart';

export 'presentation/settings_routes.dart';

final class SettingsFeature extends AppFeature {
  const SettingsFeature();

  @override
  String get name => 'settings';

  @override
  List<AppRouteDefine> get routes => const [SettingsRoute()];
}
```

**3. 注册到 Feature 汇聚入口：**

```dart
// lib/features/features.dart
import 'settings/settings_feature.dart';

export 'settings/settings_feature.dart';

const List<AppFeature> appFeatures = [
  HomeFeature(),
  AuthFeature(),
  ProfileFeature(),
  TodoFeature(),
  SettingsFeature(),
];
```

完成。业务代码即可导航：

```dart
import 'package:flutter_starter_app/header.dart';

ref.read(appRouterProvider).go(const SettingsRoute().location);
```

## 设计原则

- **业务层不 import `go_router`** — 通过 `AppRouteDefine` + `BaseNavigator` 解耦
- **一个 Route class 表达一个路由** — 导航目标 + 页面构建合并在一个对象中，不再分离
- **RouterNavigator 是唯一调用 GoRouter 导航 API 的类** — 切换路由框架只需重写此类
- **Feature 负责暴露路由** — 每个 `XxxFeature` 维护自己的路由列表
- **Feature 汇聚入口集中管理** — `features/features.dart` 是业务 Feature 注册与路由导出的统一入口
- **Provider 而非单例** — `goRouterProvider` / `appRouterProvider` 通过 Riverpod 注入，测试可用 `ProviderScope.overrides` 替换
- **`router.dart` 是对外唯一入口** — 业务代码只 import 这一个文件
