# 📘 模板使用说明

这份文档面向第一次 clone 本模板的开发者，说明如何把 `Flutter Starter App` 快速改造成自己的业务项目。

## 📚 目录

- [使用流程总览](#-使用流程总览)
- [初始化项目](#-初始化项目)
- [修改项目名称](#-修改项目名称)
- [配置运行环境](#-配置运行环境)
- [新增业务 Feature](#-新增业务-feature)
- [注册页面路由](#-注册页面路由)
- [接入真实接口](#-接入真实接口)
- [接入真实登录](#-接入真实登录)
- [修改主题与资源](#-修改主题与资源)
- [修改国际化文案](#-修改国际化文案)
- [常见开发约定](#-常见开发约定)

---

## 🚀 使用流程总览

推荐按下面顺序接入真实项目：

```text
clone 模板
  ↓
flutter pub get
  ↓
重命名项目
  ↓
替换 App 图标、包名、应用名
  ↓
配置 Dev / SIT / Prod 环境
  ↓
接入真实登录接口
  ↓
新增业务 Feature
  ↓
注册 Feature 路由
  ↓
替换主题、资源、国际化文案
  ↓
补充业务测试与发布配置
```

如果只是验证模板能力，可以先跳过重命名、图标、包名步骤，直接从 `flutter run -t lib/main_dev.dart` 开始。

---

## ⚡ 初始化项目

```bash
flutter pub get
flutter run -t lib/main_dev.dart
```

其他环境入口：

```bash
# SIT 环境
flutter run -t lib/main_sit.dart

# 生产环境
flutter run -t lib/main_prod.dart

# 默认入口，当前指向生产环境
flutter run -t lib/main.dart
```

建议首次运行后先确认：

- 首页是否正常展示
- Todo 示例是否可进入，并支持新增、切换完成、删除
- 登录页是否可进入
- 主题切换是否正常
- 国际化切换是否正常
- 示例网络请求是否符合预期

---

## 🏷 修改项目名称

模板提供了项目重命名脚本：

```bash
dart run script/rename_project.dart my_app
```

执行后建议检查：

```bash
flutter pub get
flutter analyze
flutter test
```

脚本主要用于替换 Flutter/Dart 项目内的名称引用。平台侧配置仍建议人工复核：

- Android package name
- iOS bundle identifier
- macOS / Windows / Linux 应用名
- App 显示名称
- 发布签名配置

---

## 🌍 配置运行环境

环境配置集中在入口文件：

```text
lib/main_dev.dart
lib/main_sit.dart
lib/main_prod.dart
```

示例：

```dart
await Application.run(
  envConfig: const EnvConfig(
    envTag: EnvTag.dev,
    baseUrl: 'https://dev.example.com',
    apiPathPrefix: '/api',
    proxyEnable: false,
    caughtAddress: '127.0.0.1:8888',
    privacyPolicyUrl: 'https://example.com/privacy',
    userAgreementUrl: 'https://example.com/agreement',
  ),
);
```

常用字段说明：

| 字段 | 说明 |
| --- | --- |
| `envTag` | 当前环境标识，区分 Dev / SIT / Prod |
| `baseUrl` | 接口域名 |
| `apiPathPrefix` | API 路径前缀 |
| `proxyEnable` | 是否启用代理抓包 |
| `caughtAddress` | 抓包代理地址 |
| `privacyPolicyUrl` | 隐私协议地址 |
| `userAgreementUrl` | 用户协议地址 |

建议真实项目中至少维护三套环境：

| 环境 | 用途 |
| --- | --- |
| Dev | 本地开发、自测、抓包 |
| SIT | 测试环境、联调环境 |
| Prod | 生产环境 |

---

## ➕ 新增业务 Feature

模板采用 Feature-First + Clean Architecture。新增业务模块时，推荐在 `lib/features/` 下创建独立目录。

模板已内置 `todo` 示例 Feature，可作为新增业务模块的参考：

```text
lib/features/todo/
├── data/
│   ├── datasources/todo_local_datasource.dart
│   └── repositories/todo_repository_impl.dart
├── domain/
│   ├── entities/todo_item.dart
│   └── repositories/todo_repository.dart
└── presentation/
    ├── todo_routes.dart
    ├── pages/todo_page.dart
    └── viewmodels/todo_viewmodel.dart
```

该示例演示了本地内存数据源、Repository 抽象、ViewModel 状态管理、页面交互、路由注册和首页导航入口。

以 `order` 模块为例：

```text
lib/features/order/
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

分层职责：

| 层级 | 职责 |
| --- | --- |
| `presentation` | 页面、ViewModel、路由定义、UI 状态 |
| `domain` | 业务实体、Repository 抽象 |
| `data` | DataSource、Repository 实现、接口数据转换 |

推荐调用链：

```text
OrderPage
  ↓ 用户交互
OrderViewModel
  ↓ 调用抽象
OrderRepository
  ↓ 具体实现
OrderRepositoryImpl
  ↓ 委托数据源
OrderDataSource / HttpClient
```

---

## 🧭 注册页面路由

### 1. 在 Feature 内定义路由

示例：

```dart
import 'package:flutter/widgets.dart';

import '../../../core/router/app_route_define.dart';
import 'pages/order_page.dart';

final class OrderRoute extends AppRouteDefine {
  const OrderRoute();

  @override
  String get path => '/order';

  @override
  bool get public => false;

  @override
  Widget buildPage(BuildContext context, RouteState state) {
    return const OrderPage();
  }
}
```

`public` 含义：

| 值 | 说明 |
| --- | --- |
| `true` | 公开页面，未登录也可以访问 |
| `false` | 受保护页面，未登录会跳转到登录页 |

### 2. 注册到根路由表

打开 `lib/core/router/router_provider.dart`：

```dart
final List<AppRouteDefine> _allRoutes = [
  HomeRoute(),
  ProfileRoute(),
  LoginRoute(),
  OrderRoute(),
];
```

同时补充 import：

```dart
import '../../features/order/presentation/order_routes.dart';
```

### 3. 在业务代码中导航

业务层建议依赖 `BaseNavigator` 抽象，而不是直接依赖 GoRouter：

```dart
ref.read(appRouterProvider).push(const OrderRoute());
```

---

## 🌐 接入真实接口

### 1. 修改环境域名

先在对应入口文件中配置真实接口地址：

```dart
baseUrl: 'https://api.example.com',
apiPathPrefix: '/api',
```

### 2. 在 DataSource 中请求接口

示例：

```dart
final class OrderDataSource {
  const OrderDataSource(this._client);

  final BaseHttpClient _client;

  Future<List<dynamic>> fetchOrders() async {
    final response = await _client.get('/orders');
    return response.data as List<dynamic>;
  }
}
```

### 3. 在 RepositoryImpl 中转换业务实体

```dart
final class OrderRepositoryImpl implements OrderRepository {
  const OrderRepositoryImpl(this._dataSource);

  final OrderDataSource _dataSource;

  @override
  Future<List<Order>> fetchOrders() async {
    final rows = await _dataSource.fetchOrders();
    return rows
        .map((item) => Order.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
```

### 4. 在 ViewModel 中更新页面状态

```dart
final class OrderState extends BaseState {
  const OrderState({this.initialized = false, this.orders = const []});

  final bool initialized;
  final List<Order> orders;

  OrderState copyWith({bool? initialized, List<Order>? orders}) {
    return OrderState(
      initialized: initialized ?? this.initialized,
      orders: orders ?? this.orders,
    );
  }
}

final class OrderViewModel extends BaseVM<OrderState> {
  @override
  OrderState initialState() => const OrderState();

  Future<void> loadOrders() async {
    await PresentationHelper.runWithLoading(() async {
      final orders = await ref.read(orderRepositoryProvider).fetchOrders();
      state = state.copyWith(initialized: true, orders: orders);
    });
  }
}
```

由页面决定何时触发首屏加载：

```dart
final class OrderPage extends BasePage {
  const OrderPage({super.key});

  @override
  void onPageReady(PageScope scope) {
    scope.ref.read(orderViewModelProvider.notifier).loadOrders();
  }

  @override
  Widget page(PageScope scope) {
    final state = scope.ref.watch(orderViewModelProvider);

    if (!state.initialized) {
      return ColoredBox(color: scope.context.appColor.backgroundPrimary);
    }

    return OrderList(orders: state.orders);
  }
}
```

---

## 🔐 接入真实登录

登录链路已经在 `features/auth` 中给出示例：

```text
LoginPage
  ↓
AuthViewModel.login()
  ↓
AuthRepository
  ↓
AuthRepositoryImpl
  ↓
AuthRemoteDataSource
  ↓
AuthStore.setSession()
  ↓
authSessionProvider 更新
  ↓
RouterGuard / AuthInterceptor 生效
```

接入真实登录通常只需要改三处：

### 1. 修改登录接口路径

在 Auth DataSource 中替换真实接口路径和参数结构。

### 2. 修改响应解析

将后端返回的 token、refreshToken、用户信息转换成 `AuthSession`。

### 3. 确认退出登录逻辑

退出登录时清空本地会话：

```dart
await ref.read(authRepositoryProvider).logout();
```

登录成功后，模板会自动完成：

- Token 安全存储
- 登录态 Provider 更新
- 路由守卫重新计算
- HTTP 请求自动携带 Token

---

## 🎨 修改主题与资源

主题相关代码位于：

```text
lib/core/theme/
```

常见修改点：

| 需求 | 修改位置 |
| --- | --- |
| 修改品牌色 | `lib/core/theme/theme.dart` 或具体色值定义文件 |
| 增加语义化颜色 | ThemeExtension 对应类 |
| 修改亮暗主题资源 | `lib/core/theme/asset/` |
| 替换图片资源 | `assets/images/`、`assets/images/dark/` |

页面中推荐通过 `BuildContext` 扩展访问主题资源：

```dart
context.appColor.brand
context.appAsset.logo
```

生成 App 图标：

```bash
./script/gen_app_icon.sh
```

---

## 🌏 修改国际化文案

国际化源文件：

```text
lib/core/l10n/arb/app_en.arb
lib/core/l10n/arb/app_zh.arb
```

修改或新增文案后执行：

```bash
./script/gen_l10n.sh
```

在代码中切换语言：

```dart
ref.read(appLocaleProvider.notifier).setLocale(AppLocale.zh);
```

页面中读取文案时，优先使用项目内已经封装好的 l10n Provider 或 BuildContext 扩展，保持调用方式统一。

---

## ✅ 常见开发约定

### 推荐做法

- 一个业务模块对应一个 `Feature` 目录。
- 页面继承 `BasePage`，在 `page(scope)` 中读取状态并调用 ViewModel。
- ViewModel 只依赖 Repository 抽象，不直接依赖 HTTP 客户端，也不管理页面生命周期。
- RepositoryImpl 负责把接口数据转换成业务实体。
- 公共 UI 放到 `shared/widgets`。
- 公共业务服务放到 `shared/services`。
- 全局基础设施放到 `core`。
- 新增页面时先在 Feature 内定义路由，再注册到根路由表。

### 避免做法

- 不要在 Page 中直接写接口请求。
- 不要在 Page 中直接读写 SharedPreferences 或 SecureStorage。
- 不要让一个 Feature 直接依赖另一个 Feature 的内部实现。
- 不要把具体业务逻辑放进 `core`。
- 不要绕过 `AuthStore` 手动管理 token。
- 不要在多个状态管理方案之间混用。

---

## 🧪 接入业务后的建议检查

每次完成一个 Feature 后，建议执行：

```bash
flutter analyze
flutter test
```

如果修改了国际化、资源或平台配置，也建议重新运行 App 做一次手动验证。
