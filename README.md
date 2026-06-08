<p align="center">
  <img src="assets/app_icon.png" width="120" alt="Flutter Starter App" />
</p>

<h1 align="center">🚀 Flutter Starter App</h1>

<p align="center">
  <strong>✨ 主打分层架构 · MVVM · Clean Architecture 的 Flutter 开箱即用代码模板</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Riverpod-2.x-06B6D4?logo=riverpod&logoColor=white" alt="Riverpod" />
  <img src="https://img.shields.io/badge/license-MIT-green" alt="License" />
</p>

---

这是一个面向中大型 Flutter 项目的快速启动模板。项目以 **Feature-First** 组织业务模块，在每个 Feature 内落地 **Data / Domain / Presentation** 分层，并通过 **BasePage + PageLogic + BaseVM + Riverpod** 建立职责清晰的 MVVM 开发范式。

模板已内置多环境、网络请求、路由守卫、主题、国际化、本地存储、登录会话、Toast/Loading、刷新、按钮、弹窗等常用基础设施。Clone 后只需要替换业务接口与页面，即可进入功能开发。

> 📘 第一次使用模板请先阅读：[模板使用说明](docs/template_usage.md)。
>
> 🧪 测试与质量门禁请查看：[测试与质量保障](docs/testing_quality.md)。
>
> 🤖 AI 指令统一管理请查看：[Ruler AI 指令管理](docs/ruler_usage.md)。

## 📚 目录

- [核心优势](#-核心优势)
- [模板使用说明](docs/template_usage.md)
- [测试与质量保障](docs/testing_quality.md)
- [Ruler AI 指令管理](docs/ruler_usage.md)
- [快速开始](#-快速开始)
- [项目结构](#-项目结构)
- [架构设计](#-架构设计)
- [MVVM 基础能力](#-mvvm-基础能力)
- [核心模块](#-核心模块)
  - [启动引导与依赖注入](#-启动引导与依赖注入)
  - [多环境配置](#-多环境配置)
  - [网络层](#-网络层)
  - [路由系统](#-路由系统)
  - [登录会话](#-登录会话)
  - [主题与资源](#-主题与资源)
  - [国际化](#-国际化)
  - [存储层](#-存储层)
  - [通用组件](#-通用组件)
- [开发指南](#-开发指南)
- [脚本工具](#-脚本工具)
- [主要依赖](#-主要依赖)

---

## ✨ 核心优势

| 能力 | 说明 |
| --- | --- |
| 清晰分层 | 每个业务模块按 `data / domain / presentation` 拆分，职责边界明确 |
| MVVM 开发范式 | `BasePage` 承载页面骨架，`PageLogic` 承载页面私有生命周期与局部交互，`BaseVM` 只承载状态与业务动作 |
| Clean Architecture | 业务依赖抽象而非实现，Repository 接口与实现分离，便于替换数据源 |
| Feature-First | 业务代码按功能聚合，模块可独立演进，避免按技术层级散落全局 |
| Riverpod 驱动 | 状态管理、依赖注入、服务组合统一使用 Riverpod，减少框架混用成本 |
| 开箱即用基础设施 | 网络、路由、主题、存储、认证、国际化、异常捕获、日志、组件均已预置 |
| 多环境支持 | Dev / SIT / Prod 独立入口，环境配置通过 `EnvConfig` 注入 |
| 易扩展 | 新增 Feature 时复用既有目录、路由、ViewModel、Repository 模式即可 |

---

## 🚀 快速开始

```bash
# 安装依赖
flutter pub get

# 运行开发环境
flutter run -t lib/main_dev.dart

# 运行 SIT 环境
flutter run -t lib/main_sit.dart

# 运行生产环境
flutter run -t lib/main_prod.dart

# 默认入口同样指向生产环境
flutter run -t lib/main.dart
```

首次使用建议先修改各环境入口中的 `EnvConfig`：

```dart
await Application.run(
  envConfig: const EnvConfig(
    envTag: EnvTag.dev,
    baseUrl: 'https://dev.example.com',
    apiPathPrefix: '/api',
  ),
);
```

---

## 📁 项目结构

```text
lib/
├── app/                           # 应用启动、根组件、环境配置
│   ├── app.dart                   # MaterialApp.router 根组件
│   ├── application.dart           # Application.run 启动入口
│   └── env.dart                   # EnvConfig / EnvTag
├── core/                          # 全局基础设施，不承载具体业务
│   ├── constant/                  # 常量
│   ├── di/                        # AppBootstrap / Provider overrides
│   ├── exception/                 # 全局异常捕获
│   ├── feature/                   # AppFeature 模块协议
│   ├── l10n/                      # 国际化
│   ├── network/                   # 网络、连接状态、HTTP 客户端
│   ├── router/                    # GoRouter 封装、守卫、导航抽象
│   ├── service/                   # 日志、事件总线等公共服务
│   ├── storage/                   # SharedPreferences / SecureStorage 封装
│   ├── theme/                     # 主题、色值、主题资源
│   └── util/                      # 工具类
├── features/                      # 业务功能模块
│   ├── features.dart              # Feature 汇聚与业务路由统一导出
│   ├── auth/                      # 登录示例
│   ├── home/                      # 首页示例
│   ├── profile/                   # 个人中心示例
│   └── todo/                      # Todo 完整分层示例
├── shared/                        # 跨 Feature 共享能力
│   ├── presentation/              # BasePage / PageLogic / BaseVM / BaseState / PresentationHelper
│   ├── services/                  # AuthSession / AuthStore
│   └── widgets/                   # Toast、Loading、Button、Dialog 等组件
├── header.dart                    # 常用导出
├── main_dev.dart                  # 开发环境入口
├── main_sit.dart                  # SIT 环境入口
├── main_prod.dart                 # 生产环境入口
└── main.dart                      # 默认入口
```

项目根目录还包含 AI 指令管理源文件：

```text
.ruler/                            # Ruler AI 指令源文件，需纳入版本控制
├── AGENTS.md                      # 项目 AI 指令总入口
├── ruler.toml                     # Ruler 配置
├── architecture.md                # 架构规则
├── flutter_conventions.md         # Flutter / Dart 约定
├── routing.md                     # 路由规则
├── state_management.md            # 状态管理规则
├── testing.md                     # 测试与质量规则
├── documentation.md               # 文档维护规则
└── skills/                        # 可分发给 AI 工具的项目技能
```

Ruler 生成的 `AGENTS.md`、`CLAUDE.md`、`.claude/skills/`、`.cursor/skills/`、`.codex/` 等文件由 `.gitignore` 忽略，不应手动修改或提交。详见 [Ruler AI 指令管理](docs/ruler_usage.md)。

单个 Feature 推荐结构：

```text
lib/features/<feature>/
├── <feature>_feature.dart          # Feature 声明与路由导出
├── data/
│   ├── datasources/               # 远程/本地数据源
│   └── repositories/              # Repository 实现
├── domain/
│   ├── entities/                  # 业务实体
│   └── repositories/              # Repository 抽象
└── presentation/
    ├── pages/                     # 页面
    ├── viewmodels/                # ViewModel
    └── <feature>_routes.dart      # Feature 路由定义
```

---

## 🏗 架构设计

### 分层关系

```text
┌──────────────────────────────────────────────┐
│                Presentation                  │
│       Page · ViewModel · Route · Widget      │
│             UI 展示、状态管理、交互            │
├──────────────────────────────────────────────┤
│                   Domain                     │
│            Entity · Repository 接口          │
│              业务模型、业务抽象               │
├──────────────────────────────────────────────┤
│                    Data                      │
│        DataSource · Repository 实现          │
│              接口请求、缓存、数据转换          │
└──────────────────────────────────────────────┘
```

依赖方向：

```text
Presentation  ──────▶  Domain  ◀──────  Data
     UI                 抽象              实现
```

这种依赖关系让页面只关心业务抽象，数据来源可以在 API、Mock、本地缓存之间切换，而不会影响 UI 层。

### 模块职责

| 模块 | 职责 | 依赖规则 |
| --- | --- | --- |
| `app/` | 应用启动、环境注入、根组件挂载 | 可组合全局能力 |
| `core/` | 网络、路由、存储、主题、DI、异常、工具 | 不依赖具体 Feature |
| `features/` | 业务模块 | 可依赖 `core` 与 `shared` |
| `shared/` | BasePage、PageLogic、BaseVM、PresentationHelper、认证服务、通用组件 | 提供跨业务复用能力 |

---

## 🧭 MVVM 基础能力

模板通过 `BasePage`、`PageLogic`、`BaseVM`、`BaseState`、`PresentationHelper` 固化页面开发方式，同时保持 Page、PageLogic 与 ViewModel 的职责边界：Page 负责 UI 结构、Widget 组合、布局、样式；PageLogic 负责页面本地 controller、临时交互状态、生命周期、调用 VM/Provider；ViewModel / Notifier 负责页面可观察状态、业务动作编排，并把领域/服务状态转换成 UI 状态。

### BasePage

`BasePage` 是纯页面壳，不绑定具体 ViewModel，负责 UI 结构、Widget 组合、布局和样式：

- 标准 `Scaffold` 构建
- AppBar、背景色、SafeArea、KeepAlive 扩展点
- 背景点击自动收起键盘
- App 生命周期监听与 `PageLogic` 生命周期分发：`onInit` / `onReady` / `onResume` / `onPause` / `onDispose`
- Pop 拦截与默认返回能力
- 通过 `PageScope` 向子类提供 `context`、`ref` 与可选 `PageLogic`

`PageLogic` 用于承载只属于当前页面的本地 controller、临时交互状态、生命周期，以及调用 VM/Provider，不放跨页面业务状态。页面如需使用，覆盖 `createPageLogic()` 并通过 `scope.logic<XxxPageLogic>()` 取得实例：

```dart
final class OrderPageLogic extends PageLogic {
  @override
  void onReady() {
    ref.read(orderViewModelProvider.notifier).loadOrders();
  }
}
```

页面在 `page(scope)` 中按需桥接状态与 ViewModel：

```dart
@override
Widget page(PageScope scope) {
  final logic = scope.logic<OrderPageLogic>();
  final state = scope.ref.watch(todoViewModelProvider);
  final vm = scope.ref.read(todoViewModelProvider.notifier);

  return TodoContent(state: state, vm: vm, logic: logic);
}
```

### BaseVM

`BaseVM` 基于 Riverpod `Notifier`，只用于承载页面可观察状态、业务动作编排，并把领域/服务状态转换成 UI 状态：

- `initialState()` 提供初始状态
- 通过 `state = state.copyWith(...)` 更新 UI 状态
- 调用 Repository 抽象完成业务数据读写
- 不感知 `BuildContext`、Widget 生命周期、页面返回或页面 ready 策略

### BaseState

`BaseState` 是纯状态基类，不内置页面级字段。业务页面如需首屏加载、空态、错误态，应在各自 Feature 的 State 中显式建模，例如 `initialized`、`loading`、`errorMessage`。

### PresentationHelper

`PresentationHelper` 承接 Presentation 层的一次性 UI 反馈：

- `runWithLoading` 包装异步任务
- `emitHint` 展示提示
- `showLoading` / `hideLoading` 控制全局 Loading

这些反馈不进入 `BaseState`，避免临时事件污染可渲染状态。

推荐页面开发流程：

```text
Page 负责 UI 结构、Widget 组合、布局、样式
  ↓ 用户交互
PageLogic 负责页面本地 controller、临时交互状态、生命周期、调用 VM/Provider
  ↓ 调用动作
ViewModel / Notifier 负责可观察状态、业务动作编排、领域状态到 UI 状态的转换
  ↓ 调用抽象
Repository 负责业务数据获取
  ↓ 委托实现
DataSource / HttpClient 负责具体数据来源
```

---

## 📦 核心模块

### 🧩 启动引导与依赖注入

应用统一从 `Application.run()` 启动，启动过程集中在 `AppBootstrap` 中：

```text
main()
  → Application.run(envConfig)
  → AppBootstrap.create(envConfig)
      → WidgetsFlutterBinding.ensureInitialized()
      → 绑定 PresentationHelper 全局反馈处理
      → 初始化普通存储与安全存储
      → 恢复 AuthSession
      → 创建 Riverpod overrides
  → AppExceptionCatcher.runAppGuarded()
  → ProviderScope(overrides: bootstrap.overrides)
  → MaterialApp.router
```

这样可以保证存储、登录会话、环境配置在应用挂载前完成初始化。

### 🌍 多环境配置

| 环境 | 入口 | 适用场景 |
| --- | --- | --- |
| Dev | `lib/main_dev.dart` | 本地开发、调试、抓包 |
| SIT | `lib/main_sit.dart` | 测试环境、联调环境 |
| Prod | `lib/main_prod.dart` | 生产环境 |

`EnvConfig` 支持配置：

- `baseUrl`、`apiPathPrefix`
- 日志开关
- 代理/抓包配置
- 重试策略
- 证书校验策略
- 隐私协议、用户协议地址

### 🌐 网络层

网络层基于 Dio 封装，业务侧依赖统一的 HTTP 抽象，不直接散落 Dio 调用。

```text
HttpConfig
  ↓
httpClientProvider
  ↓
BaseHttpClient / DioHttpClient
  ↓
Interceptor Chain + Cache + Retry + Mock + Batch Request
```

已内置能力：

- Token 自动注入
- 业务状态码解析
- 异常捕获与分类
- 日志输出
- 抓包代理支持
- 请求缓存策略
- 指数退避重试
- Mock 支持
- 批量请求封装

缓存策略包括：

```text
noCache · cacheFirst · networkFirst · cacheOnly · networkOnly · staleWhileRevalidate
```

### 🧭 路由系统

路由基于 GoRouter，但 Presentation/Page 层通过模板封装的路由定义与导航抽象使用，减少对第三方路由库的直接依赖。

```text
Feature Route Define → AppRouteDefine → GoRoute
Feature Module       → AppFeature      → appFeatureRoutes
Page Navigation       → BaseNavigator  → RouterNavigator
```

特点：

- 每个 Feature 自己维护路由定义
- 每个 Feature 通过 `XxxFeature` 暴露模块路由
- `features/features.dart` 汇聚所有 Feature，并统一导出业务 Route class
- 支持公开路由与登录态路由
- 未登录访问受保护页面时自动跳转登录页
- 提供 root navigator key，支持非 UI 场景导航

### 🔐 登录会话

模板内置通用登录会话模型与安全存储：

```text
AuthSession
  ↓
AuthStore
  ↓
authSessionProvider
  ↓
Router Guard / AuthInterceptor / UI
```

`AuthSession` 以 `token`、`refreshToken` 与可扩展 payload 为核心，适配不同后端登录协议。登录 Feature 中提供了完整示例：页面表单、ViewModel、Repository、DataSource、会话落盘与退出登录。

### 🎨 主题与资源

主题系统支持亮/暗模式，并通过 Riverpod 持久化主题选择。

能力包括：

- Material 3 主题配置
- `ThemeExtension` 扩展语义化色值
- 亮/暗主题资产切换
- `BuildContext` 扩展访问颜色与资源
- `assets/images/` 与 `assets/images/dark/` 分离

示例：

```dart
context.appColor.brand
context.appAsset.logo
```

### 🌏 国际化

国际化使用 Flutter 官方 `gen-l10n`：

- 源文件：`lib/core/l10n/arb/app_en.arb`
- 源文件：`lib/core/l10n/arb/app_zh.arb`
- 配置文件：`l10n.yaml`
- 生成脚本：`./script/gen_l10n.sh`

切换语言示例：

```dart
ref.read(appLocaleProvider.notifier).setLocale(AppLocale.zh);
```

### 💾 存储层

模板将普通数据与敏感数据分开处理：

| 实现 | 底层 | 场景 |
| --- | --- | --- |
| `PrefsStorage` | SharedPreferences | 主题、语言、普通偏好 |
| `SecureStorage` | FlutterSecureStorage | Token、登录态、敏感凭证 |

业务代码通过统一抽象访问存储，便于测试和替换实现。

### 🧱 通用组件

`shared/widgets` 已内置常用组件：

| 组件 | 用途 |
| --- | --- |
| Toast / Loading | 全局轻提示、加载态 |
| Dialog / Sheet | 通用弹窗、确认面板、选择面板与业务选择面板 |
| RefreshView | 下拉刷新、上拉加载 |
| PrimaryRoundButton | 主按钮 |
| CountdownRoundButton | 验证码倒计时按钮 |
| InputTextWidget | 输入框 |
| ImageView | 本地、网络、SVG、Base64 图片展示 |
| SwitchWidget | 开关组件 |
| BaseCard | 基础卡片容器 |
| LabelRow | 标签行、箭头行、开关行 |
| ContextMenu / Overlay | 浮层与菜单能力 |

---

## 🛠 开发指南

### ➕ 添加一个新 Feature

1. 在 `lib/features/` 下创建模块目录。
2. 按 `data / domain / presentation` 创建分层文件。
3. 在 `domain/repositories` 中定义 Repository 抽象。
4. 在 `data/repositories` 中实现 Repository。
5. 在 `presentation/viewmodels` 中继承 `BaseVM` 管理 UI 状态与业务动作。
6. 在 `presentation/pages` 中继承 `BasePage` 编写 UI，并在 `page(scope)` 中读取状态、调用 ViewModel。
7. 在 `<feature>_routes.dart` 中声明路由。
8. 在 `<feature>_feature.dart` 中继承 `AppFeature` 并暴露路由。
9. 在 `features/features.dart` 中注册 `XxxFeature()`，并导出该 Feature。

推荐最小结构：

```text
lib/features/order/
├── order_feature.dart
├── data/
│   ├── datasources/order_datasource.dart
│   └── repositories/order_repository_impl.dart
├── domain/
│   ├── entities/order.dart
│   └── repositories/order_repository.dart
└── presentation/
    ├── order_routes.dart
    ├── pages/order_page.dart
    └── viewmodels/order_viewmodel.dart
```

### 📝 页面开发建议

- UI 逻辑放在 Page，业务动作放在 ViewModel。
- ViewModel 通过 Repository 抽象获取数据。
- 不在 Page 中直接调用 Dio、SharedPreferences、SecureStorage。
- 不让 Feature 直接依赖其他 Feature 的内部实现。
- 可复用 UI 放到 `shared/widgets`，可复用业务服务放到 `shared/services`。

### 🔌 替换为真实接口

1. 修改对应环境入口的 `baseUrl` 与 `apiPathPrefix`。
2. 在 Feature 的 DataSource 中替换接口路径。
3. 在 RepositoryImpl 中完成响应数据到业务实体的转换。
4. 在 ViewModel 中调用 Repository 并更新状态。

### 🤖 维护 AI 指令

本项目使用 Ruler 统一管理 Copilot、Cursor、Claude Code、Codex 等 AI Coding Assistant 指令。

- 指令源文件统一维护在 `.ruler/`。
- 不手动修改 Ruler 生成的 `AGENTS.md`、`CLAUDE.md`、`.claude/skills/`、`.cursor/skills/`、`.codex/` 等文件。
- 修改 `.ruler/` 后，先运行 `ruler apply --dry-run --verbose` 预览，再运行 `ruler apply`。
- 提交时包含 `.ruler/` 与 `.gitignore` 的变更，不提交生成文件。

详细说明见：[Ruler AI 指令管理](docs/ruler_usage.md)。

---

## 🔧 脚本工具

| 脚本 | 用途 |
| --- | --- |
| `./script/gen_l10n.sh` | 生成国际化代码 |
| `./script/gen_app_icon.sh` | 根据 `assets/app_icon.png` 生成 App 图标 |
| `dart run script/rename_project.dart <name>` | 重命名项目 |

```bash
# 生成国际化代码
./script/gen_l10n.sh

# 生成 App 图标
./script/gen_app_icon.sh

# 重命名项目
dart run script/rename_project.dart my_app
```

---

## 📚 主要依赖

| 类型 | 依赖 |
| --- | --- |
| 状态管理 / DI | `flutter_riverpod` |
| 路由 | `go_router` |
| 网络 | `dio`、`connectivity_plus` |
| 存储 | `shared_preferences`、`flutter_secure_storage` |
| 国际化 | `flutter_localizations`、`intl` |
| UI / 体验 | `bot_toast`、`easy_refresh`、`flutter_screenutil`、`cached_network_image`、`loading_animation_widget`、`shimmer`、`flutter_svg` |
| 工程能力 | `exception_catcher`、`logger`、`package_info_plus`、`permission_handler`、`flutter_launcher_icons` |

---

<p align="center">
  <sub>MIT License · 可自由用于个人与商业项目</sub>
</p>
