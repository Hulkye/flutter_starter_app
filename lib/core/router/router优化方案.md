# Router 模块优化方案

## 1. 文档定位

本文是当前 Flutter Starter App 路由模块的架构方案与后续重构路线。方案基于现有实现整理，不再描述已经移除的 `AppPageRoute.location`、`goTarget`、`pushTarget` 等过渡 API。

核心目标：

- 保持 Feature-First，`AppFeatureRegistry` 继续作为 App 的业务模块总注册表。
- 让路由定义、导航目标、路由参数、访问策略和外部入口各自表达单一职责。
- 让 GoRouter 只存在于 `core/router` 的适配器层。
- 让内部业务导航使用 `AppRouteTarget`，避免业务代码拼接裸字符串。
- 让路由元数据保持精简，不把认证、Deep Link、埋点和页面恢复配置全部塞进 router。
- 让每个阶段都有可验证的迁移边界，不一次性重写所有 Feature。

## 2. 当前已完成基线

当前代码已经完成以下能力：

```text
AppPageRoute<TArgs>
AppRouteTarget
AppRouteCodec<TArgs>
AppRouteState
AppRouteMetadata
BaseNavigator(AppRouteTarget)
AppRouteGuard / AppRouteGuardChain
RouteAccessDecision(AppRouteTarget)
AppFeatureRegistry
```

当前目录职责：

```text
lib/core/router/
├── definitions/       路由结构、状态、Target、Codec、Metadata
├── navigation/        BaseNavigator 与框架无关 Provider binding
├── guards/            框架无关的 Guard 协议、决策模型与重定向解析
├── adapters/          稳定导航门面与具体 Router runtime 适配器
│   └── go_router/     GoRouter 导航、路由转换、Guard 与 Provider
└── router.dart        对外 barrel export
```

当前验证基线：

- `AppPageRoute<TArgs>` 已通过 `parse(AppRouteState)` 产生类型化参数。
- GoRouter 适配器执行 `parse -> buildPage(args)`。
- 固定页面使用 `AppPageRoute<void>`。
- WebView 使用 `AppPageRoute<WebPageConfig>` 与 `AppRouteCodec<WebPageConfig>`。
- `BaseNavigator` 的正式 API 接收 `AppRouteTarget`。
- `RouteAccessDecision` 的重定向目标使用 `AppRouteTarget`。
- `AppRouteGuardChain` 支持顺序执行、首个 Redirect 短路、Allow redirects 合并和冲突失败。
- `AppFeatureRegistry` 已汇聚 routes、tabs、externalRoutes、guards、route indexes 与 provider overrides。

## 3. 目标概念模型

```text
AppPageRoute<TArgs>  路由注册定义
AppRouteTarget       一次具体导航目标
AppRouteState        当前 URL/GoRouter 状态的框架无关表示
AppRouteCodec<TArgs> 参数解析与地址编码
AppRouteMetadata     路由身份与匹配元数据
AppRoutePolicy       访问要求，属于 App/Feature 组合层
AppExternalRoute     外部入口暴露声明
AppRouteGuard        当前运行态访问判断
RouteAccessDecision  GuardChain 的最终结果
```

关系如下：

```text
Route Definition + Route State
            ↓ parse
          Route Args
            ↓ buildPage
           页面

Route Target
            ↓ BaseNavigator
      GoRouter Adapter

Feature Registry
  ├── Route Definitions
  ├── Tab Entries
  ├── External Routes
  ├── Feature Guards
  ├── Route Indexes
  └── Provider Overrides
```

## 4. 字段归属原则

### 4.1 `key` 和 `path` 属于路由定义

`key` 与 `path` 是 router 需要理解的结构字段：

- `key`：路由稳定身份，用于 Registry 校验、索引、诊断和引用。
- `path`：GoRouter 匹配模板，例如 `/profile/:userId`。

长期建议 Feature 显式声明稳定 key：

```dart
@override
AppRouteMetadata get metadata => const AppRouteMetadata(
  key: 'profile.home',
  path: '/profile',
);
```

迁移期间允许默认使用 `path` 作为 key，但不能把 path 当作长期业务身份。

### 4.2 `public` 不属于基础 Route Node

`public` 的实际含义是“是否需要认证”，它属于访问策略，不是路由结构。当前实现已将公开访问要求迁移到 Feature/App 组合层的 `AppRoutePolicy`：

```text
AppRouteMetadata       路由身份与匹配信息
AppRoutePolicy         访问要求
AppRouteGuard          当前状态判断
RouteAccessDecision    最终访问结果
```

不要继续扩展 `public: bool` 来表达复杂权限。未来的访问要求可以包括：

```text
public
authenticated
guestOnly
profileCompleted
tenantSelected
permissionRequired
```

具体枚举或 Policy 字段应由 App/Feature 组合层决定，`core/router` 只消费最终 `RouteAccessDecision`。

### 4.3 `deepLinkable` 不属于 Router

`deepLinkable` 表示某个外部入口系统是否允许暴露某个页面，不是路由固有属性。同一个页面可能允许：

- App 内部导航；
- Push 打开；
- OAuth 回调进入；
- Deep Link 打开；
- 某个环境打开而另一个环境禁止。

当前项目已有更清晰的声明：

```dart
AppExternalRoute(
  key: 'profile',
  route: const ProfileRoute(),
)
```

因此：

- `AppExternalRoute` 是外部入口的唯一声明来源。
- 外部入口 Registry 负责转换成 Deep Link/Push 等平台配置。
- `AppRouteMetadata` 不应再增加 `deepLinkable`。
- 禁止同时维护 `metadata.deepLinkable` 和 `AppExternalRoute` 两套开关。

### 4.4 `analyticsName` 不属于 Router

Router 可以提供稳定 route key，但不应依赖具体分析系统或业务事件名称：

```text
route key: profile.home
analytics event: profile_view
```

建议由 Analytics 层维护映射：

```text
routeKey -> analytics event name
```

这样更换分析平台不会反向污染 `core/router`。

### 4.5 `restoreState` 不属于基础 Metadata

页面恢复涉及 Shell 分支、浏览历史、冷启动恢复和页面生命周期，属于导航展示策略。未来如确有需求，应独立为：

```dart
AppRoutePresentationPolicy(
  restoreState: true,
)
```

由 Shell 或 GoRouter Adapter 消费，不放入基础 `AppRouteMetadata`。

## 5. 推荐的核心接口

### 5.1 AppPageRoute

```dart
abstract class AppPageRoute<TArgs> extends AppRouteNode {
  const AppPageRoute();

  String get path;

  AppRouteMetadata get metadata;

  TArgs parse(AppRouteState state);

  Widget buildPage(BuildContext context, TArgs args);
}
```

路由注册对象必须无状态，不携带某一次导航的业务参数：

```dart
const ProfileRoute()
```

动态页面的参数由 `AppRouteState` 解析，不由注册实例保存。

### 5.2 AppRouteTarget

```dart
abstract interface class AppRouteTarget {
  String get location;

  Object? get extra;
}
```

内部业务导航只使用 Target：

```dart
ref.read(appRouterProvider).push(
  const ProfileTarget(userId: '42'),
);
```

GoRouter、URI 编码和 `extra` 转换只在 `core/router/adapters` 中处理。

### 5.3 AppRouteCodec

```dart
abstract interface class AppRouteCodec<TArgs> {
  String get path;

  TArgs parse(AppRouteState state);

  String location(TArgs args);

  Object? extra(TArgs args);
}
```

同一个 Codec 同时服务：

- 页面从真实 URL 解析参数。
- Target 从类型化参数构造 location。
- `extra` 的进程内传递。

固定页面不强制创建 Codec；只有参数复杂、需要校验或需要复用时才引入。

## 6. AppFeatureRegistry 的定位

`AppFeatureRegistry` 必须保留为总注册表，因为项目的一级业务装配单位是 Feature，而不是 Route。

```text
features/features.dart
        ↓
AppFeatureRegistry
        ├── features
        ├── routes
        ├── tabs
        ├── externalRoutes
        ├── guards
        ├── routesByKey
        ├── routesByPath
        └── providerOverrides
```

不建议把它改名为 `RouteRegistry`。如果未来需要更丰富的路由查询能力，可以继续增加派生索引或只读视图：

```dart
registry.routesByKey
registry.routesByPath
```

它们是 `AppFeatureRegistry` 的派生结果，不是新的 App 总装配入口。

### AppFeature 应暴露的能力

```dart
abstract class AppFeature {
  const AppFeature();

  AppFeatureMetadata get metadata;

  List<AppPageRoute<dynamic>> get routes;

  List<AppTabEntry> get tabs;

  List<AppExternalRoute> get externalRoutes;

  List<AppRouteGuard> get guards;

  List<Override> get providerOverrides;
}
```

Registry 负责：

- 环境筛选。
- priority/key 稳定排序。
- Feature key 唯一校验。
- Route key/path 唯一校验。
- Tab key 唯一校验。
- Tab route 所属 Feature 校验。
- External route key/path 及所属 Feature 校验。
- Feature Guards 汇聚。
- routesByKey/routesByPath 派生。
- Provider overrides 汇聚。

## 7. 访问策略与 GuardChain

访问判断分为三层：

```text
AppRoutePolicy          静态访问要求
AppRouteGuard           运行态业务判断
RouteAccessDecision     最终结果
```

GuardChain 的执行规则：

```text
Bootstrap Guard
    ↓
Authentication Guard
    ↓
Feature Guards
    ↓
Allow
```

当前 `AppRouteGuardChain` 已支持：

- 按注册顺序执行。
- 第一个 `RedirectRoute` 立即短路。
- 多个 `AllowRoute.redirects` 合并。
- 同一匹配模式产生不同目标时 fail-fast。

当前 Guard 已接收 `AppRouteRequest`。GoRouter Adapter 从真实导航状态构造 request，
再交给 App 组合层注入的 GuardChain；Bootstrap、Authentication 和 Feature Guards
因此使用同一份路由上下文，但现有决策优先级保持不变：

```dart
final class AppRouteRequest {
  const AppRouteRequest({
    required this.location,
    required this.routeKey,
    required this.metadata,
    required this.state,
  });

  final String location;
  final String routeKey;
  final AppRouteMetadata metadata;
  final AppRouteState state;
}

abstract interface class AppRouteGuard {
  RouteAccessDecision evaluate(AppRouteRequest request);
}
```

该升级只增加路由上下文，不改变现有 Guard 优先级和业务规则。

## 8. 外部入口

Deep Link、Push、OAuth 和通知入口不应直接调用页面 Route。

推荐链路：

```text
外部 URI / Push Payload
        ↓
入口解析器
        ↓
AppExternalRoute / Route Resolver
        ↓
AppNavigationCommand
        ↓
Bootstrap / Authentication / Feature Guard
        ↓
AppRouteTarget
        ↓
BaseNavigator
```

约束：

- 外部入口只依赖当前环境启用的 `AppFeatureRegistry.externalRoutes`。
- 被禁用 Feature 的外部入口必须同步消失。
- Deep Link 使用可序列化 path/query。
- `extra` 只能作为进程内补充，不能作为深链唯一数据来源。
- 外部 URI 不能未经校验直接成为内部重定向目标。

## 9. 推荐目录结构

```text
lib/core/router/
├── definitions/
│   ├── app_route_node.dart
│   ├── app_page_route.dart
│   ├── app_redirect_route.dart
│   ├── app_shell_route.dart
│   ├── app_route_state.dart
│   ├── app_route_state_reading.dart
│   ├── app_route_target.dart
│   ├── app_route_target_resolver.dart
│   ├── app_route_codec.dart
│   └── app_route_metadata.dart
├── navigation/
│   └── base_navigator.dart
├── guards/
│   ├── app_route_guard.dart
│   ├── route_access_decision.dart
│   └── route_redirect_resolver.dart
├── adapters/
│   └── go_router/
│       ├── router_navigator.dart
│       ├── route_transform.dart
│       ├── access_guard.dart
│       └── router_provider.dart
├── README.md
└── router.dart
```

Feature 内部建议：

```text
lib/features/profile/presentation/
├── profile_routes.dart
├── profile_route_args.dart       # 只有参数复杂时创建
└── profile_route_targets.dart    # 只有存在多个 Target 时拆出
```

不引入空的 Args、Codec 或 Target 文件。固定页面保持简单实现。

## 10. 分阶段落地路线

### 阶段一：已完成，导航语义分离

- `AppPageRoute` 只作为注册定义。
- 移除带导航参数的 Route 实例模式。
- 引入 `AppRouteTarget`。
- `BaseNavigator` 正式接收 Target。
- 旧字符串接口改为显式 `*Location` 兼容入口。
- 删除 `AppPageRoute.location`。

### 阶段二：已完成，参数类型化

- 引入 `AppPageRoute<TArgs>`。
- 固定页面使用 `void`。
- 参数页面通过 `parse(AppRouteState)` 获取 typed Args。
- GoRouter Adapter 执行 `parse -> buildPage(args)`。
- WebView 使用 `WebPageConfig` 作为类型化参数。
- Login 使用 `LoginRouteArgs`。

### 阶段三：已完成，访问决策 Target 化

- `RedirectRoute` 使用 `AppRouteTarget`。
- `AllowRoute.redirects` 的 value 使用 Target。
- 保留 key 作为当前路由匹配模式字符串。
- 保留内部 location 校验与登录回跳行为。

### 阶段四：已完成，Feature 注册表增强

- `AppFeatureRegistry` 继续作为总注册表。
- 增加 Feature Guards 汇聚。
- 增加 routesByKey/routesByPath 派生索引。
- 将 Feature Guards 接入 AppRouteGuardChain。
- 保持 Bootstrap → Authentication → Feature Guards 顺序。

### 阶段五：已完成，路由上下文化 Guard

- 引入 `AppRouteRequest`。
- `AppRouteGuard.evaluate()` 接收 Route Request。
- GoRouter Adapter 根据实际 `GoRouterState` 生成 route key、metadata、AppRouteState 和当前 location。
- 不改变 Bootstrap → Authentication → Feature Guards 的顺序和业务规则。

### 阶段六：已完成，收窄 Route Metadata

当前结构：

```dart
final class AppRouteMetadata {
  const AppRouteMetadata({
    required this.key,
    required this.path,
  });

  final String key;
  final String path;
}
```

已完成事项：

1. 新增 App/Feature 层的 `AppRoutePolicy` 索引。
2. `AppRouterConfig.publicRoutePatterns` 消费访问策略索引。
3. 删除 `AppRouteNode.public`。
4. 删除 `AppRouteMetadata.public`。
5. 删除 `deepLinkable`、`analyticsName`、`restoreState` 等非路由本体字段。
6. 继续由 `AppExternalRoute` 作为外部入口唯一声明来源。

这一阶段未改变实际认证规则，只移动了字段归属。

### 阶段七：进行中，外部入口统一

- Deep Link 已通过 integration 层 `DeepLinkNavigationCommandResolver` 转换为
  `AppNavigationCommand`，Deep Link package 只负责 URI 安全校验和通用路由匹配。
- WebView 参数标准化和 `WebPageConfig` 构造已从 capability 移到 Resolver。
- Push、OAuth、通知等其他入口仍需接入同一 Resolver/Command 协议。
- 后续由 Resolver 根据当前 `AppFeatureRegistry` 解析 route key/path/query。
- 明确启动未完成、未登录、Feature 禁用和非法 URI 的失败行为。
- 不引入静默跳首页等临时 fallback。

## 11. 测试与质量门禁

每个阶段至少覆盖：

- Route key/path 冲突。
- Feature 环境筛选后的 route、Tab、external route、Guard 同步变化。
- Target path/query 编码。
- AppRouteState 参数解析。
- `extra` 类型和可恢复性边界。
- Route Adapter 的 `parse -> buildPage` 链路。
- GuardChain 顺序、短路、合并和冲突。
- 未登录回跳与外部 URI 安全校验。
- Shell Tab 初始 Target。

提交前执行：

```bash
flutter analyze
dart format --set-exit-if-changed lib test script
flutter test
```

架构扫描要求：

- Feature presentation 不直接 import `go_router`。
- `core/router` 不 import `app/` 或 `features/`。
- 新业务导航不新增裸字符串调用。
- `AppPageRoute` 不携带一次导航参数。
- `AppExternalRoute` 是外部入口暴露的唯一声明来源。
- `AppFeatureRegistry` 是 Feature-First 的唯一 App 组合注册结果。

## 12. 最终边界

```text
core/router
  负责：
  - Route Definition
  - Route Target
  - Route State
  - Route Codec 协议
  - Navigator 抽象
  - GoRouter Adapter
  - Guard 协议与最终决策执行

core/feature / app 组合层
  负责：
  - Feature 注册
  - Route Policy
  - Feature Guards 装配
  - Tab/External Route 汇聚
  - Provider Overrides

shared/integrations
  负责：
  - Deep Link
  - Push
  - OAuth
  - Analytics
  - 页面恢复与平台生命周期
```

最终原则：

> `key/path` 是路由本体；访问要求属于 Policy；运行态判断属于 Guard；外部暴露属于 AppExternalRoute；页面恢复属于展示策略；埋点名称属于 Analytics。

不要把这些字段继续堆进 `AppRouteMetadata` 或 `AppRouteNode`。
