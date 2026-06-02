<p align="center">
  <img src="assets/app_icon.png" width="120" alt="Flutter Starter App" />
</p>

<h1 align="center">Flutter Starter App</h1>

<p align="center">
  <strong>开箱即用的 Flutter 快速开发模板</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Riverpod-2.x-06B6D4?logo=riverpod&logoColor=white" alt="Riverpod" />
  <img src="https://img.shields.io/badge/license-MIT-green" alt="License" />
</p>

---

内置企业级网络层、路由管理、主题系统、国际化、状态管理、存储等基础设施，采用 Feature-First + Clean Architecture 分层架构。Clone 即用，专注业务开发。

## 📋 目录

- [特性速览](#-特性速览)
- [快速开始](#-快速开始)
- [项目结构](#-项目结构)
- [架构设计](#-架构设计)
- [核心模块](#-核心模块)
  - [启动引导](#启动引导)
  - [多环境](#多环境)
  - [网络层](#网络层)
  - [路由系统](#路由系统)
  - [主题系统](#主题系统)
  - [状态管理](#状态管理)
  - [存储层](#存储层)
  - [国际化](#国际化)
  - [通用组件](#通用组件)
  - [认证模块](#认证模块)
- [开发指南](#-开发指南)
- [脚本工具](#-脚本工具)
- [依赖清单](#-依赖清单)

---

## ✨ 特性速览

| 🧩 特性 | 🔧 技术选型 | 💡 说明 |
|---------|-------------|--------|
| 状态管理 | **Riverpod 2.x** | 编译时安全，无 BuildContext 依赖 |
| 路由 | **GoRouter 16.x** | 声明式路由，抽象层解耦 |
| 网络请求 | **Dio 5.x** | 拦截器链 · 缓存 · 重试 · Mock |
| 主题 | **Material 3 + ThemeExtension** | 亮/暗双主题，50+ 语义化色值 |
| 国际化 | **flutter gen-l10n** | 中/英双语，一键生成 |
| 存储 | **SharedPreferences + SecureStorage** | 偏好设置 & 安全凭证分离 |
| 屏幕适配 | **flutter_screenutil** | 按设计稿自动缩放 |
| 多环境 | **Dev / SIT / Prod** | 独立入口，配置即切换 |
| 架构 | **Feature-First + Clean Architecture** | 依赖反转，分层清晰 |

---

## 🚀 快速开始

```bash
# 1. 安装依赖
flutter pub get

# 2. 运行开发环境
flutter run -t lib/main_dev.dart

# 运行 SIT 环境
flutter run -t lib/main_sit.dart

# 运行生产环境
flutter run -t lib/main_prod.dart

# 默认入口同样指向生产环境
flutter run -t lib/main.dart
```

> **提示**：首次使用请在 `main_dev.dart` 中将 `baseUrl` 替换为你的 API 地址。

---

## 📁 项目结构

```
lib/
├── main.dart                                    # 默认入口，调用 main_prod.dart
├── main_dev.dart / main_sit.dart / main_prod.dart # 三环境入口
├── app/                                          # 启动编排 + 环境配置
├── core/                                         # 全局基础设施（不依赖业务）
│   ├── constant/                                 #   UI 常量、动画时长
│   ├── di/                                       #   依赖注入引导
│   ├── exception/                                #   全局异常捕获
│   ├── l10n/                                     #   国际化
│   ├── network/                                  #   网络层（Dio 封装）
│   │   ├── connection/                           #     网络状态监听
│   │   └── http/                                 #     HTTP 客户端
│   │       ├── config/                           #       全局配置、重试策略
│   │       ├── interceptor/                      #       拦截器链
│   │       ├── cache/                            #       内存 + 磁盘双缓冲
│   │       ├── request/   response/              #       请求/响应模型
│   │       └── mock/                             #       Mock 适配器
│   ├── router/                                   #   GoRouter 封装
│   ├── service/                                  #   事件总线、日志
│   ├── storage/                                  #   本地存储
│   ├── theme/                                    #   主题系统
│   └── util/                                     #   工具类
├── features/                                     # 业务功能模块
│   ├── auth/          data / domain / presentation
│   ├── home/          data / domain / presentation
│   └── profile/       (预留模板)
└── shared/                                       # 跨模块共享
    ├── presentation/                             #   BasePage / BaseVM / BaseState
    ├── services/                                 #   认证共享服务
    └── widgets/                                  #   Toast · Loading · Dialog · Input · Button
```

---

## 🏗 架构设计

### 分层架构

```
┌─────────────────────────────────────────┐
│             Presentation                 │
│  pages  ·  viewmodels  ·  routes  ·  widgets  │
│            （UI + 状态管理）              │
├─────────────────────────────────────────┤
│               Domain                     │
│       entities  ·  repositories         │
│          （业务实体 + 接口抽象）            │
├─────────────────────────────────────────┤
│                Data                      │
│    datasources  ·  repository impl      │
│         （数据源 + 接口实现）              │
└─────────────────────────────────────────┘
```

**依赖方向**：`Presentation → Domain ← Data`（依赖反转）

### 模块分工

| 层级 | 职责 | 依赖规则 |
|------|------|----------|
| `app/` | 启动编排、环境配置、根组件 | 可依赖所有层级 |
| `core/` | 网络、路由、主题、存储、DI | 不依赖任何 Feature |
| `features/` | 按功能组织，内部分 data / domain / presentation | 依赖 core + shared |
| `shared/` | BasePage、BaseVM、Toast、通用组件 | 依赖 core |

---

## 📦 核心模块

### 启动引导

`Application.run()` 按以下流程启动：

```
① appConfig = envConfig               → 设置全局环境
② AppBootstrap.create(envConfig)      → 初始化存储 → 恢复会话 → 收集 Overrides
③ AppExceptionCatcher.runAppGuarded() → 全局异常兜底
④ ProviderScope(overrides: ...)       → 注入环境 Overrides
⑤ MaterialApp.router                  → 挂载应用
```

### 多环境

| 环境 | 入口 | EnvTag | 特点 |
|------|------|--------|------|
| 🛠 开发 | `main_dev.dart` | `dev` | 日志开启、抓包代理 |
| 🧪 测试 | `main_sit.dart` | `sit` | 日志开启、SIT 域名 |
| 🚀 生产 | `main.dart` | `prod` | 日志关闭、生产域名 |

```dart
// lib/main_dev.dart
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

### 网络层

基于 Dio 的企业级封装，通过 `BaseHttpClient` 抽象解耦。

```
HttpConfig → httpClientProvider → BaseHttpClient (Dio)
                  │
       ┌──────────┼──────────┐
       ▼          ▼          ▼
    拦截器链    缓存系统    重试策略
```

**拦截器链**（洋葱模型）：

```
请求 → PacketCapture → Auth → BusinessStatus → ExceptionCapture → 服务端
响应 ← PacketCapture ← Auth ← BusinessStatus ← ExceptionCapture ← 服务端
```

| 拦截器 | 职责 |
|--------|------|
| `AuthInterceptor` | Token 自动注入，401 触发回调 |
| `BusinessStatusInterceptor` | 业务码 `{code, data, msg}` 解包 |
| `ExceptionCaptureInterceptor` | 异常分类上报 |
| `PacketCaptureInterceptor` | 抓包调试 |

**缓存策略**：`noCache` · `cacheFirst` · `networkFirst` · `cacheOnly` · `networkOnly` · `staleWhileRevalidate`

**重试策略**：指数退避 + 随机 jitter，按状态码筛选，总耗时硬限制。

### 路由系统

GoRouter 的清爽隔离层：

```
AppRouteDefine (抽象) → toGoRoute() → GoRouter
BaseNavigator  (接口) → RouterNavigator (实现)
```

- **集中注册**：所有路由在 `router_provider.dart` 的 `_allRoutes` 列表中注册
- **认证守卫**：`isPublic = false` 的路由未登录时自动重定向到登录页
- **导航抽象**：业务代码依赖 `BaseNavigator` 接口，不直接引用 GoRouter

### 主题系统

基于 Flutter `ThemeExtension`，类型安全的颜色 & 资产访问。

```
BuildContext.appColor   →  AppColor (50+ 语义化色值)
BuildContext.appAsset   →  AppAsset (主题感知资源路径)
```

**颜色体系**：品牌 · 警示 · 字体 · 图标 · 背景 · 组件 · 交互态，每种 4 个色阶。

| 色阶 | 命名 | 示例 |
|------|------|------|
| 标准 | `brand` | `0xFF0A59F7` |
| 浅色 | `brandLight` | `0xFFE8F1FF` |
| 按压 | `brandPressed` | `0xFF084DD6` |
| 禁用 | `brandDisabled` | `0xFFA3C4FC` |

### 状态管理

全项目统一 **Riverpod 2.x**，无混用。

| Provider 后缀 | 说明 | 示例 |
|-------------|------|------|
| `*Provider` | 只读 Provider | `httpClientProvider` |
| `*Notifier` | 可变状态 Provider | `authSessionProvider` |
| `*ValueProvider` | 简单值 Provider | `appLocaleValueProvider` |

### 存储层

| 实现 | 底层 | 场景 |
|------|------|------|
| `PrefsStorage` | SharedPreferences | 偏好设置、UI 缓存 |
| `SecureStorage` | FlutterSecureStorage | Token、敏感凭证 |

### 国际化

- **源文件**：`lib/core/l10n/arb/app_en.arb` / `app_zh.arb`
- **切换语言**：`ref.read(appLocaleProvider.notifier).setLocale(AppLocale.zh)`
- **生成脚本**：`./script/gen_l10n.sh`

### 通用组件

| 组件 | 用途 |
|------|------|
| `BasePage` / `BaseVM` / `BaseState` | 页面生命周期 + ViewModel 模式 |
| `BaseToast` | 轻提示（自动消失） |
| `BaseLoading` | 加载中蒙版 |
| `CommonDialog` / `WarningDialog` | 弹窗（队列管理） |
| `SuccessTips` / `FailTips` | 成功/失败提示 |
| `AppTextField` / `InputTextWidget` | 输入框组件 |
| `CountdownRoundButton` | 验证码倒计时按钮 |
| `ImageView` | 图片组件（网络/本地/SVG/Base64） |

### 认证模块

双层设计：

```
shared/services/auth/          ← 共享层
  AuthSession · AuthStore · authSessionProvider

features/auth/                 ← Feature 层
  AuthRepository → AuthRepositoryImpl → AuthRemoteDataSource
  LoginPage + AuthViewModel
```

流程：`LoginPage → ViewModel.login() → API → AuthStore.setSession() → Provider 更新 → Interceptor 注入新 Token`

---

## 📖 开发指南

### 添加新功能模块

```
lib/features/<name>/
├── data/
│   ├── datasources/<name>_datasource.dart
│   └── repositories/<name>_repository_impl.dart
├── domain/
│   ├── entities/
│   └── repositories/<name>_repository.dart
└── presentation/
    ├── <name>_routes.dart
    ├── pages/<name>_page.dart
    └── viewmodels/<name>_viewmodel.dart
```

完成代码后在 `router_provider.dart` 注册路由即可。

---

## 🔧 脚本工具

| 脚本 | 用途 |
|------|------|
| `./script/gen_l10n.sh` | 生成国际化代码 |
| `./script/gen_app_icon.sh` | 从 `assets/app_icon.png` 生成 App 图标 |

```bash
# 生成 App 图标
./script/gen_app_icon.sh
```

---

## 📦 依赖清单

### 核心

| 包 | 版本 | 用途 |
|---|------|------|
| `flutter_riverpod` | ^2.6.1 | 状态管理 + DI |
| `go_router` | ^16.2.4 | 路由 |
| `dio` | ^5.9.0 | 网络请求 |

### 存储

| 包 | 版本 | 用途 |
|---|------|------|
| `shared_preferences` | ^2.5.5 | 偏好存储 |
| `flutter_secure_storage` | 9.2.4 | 安全存储 |

### UI

| 包 | 版本 | 用途 |
|---|------|------|
| `flutter_screenutil` | ^5.9.3 | 屏幕适配 |
| `flutter_svg` | 2.3.0 | SVG |
| `cached_network_image` | ^3.4.1 | 图片缓存 |
| `shimmer` | ^3.0.0 | 骨架屏 |
| `easy_refresh` | ^3.5.0 | 下拉刷新 |
| `bot_toast` | ^4.1.3 | Toast |
| `loading_animation_widget` | ^1.3.0 | Loading 动画 |

### 工具

| 包 | 版本 | 用途 |
|---|------|------|
| `logger` | ^2.6.1 | 日志 |
| `connectivity_plus` | ^7.1.0 | 网络状态 |
| `permission_handler` | ^12.0.1 | 权限 |
| `package_info_plus` | ^9.0.1 | 包信息 |
| `exception_catcher` | 0.1.1 | 异常捕获 |
| `intl` | ^0.20.2 | 国际化 |
| `date_format` | ^2.0.9 | 日期格式化 |
| `collection` | ^1.19.1 | 集合工具 |

### 开发依赖

| 包 | 版本 | 用途 |
|---|------|------|
| `flutter_lints` | ^6.0.0 | Lint |
| `flutter_launcher_icons` | 0.14.4 | App 图标生成 |

---

<p align="center">
  <sub>MIT License · 自由用于商业和个人项目</sub>
</p>
