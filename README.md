# Flutter Starter App

一个开箱即用的 Flutter 快速开发模板，内置企业级网络层、路由管理、主题系统、国际化、状态管理、存储等基础设施，采用 Feature-First + Clean Architecture 分层架构。

## 目录

- [特性概览](#特性概览)
- [快速开始](#快速开始)
- [项目结构](#项目结构)
- [架构设计](#架构设计)
- [核心模块](#核心模块)
  - [应用启动与引导](#应用启动与引导)
  - [多环境配置](#多环境配置)
  - [网络层 (HTTP)](#网络层-http)
  - [路由系统](#路由系统)
  - [主题系统](#主题系统)
  - [状态管理 (Riverpod)](#状态管理-riverpod)
  - [存储层](#存储层)
  - [国际化 (i18n)](#国际化-i18n)
  - [通用 Presenter 架构](#通用-presenter-架构)
  - [认证模块](#认证模块)
  - [工具类](#工具类)
- [功能模块开发指南](#功能模块开发指南)
- [代码生成](#代码生成)
- [依赖清单](#依赖清单)

---

## 特性概览

| 特性 | 技术选型 | 说明 |
|------|----------|------|
| 状态管理 | Riverpod 2.x | 编译时安全，无 BuildContext 依赖 |
| 路由 | GoRouter 16.x | 声明式路由，通过抽象层解耦 |
| 网络请求 | Dio 5.x | 完整封装：拦截器链、缓存、重试、Mock |
| 主题 | Material 3 + ThemeExtension | 亮/暗双主题，语义化调色板 |
| 国际化 | flutter gen-l10n | 中/英双语，含生成脚本 |
| 存储 | SharedPreferences + FlutterSecureStorage | 偏好 + 安全凭证分离 |
| 屏幕适配 | flutter_screenutil | 按设计稿尺寸自动缩放 |
| 多环境 | Dev / SIT / Prod | 独立入口文件，配置即切换 |
| 架构模式 | Feature-First + Clean Architecture | 按功能模块分层，依赖反转 |

## 快速开始

```bash
# 1. 安装依赖
flutter pub get

# 2. 生成代码（首次运行或模型变更后）
flutter pub run build_runner build --delete-conflicting-outputs

# 3. 运行开发环境
flutter run -t lib/main_dev.dart

# 运行 SIT 环境
flutter run -t lib/main_sit.dart

# 运行生产环境
flutter run -t lib/main.dart
```

---

## 项目结构

```
lib/
├── main.dart                  # 生产环境入口
├── main_dev.dart              # 开发环境入口
├── main_sit.dart              # SIT 环境入口
├── app/                       # 应用启动、环境配置、根组件
├── core/                      # 全局基础设施
│   ├── constant/              # 常量（动画时长、UI 尺寸）
│   ├── di/                    # 依赖注入引导
│   ├── exception/             # 全局异常捕获
│   ├── l10n/                  # 国际化
│   ├── network/               # 网络层（Dio 封装）
│   │   ├── connection/        #   网络连接状态监听
│   │   └── http/              #   HTTP 客户端（config / interceptor / cache / request / response / mock ...）
│   ├── router/                # 路由（GoRouter 封装）
│   ├── service/               # 事件总线、日志
│   ├── storage/               # 本地存储（SharedPreferences / SecureStorage）
│   ├── theme/                 # 主题系统
│   └── util/                  # 工具类（屏幕适配、权限、图片）
├── features/                  # 业务功能模块
│   ├── auth/                  # 认证（登录/登出）
│   ├── home/                  # 首页
│   └── profile/               # 个人中心
└── shared/                    # 跨模块共享
    ├── presentation/          # BasePage / BaseVM / BaseState
    ├── services/              # 认证共享服务（AuthStore / AuthSession）
    └── widgets/               # 通用组件（ImageView / Switch）
```

> 各模块的详细说明见下方 [核心模块](#核心模块) 章节。

---

## 架构设计

### 分层架构

```
┌─────────────────────────────────────────────────┐
│                   Presentation                    │
│   pages/  viewmodels/  routes/  widgets/         │
│   (UI 层：页面、状态管理、路由定义、组件)            │
├─────────────────────────────────────────────────┤
│                     Domain                        │
│   entities/  repositories/ (接口)                 │
│   (领域层：业务实体、仓库抽象)                       │
├─────────────────────────────────────────────────┤
│                      Data                         │
│   datasources/  repositories/ (实现)              │
│   (数据层：远程/本地数据源、仓库实现)                  │
└─────────────────────────────────────────────────┘
```

### 依赖方向

```
Presentation ──→ Domain ←── Data
   (UI 层)     (接口定义)   (数据实现)
```

**依赖反转**：Presentation 和 Data 都依赖 Domain 层的抽象接口，Data 层实现 Domain 层的 Repository 接口。

### module 分工

| 层级 | 目录 | 职责 |
|------|------|------|
| `core/` | 全局基础设施 | 网络、路由、主题、存储、DI —— 不依赖任何 Feature |
| `features/` | 业务功能模块 | 按 Feature 组织，每个 Feature 内部按 Clean Architecture 分层 |
| `shared/` | 跨模块共享 | 通用 UI 基类、认证服务、通用组件 —— 被多个 Feature 引用 |
| `app/` | 应用入口 | 启动编排、环境配置、根组件 |

---

## 核心模块

### 应用启动与引导

启动入口为 `Application.run()`，执行以下流程：

```
1. appConfig = envConfig                      ← 设置全局环境配置
2. AppBootstrap.create(envConfig)             ← DI 引导
   ├── prefsStorage.init()                    ← SharedPreferences 初始化
   ├── secureStorage.init()                   ← FlutterSecureStorage 初始化
   ├── authStore.init()                       ← 从安全存储恢复登录会话
   └── createEnvOverrides(envConfig)           ← 收集环境特定的 Provider Overrides
3. AppExceptionCatcher.runAppGuarded()        ← 全局异常兜底
4. ProviderScope(overrides: ...)              ← 注入环境 Overrides
5. MaterialApp.router                         ← 挂载应用
```

```dart
// lib/main_dev.dart — 开发环境入口示例
Future<void> main() async {
  await Application.run(
    envConfig: const EnvConfig(
      envTag: EnvTag.dev,
      baseUrl: 'https://dev.example.com',
      apiPathPrefix: '/api',
    ),
  );
}
```

### 多环境配置

通过 `EnvConfig` 实现环境差异化，支持三个内置环境：

| 环境 | 入口文件 | `EnvTag` | 典型配置差异 |
|------|----------|----------|-------------|
| 开发 | `main_dev.dart` | `EnvTag.dev` | 日志开启、代理抓包、弱证书允许 |
| 测试 | `main_sit.dart` | `EnvTag.sit` | 日志开启、SIT 域名 |
| 生产 | `main.dart` | `EnvTag.prod` | 日志关闭、生产域名 |

`EnvConfig` 核心配置项：

| 参数 | 类型 | 说明 |
|------|------|------|
| `envTag` | `EnvTag` | 环境标识 (dev/sit/prod) |
| `baseUrl` | `String` | API 服务器域名 |
| `apiPathPrefix` | `String` | API 路径前缀，如 `/api` |
| `uiScreenSize` | `Size` | 设计稿尺寸，默认 402×786 |
| `proxyEnable` | `bool` | 是否开启抓包代理 |
| `caughtAddress` | `String?` | 抓包工具地址 |
| `httpLogEnable` | `bool` | 网络日志开关（生产环境默认关闭） |
| `httpRetryEnable` | `bool` | 请求重试开关 |
| `httpAllowBadCertificate` | `bool` | 是否允许弱证书（仅 dev/sit） |

### 网络层 (HTTP)

网络层是模板中最完善的子系统，基于 Dio 封装，通过抽象接口 `BaseHttpClient` 与具体实现解耦。

#### 架构概览

```
HttpConfig ──→ httpClientProvider ──→ BaseHttpClient (Dio 实现)
                  │
     ┌────────────┼────────────┐
     ▼            ▼            ▼
  拦截器链      缓存系统      重试策略
```

#### 请求/响应模型

- **`HttpRequest<T>`** — 一等请求对象，封装方法、路径、参数、header、超时、缓存策略、重试策略、响应解析器
- **`HttpResponse<T>`** — 一等响应对象，包含数据、状态码、header、可观测性元数据（耗时、缓存来源）
- **`ApiResponse<T>`** — 标准业务信封 `{code, message, data}`

#### 拦截器链（洋葱模型）

```
请求 → PacketCapture → Auth → BusinessStatus → ExceptionCapture → 实际请求
响应 ← PacketCapture ← Auth ← BusinessStatus ← ExceptionCapture ← 实际请求
```

| 拦截器 | 职责 |
|--------|------|
| `PacketCaptureInterceptor` | 抓包调试事件回调 |
| `AuthInterceptor` | 自动注入 Bearer Token，401 时触发 `onAuthFailed` |
| `BusinessStatusInterceptor` | 解析 `{code, data, msg}` 业务信封，提取 data 或抛出业务异常 |
| `ExceptionCaptureInterceptor` | 异常上报（过滤 cancel/cache 异常，记录 5xx/解析/服务器错误） |

#### 缓存系统

支持 6 种缓存策略：

| 策略 | 说明 |
|------|------|
| `noCache` | 不使用缓存，直接发请求 |
| `cacheFirst` | 优先返回缓存，同时发起网络请求更新 |
| `networkFirst` | 优先网络，失败时回退缓存 |
| `cacheOnly` | 仅从缓存读取 |
| `networkOnly` | 仅从网络读取 |
| `staleWhileRevalidate` | 返回缓存同时后台静默刷新 |

缓存存储采用双层设计：
- **内存缓存** (`MemoryHttpCacheStore`) — 快速访问
- **磁盘缓存** (`FileHttpCacheStore`) — 持久化，应用重启后仍可用

#### 重试策略

指数退避 + 随机 jitter：
- 默认乘法因子 1.6
- 按 HTTP 状态码筛选（408/429/500/502/503/504）
- 最大总耗时硬限制

#### 使用示例

```dart
// 在 ViewModel 中通过 Provider 获取 HTTP 客户端
final httpClient = ref.read(httpClientProvider);

// GET 请求
final response = await httpClient.get<UserModel>(
  '/user/profile',
  parser: (data) => UserModel.fromJson(data),
);

// POST 请求（带缓存）
final response = await httpClient.post<UserModel>(
  '/user/update',
  data: {'name': '新名称'},
  parser: (data) => UserModel.fromJson(data),
  cachePolicy: CachePolicy.networkFirst,
);
```

### 路由系统

路由层对 GoRouter 进行抽象隔离，业务代码不直接依赖 GoRouter API：

```
AppRouteDefine (抽象) ──→ toGoRoute() ──→ GoRouter
BaseNavigator (接口)  ──→ RouterNavigator (实现)
```

#### 核心概念

| 类 | 职责 |
|----|------|
| `AppRouteDefine` | 路由定义抽象类：`path`、`location`、`isPublic`、`buildPage()` |
| `BaseNavigator` | 导航操作接口：`go()` / `push()` / `replace()` / `replaceAll()` / `back()` |
| `RouterNavigator` | 唯一直接调用 GoRouter API 的导航实现 |
| `RouteState` | 框架无关的路由状态封装 |

#### 路由注册

在 `router_provider.dart` 中集中注册：

```dart
// 路由注册表 —— 添加新路由时在这里注册
final routes = <AppRouteDefine>[
  HomeRoute(),
  ProfileRoute(),
  LoginRoute(),
];
```

#### 认证守卫

- 通过 `authSessionProvider` 判断登录状态
- 标记 `isPublic = true` 的路由无需登录即可访问
- 未登录访问非公开路由 → 自动重定向到登录页

#### 定义新路由

```dart
class SettingsRoute extends AppRouteDefine {
  @override
  String get path => '/settings';

  @override
  String? get location => '/settings';

  @override
  bool get isPublic => false;

  @override
  Widget buildPage(BuildContext context, RouteState state) {
    return const SettingsPage();
  }
}
```

### 主题系统

基于 Flutter `ThemeExtension` 的类型安全主题系统。

#### 调色板 (`AppColor`)

50+ 语义化颜色，分 4 个色阶：

| 色阶 | 说明 | 示例 |
|------|------|------|
| `defaultColor` | 标准色 | `brandDefault = 0xFF0A59F7` |
| `lightColor` | 浅色变体 | `brandLight = 0xFFE8F1FF` |
| `pressedColor` | 按下状态 | `brandPressed = 0xFF084DD6` |
| `disabledColor` | 禁用状态 | `brandDisabled = 0xFFA3C4FC` |

颜色分类：
- 品牌色 (brand)、警告色 (warning)、告警色 (alert)、确认色 (confirm)
- 字体色 (font)、图标色 (icon)、背景色 (bg)、组件色 (component)、交互状态色 (interactiveState)

#### 亮/暗双主题

- `AppColor` — 亮色调色板
- `AppDarkColor` — 暗色调色板覆盖（蓝色从 `0xFF0A59F7` 变为 `0xFF317AF7`）
- `AppAsset` / `AppDarkAsset` — 主题感知的资源路径

#### 使用方式

```dart
// 通过 BuildContext 扩展访问
final brandColor = context.appColor.brandDefault;
final logoAsset = context.appAsset.logo;

// 切换主题
ref.read(appThemeModeProvider.notifier).toggleTheme();
```

### 状态管理 (Riverpod)

全项目统一使用 Riverpod 2.x，无其他状态管理方案混用。

#### Provider 命名约定

| 后缀 | 说明 | 示例 |
|------|------|------|
| `*Provider` | 只读 Provider | `httpClientProvider` |
| `*Notifier` | 可变状态 Provider | `authSessionProvider` |
| `*ValueProvider` | 简单值 Provider | `appLocaleValueProvider` |

#### ViewModel 模式

每个页面对应一个 ViewModel（Riverpod Notifier），持有页面状态：

```dart
@riverpod
class HomeViewModel extends _$HomeViewModel {
  @override
  HomeState build() => const HomeState();

  Future<void> loadData() async { ... }
  Future<void> refresh() async { ... }
}
```

### 存储层

通过 `StorageService` 接口统一抽象，区分两种存储场景：

| 实现 | 底层技术 | 适用场景 |
|------|----------|----------|
| `PrefsStorage` | SharedPreferences | 偏好设置、UI 缓存、非敏感数据 |
| `SecureStorage` | FlutterSecureStorage | Token、密码、敏感凭证 |

```dart
// 普通存储
await prefsStorage.setString('theme', 'dark');

// 安全存储（Token 等敏感数据）
await secureStorage.writeToken('access_token_value');
final token = secureStorage.bearerToken; // 同步读取（仅内存缓存）
```

### 国际化 (i18n)

- **源文件**：`lib/core/l10n/arb/app_en.arb` / `app_zh.arb`
- **生成脚本**：`script/gen_l10n.sh`
- **配置**：`l10n.yaml`
- **语言切换**：通过 `l10nProvider`，自动持久化

```dart
// 获取翻译文案
Text(AppLocalizations.of(context)!.appTitle)

// 通过扩展快速访问
Text(context.i18n.appTitle)

// 切换语言
ref.read(appLocaleProvider.notifier).setLocale(AppLocale.zh);
```

### 通用 Presenter 架构

#### BasePage

所有页面的基类，自动提供：
- `Scaffold` + `SafeArea` 骨架
- 页面生命周期管理（`init` → `onReady` → `onResume` → `onPause` → `dispose`）
- `AutomaticKeepAliveClientMixin` — 支持 TabBar 页面保活
- App 前后台切换监听
- `PopScope` 返回拦截

#### BaseVM

ViewModel 基类，提供：
- 生命周期钩子（`init` / `onReady` / `onResume` / `onPause` / `onClose`）
- `runWithLoading()` — 自动管理 loading 状态
- `emitHint()` — 提示信息
- `pop()` — 页面返回

#### 使用模式

```dart
class MyPage extends BasePage<MyViewModel> {
  const MyPage({super.key});

  @override
  MyViewModel createViewModel(WidgetRef ref) => ref.watch(myViewModelProvider.notifier);

  @override
  Widget buildPage(BuildContext context, WidgetRef ref, MyViewModel vm, MyState state) {
    return Center(child: Text('Hello'));
  }
}
```

### 认证模块

认证采用双层设计：

**共享层** (`shared/services/auth/`)：
- `AuthSession` — 会话数据模型（token + refreshToken + payload）
- `AuthStore` — 全局单例，内存缓存 + 安全存储持久化
- `authSessionProvider` — 响应式登录状态

**Feature 层** (`features/auth/`)：
- `AuthRepository` (接口) → `AuthRepositoryImpl` (实现)
- `AuthRemoteDataSource` — 实际 API 调用
- `LoginPage` + `AuthViewModel` — 登录页面和状态管理

认证流程：
```
LoginPage → AuthViewModel.login() → AuthRepository → API
                                  ↓
                            AuthStore.setSession()
                                  ↓
                        authSessionProvider 更新
                                  ↓
                     AuthInterceptor 自动注入新 Token
```

### 工具类

| 工具 | 说明 |
|------|------|
| `ScreenUtil` | 封装 flutter_screenutil，按设计稿自适应 |
| `ImageUtil` | 图片尺寸获取、Base64 编解码、保存到相册 |
| `PermissionUtil` | 运行时权限请求封装 |
| `EventBus` | 轻量同步事件总线 |
| `AppLogger` | 统一日志输出（基于 package:logger） |
| `ConnectionManager` | 网络连接状态监听 |

---

## 功能模块开发指南

### 添加新 Feature 的步骤

1. **创建目录结构**

```
lib/features/<feature_name>/
├── data/
│   ├── datasources/<feature>_datasource.dart      # 远程/本地数据源
│   └── repositories/<feature>_repository_impl.dart # 仓库实现
├── domain/
│   ├── entities/                                    # 业务实体 (freezed)
│   └── repositories/<feature>_repository.dart      # 仓库抽象接口
└── presentation/
    ├── <feature>_routes.dart                        # 路由定义
    ├── pages/<feature>_page.dart                    # 页面 Widget
    └── viewmodels/<feature>_viewmodel.dart          # ViewModel + State + Provider
```

2. **定义 Domain 层**

```dart
// domain/repositories/example_repository.dart
abstract class ExampleRepository {
  Future<List<Item>> getItems();
}
```

3. **实现 Data 层**

```dart
// data/repositories/example_repository_impl.dart
class ExampleRepositoryImpl implements ExampleRepository {
  final BaseHttpClient _httpClient;
  ExampleRepositoryImpl(this._httpClient);

  @override
  Future<List<Item>> getItems() async {
    final response = await _httpClient.get<List<Item>>(
      '/items',
      parser: (data) => (data as List).map((e) => Item.fromJson(e)).toList(),
    );
    return response.data!;
  }
}
```

4. **定义 ViewModel**

```dart
// presentation/viewmodels/example_viewmodel.dart
@riverpod
class ExampleViewModel extends _$ExampleViewModel {
  @override
  ExampleState build() => const ExampleState();

  Future<void> loadItems() async {
    state = state.copyWith(isLoading: true);
    final repo = ref.read(exampleRepositoryProvider);
    final items = await repo.getItems();
    state = state.copyWith(isLoading: false, items: items);
  }
}
```

5. **定义路由**

```dart
// presentation/example_routes.dart
class ExampleRoute extends AppRouteDefine {
  @override String get path => '/example';
  @override String? get location => '/example';
  @override bool get isPublic => false;
  @override Widget buildPage(BuildContext context, RouteState state) =>
    const ExamplePage();
}
```

6. **注册路由** — 在 `core/router/router_provider.dart` 的 `routes` 列表中添加 `ExampleRoute()`

7. **注册 Provider** — 在 `core/di/di_overrides.dart` 中添加 Provider Override（如需环境差异化）

---

## 代码生成

模板使用 `freezed` + `json_serializable` 进行不可变数据模型和 JSON 序列化的代码生成。

```bash
# 一次性生成
flutter pub run build_runner build --delete-conflicting-outputs

# 开发时持续监听
flutter pub run build_runner watch --delete-conflicting-outputs
```

根据 `analysis_options.yaml`，生成的 `*.freezed.dart` / `*.g.dart` 文件需要排除 lint 检查：

```yaml
analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
```

---

## 依赖清单

### 核心框架

| 包 | 版本 | 用途 |
|----|------|------|
| `flutter_riverpod` | ^2.6.1 | 状态管理 + DI |
| `go_router` | ^16.2.4 | 声明式路由 |
| `dio` | ^5.9.0 | HTTP 网络请求 |
| `freezed_annotation` | ^2.4.4 | 不可变数据模型 |

### 存储

| 包 | 版本 | 用途 |
|----|------|------|
| `shared_preferences` | ^2.5.5 | 偏好存储 |
| `flutter_secure_storage` | 9.2.4 | 安全凭证存储 |

### UI & 交互

| 包 | 版本 | 用途 |
|----|------|------|
| `flutter_screenutil` | ^5.9.3 | 屏幕自适应 |
| `flutter_svg` | 2.3.0 | SVG 渲染 |
| `cached_network_image` | ^3.4.1 | 网络图片缓存 |
| `shimmer` | ^3.0.0 | 骨架屏加载 |
| `easy_refresh` | ^3.5.0 | 下拉刷新/上拉加载 |
| `bot_toast` | ^4.1.3 | Toast 提示 |
| `loading_animation_widget` | ^1.3.0 | Loading 动画 |

### 工具

| 包 | 版本 | 用途 |
|----|------|------|
| `logger` | ^2.6.1 | 日志输出 |
| `connectivity_plus` | ^7.1.0 | 网络连接状态 |
| `permission_handler` | ^12.0.1 | 权限管理 |
| `package_info_plus` | ^9.0.1 | 包信息 |
| `exception_catcher` | 0.1.1 | 异常捕获 |
| `intl` | ^0.20.2 | 国际化格式化 |
| `date_format` | ^2.0.9 | 日期格式化 |
| `collection` | ^1.19.1 | 集合工具 |

### 开发依赖

| 包 | 版本 | 用途 |
|----|------|------|
| `build_runner` | ^2.4.13 | 代码生成运行器 |
| `freezed` | ^2.5.8 | Freezed 代码生成 |
| `json_serializable` | ^6.9.0 | JSON 序列化生成 |
| `flutter_lints` | ^6.0.0 | Lint 规则 |

---

## License

MIT — 可自由用于商业和个人项目。
