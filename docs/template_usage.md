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
- [构建发布包](#-构建发布包)
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

- Todo Tab 是否默认展示，并支持新增、切换完成、删除
- Profile Tab 是否可进入，并支持主题切换与退出登录
- 登录页是否可进入
- 国际化切换是否正常
- 示例网络请求是否符合预期

---

## 🏷 修改项目名称

模板提供了项目重命名脚本：

```bash
dart run script/rename_project.dart my_app \
  --package-id com.example.myapp \
  --app-name "我的APP" \
  --en-app-name "My App"
```

参数说明：

- `<new_project_name>`：Dart 包名，用于 `pubspec.yaml` 与 `package:` imports，例如 `my_app`。
- `--package-id`：Android `namespace` / `applicationId`、Apple 平台 `PRODUCT_BUNDLE_IDENTIFIER` 与 Linux `APPLICATION_ID`，例如 `com.example.myapp`。
- `--app-name`：默认显示名，用于 Android、Apple 平台、Linux、Web、Windows 与中文 ARB 的 `appTitle`。
- `--en-app-name`：英文显示名，用于英文 ARB 的 `appTitle`，并在 `.vscode/launch.json` 存在时更新启动配置名。

脚本会自动处理：

- Android：`namespace`、`applicationId`、`AndroidManifest.xml` 显示名、`MainActivity` package 声明与 Kotlin/Java 目录迁移。
- iOS：Runner target bundle id、RunnerTests target bundle id、`Info.plist` 显示名与 `CFBundleName`。
- macOS：`AppInfo.xcconfig` 的应用名与 bundle id、RunnerTests bundle id、Scheme / Test Host 中的 `.app` 名称。
- Linux：`BINARY_NAME`、`APPLICATION_ID`、窗口标题。
- Web：`index.html` 标题、PWA manifest 的 `name` 与 `short_name`。
- Windows：CMake project / binary name、窗口标题、版本资源中的产品名与文件名。
- Flutter：`pubspec.yaml` 包名、`package:` imports、ARB 的 `appTitle`。
- VS Code：如果 `.vscode/launch.json` 已存在，自动更新启动配置名；脚本不会主动创建本地 IDE 配置。

脚本默认不直接修改 `lib/core/l10n/gen/` 下的国际化生成物。修改 ARB 后需要重新生成：

```bash
./script/gen_l10n.sh
```

执行后建议检查：

```bash
flutter pub get
./script/gen_l10n.sh
flutter analyze
flutter test
```

以下平台或发布配置仍建议人工复核：

- macOS / Windows 的公司名、版权等发布主体元数据
- App 图标、启动图、商店展示名称等品牌资源
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

### 配置深链和外链

模板在 App 层统一接收 App Scheme、Universal Links、Android App Links 和外部网页链接。
页面不需要自行解析 URL。每个允许被外部打开的 `AppPageRoute` 必须显式覆盖
Deep Link 目标由 App 组合层显式注册。链接的 path 和 query 会统一转换为
`AppNavigationCommand`，页面只通过 `AppRouteState` 读取自己需要的参数，未知参数忽略。

Deep Link 实现位于独立 package `packages/app_deep_link/`，当前模板的
`lib/integrations/deep_link_host/` 只负责把 package 解析结果适配为本项目的认证、导航和
WebView 行为。它属于可选的外部集成能力，不属于 `lib/features/` 业务 Feature。
未装配时不启动平台链接监听，也不影响普通路由和登录流程。

需要 Deep Link 的项目保留主工程中的 path dependency 和宿主适配层；不需要 Deep Link 的
项目可以移除 `app_deep_link` dependency、`lib/integrations/deep_link_host/` 以及对应的
环境配置。package 不依赖 `AppPageRoute`、Riverpod 或 GoRouter，业务路由由宿主转换为
`DeepLinkRoute` 后注册。

在各环境的 `EnvConfig` 中填写可选的 Deep Link 配置：

```dart
const EnvConfig(
  deepLinkConfig: DeepLinkConfig(
    appScheme: 'replace_me',
    appLinkHost: 'links.example.com',
  ),
)
```

系统是否将 HTTPS 链接交给 App，由 Android App Links 和 iOS Universal Links 的原生关联
配置决定。App 收到链接后按 path 分发；网页统一使用 `/web?url=...`，不会再单独配置网页
host 白名单或认证网页入口。

配置 Android App Links 前，需要在关联域名部署 `/.well-known/assetlinks.json`，内容必须匹配 application ID 和
发布签名证书 SHA-256。iOS 需要为 Runner 配置 Associated Domains，并在关联域名部署
`apple-app-site-association`，内容必须匹配 Team ID、Bundle ID 和允许路径。

原生配置不需要手动维护。Deep Link 默认关闭，`config/deep_links.json` 是可选配置源。
需要启用时，先复制 `config/deep_links.json.example` 为 `config/deep_links.json`，填写各环境值，
再按环境执行：

```bash
dart run script/configure_links.dart --env dev
flutter build apk -t lib/main_dev.dart
```

如果 `config/deep_links.json` 不存在，脚本会清理旧的原生 Deep Link 配置并正常退出。
配置存在但格式或值非法时，脚本会报错。有效配置时，脚本会生成 `android/deep_links.properties` 和
`ios/Flutter/DeepLinks.generated.xcconfig`，这两个文件已加入 `.gitignore`，由 Android
Gradle 和 iOS xcconfig 自动读取。CI 应在构建前执行对应环境的生成命令，并使用
`--check` 检查生成文件以及 Android/iOS 原生标记块没有被手工修改或过期；不同环境必须分别执行脚本。

链接解析失败只返回分类错误，不自动回首页、不自动打开任意网页；产品层可以通过
`DeepLinkResolution` 的失效原因决定后续展示策略。

---

## ➕ 新增业务 Feature

模板采用 Feature-First + Clean Architecture。新增业务模块时，推荐在 `lib/features/` 下创建独立目录。

模板已内置 `todo` 示例 Feature，可作为复杂业务模块的完整分层参考：

```text
lib/features/todo/
├── todo_feature.dart
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

该示例演示了本地内存数据源、Repository 抽象、ViewModel 状态管理、页面交互、路由注册和默认根 Tab 入口。纯展示页、设置页、Profile 这类只读取少量全局 Provider 或只有简单点击回调的页面，可以使用更薄的结构，不要机械创建空 `ViewModel`、空 `State`、空 `data` 或空 `domain` 目录。

以 `order` 模块为例：

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

分层职责：

| 层级 | 职责 |
| --- | --- |
| `presentation` | 页面、ViewModel、路由定义、UI 状态 |
| `domain` | 业务实体、Repository 抽象与抽象 Provider |
| `data` | DataSource、Repository 实现、接口数据转换 |

简单页面可以只保留页面与路由：

```text
lib/features/profile/
├── profile_feature.dart
└── presentation/
    ├── pages/profile_page.dart
    └── profile_routes.dart
```

推荐调用链：

```text
OrderPage
  ↓ 用户交互
OrderViewModel
  ↓ 调用抽象
orderRepositoryProvider / OrderRepository
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

import '../../../core/router/router.dart';
import 'pages/order_page.dart';

final class OrderRoute extends AppPageRoute {
  const OrderRoute();

  @override
  String get path => '/order';

  @override
  bool get public => false;

  @override
  Widget buildPage(BuildContext context, AppRouteState state) {
    return const OrderPage();
  }
}
```

`public` 含义：

| 值 | 说明 |
| --- | --- |
| `true` | 公开页面，未登录也可以访问 |
| `false` | 受保护页面，未登录会跳转到登录页 |

公开路由按 `path` 模式匹配，支持 `/article/:id` 这类动态路径。只要 Route 本身声明 `public = true`，实际访问 `/article/42` 也会被放行。

### 2. 在 Feature 中暴露路由

新增 `lib/features/order/order_feature.dart`：

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/feature/app_feature.dart';
import '../../core/feature/app_feature_metadata.dart';
import '../../core/router/router.dart';
import 'data/datasources/order_datasource.dart';
import 'data/repositories/order_repository_impl.dart';
import 'domain/repositories/order_repository.dart';
import 'presentation/order_routes.dart';

final class OrderFeature extends AppFeature {
  const OrderFeature();

  @override
  AppFeatureMetadata get metadata => const AppFeatureMetadata(
    key: 'order',
    priority: 400,
    enabledEnvironments: <EnvTag>{EnvTag.dev, EnvTag.sit, EnvTag.prod},
    permissions: <String>{'order.read'},
  );

  @override
  List<AppPageRoute> get routes => const [OrderRoute()];

  @override
  List<Override> get providerOverrides {
    return <Override>[
      orderRepositoryBindingProvider.overrideWith(
        (ref) => OrderRepositoryImpl(ref.watch(orderDataSourceProvider)),
      ),
    ];
  }
}
```

如果该 Feature 需要作为底部 Tab 入口，再额外覆盖 `tabs` 并返回 `AppTabEntry`。默认没有 Tab 的 Feature 只需要暴露 `routes`。Repository 的默认 data 实现在 `XxxFeature.providerOverrides` 中装配，ViewModel 仍只依赖 domain 抽象 Provider，不直接 import data 层。

`metadata.key` 在 App 内必须唯一；`priority` 越小越靠前，相同时按 key 排序。`enabledEnvironments` 声明允许启用的环境，默认覆盖 dev、sit、prod。`permissions` 只记录业务权限 key，不执行鉴权；`experimental` 只作为实验功能标识。

### 3. 注册到 Feature 汇聚入口

打开 `lib/features/features.dart`，补充 import 与 `appFeatures` 注册项：

```dart
import 'order/order_feature.dart';

const List<AppFeature> appFeatures = [
  AuthFeature(),
  TodoFeature(),
  ProfileFeature(),
  OrderFeature(),
];
```

`Application.run()` 会按 `EnvConfig.envTag` 从 `appFeatures` 构建一次 `AppFeatureRegistry`。`lib/app/navigation/app_router_config.dart` 和根 `ProviderScope` 共同消费该注册表的 routes、tabs 与 provider overrides。注册表会在启动时校验 Feature key、route path、Tab key 唯一，并校验 Tab route 由所属 Feature 声明。通常新增业务 Feature 时不需要修改 `core/router/router_provider.dart` 或 App 启动入口。

如果 route class 或公开类型需要给业务页面通过 `header.dart` 使用，在 `lib/features/exports.dart` 补充导出：

```dart
export 'order/presentation/order_routes.dart';
```

如果项目删除所有底部 Tab，模板不会创建 `/` 的 Root redirect 和 Shell；此时需要保留一个明确首页路由，或在 App 启动跳转逻辑中指定登录后的目标页。

### 4. 在页面中导航

Presentation/Page 层建议依赖 `BaseNavigator` 抽象，并传入 route 的 `location`，而不是直接依赖 GoRouter：

```dart
import 'package:my_app/header.dart';

ref.read(appRouterProvider).push(const OrderRoute().location);
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

final orderDataSourceProvider = Provider<OrderDataSource>((ref) {
  return OrderDataSource(ref.watch(httpClientProvider));
});
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

Repository 抽象 Provider 建议定义在 domain 层：

```dart
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return ref.watch(orderRepositoryBindingProvider);
});

final orderRepositoryBindingProvider = Provider<OrderRepository>((ref) {
  throw StateError('orderRepositoryBindingProvider must be overridden by OrderFeature.');
});
```

### 4. 在 ViewModel 中更新页面状态

```dart
import '../../domain/repositories/order_repository.dart';

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

final class OrderViewModel extends BaseAutoDisposeVM<OrderState> {
  @override
  OrderState initialState() => const OrderState();

  Future<void> loadOrders() async {
    final orders = await ref.read(orderRepositoryProvider).fetchOrders();
    state = state.copyWith(initialized: true, orders: orders);
  }
}

final orderViewModelProvider = AutoDisposeNotifierProvider<OrderViewModel, OrderState>(
  OrderViewModel.new,
);
```

`BaseAutoDisposeVM` 适合只服务当前页面的状态，最后一个监听者移除后会由 Riverpod 自动销毁；如果状态需要跨页面保留，改用 `BaseVM` 并配套 `NotifierProvider`。

由页面逻辑决定何时触发首屏加载：

```dart
final class OrderPageLogic extends PageLogic {
  @override
  void onReady() {
    unawaited(loadOrders());
  }

  Future<void> loadOrders() {
    return presentation.runWithLoading(
      () => ref.read(orderViewModelProvider.notifier).loadOrders(),
      rethrowError: false,
    );
  }
}

final class OrderPage extends BasePage {
  const OrderPage({super.key});

  @override
  PageLogic createPageLogic() => OrderPageLogic();

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
AuthException（失败时）
  ↓
AuthViewModel 映射国际化文案
  ↓
AuthViewModel 通过 AuthSessionController 写入 authSessionProvider
  ↓
AuthStore 持久化
  ↓
RouterGuard / AuthInterceptor 生效
```

接入真实登录通常只需要改三处：

### 1. 修改登录接口路径

在 Auth DataSource 中替换真实接口路径和参数结构。

### 2. 修改响应解析

将后端返回的 token、refreshToken、用户信息转换成 `AuthSession`。认证失败或响应结构异常时，Repository 抛 `AuthException` 的具体子类，不向 domain 接口传入 UI 兜底文案；页面文案由 `AuthViewModel` 基于异常类型映射国际化资源。`AuthRepositoryImpl` 只负责返回 `AuthSession`，不要直接写 `authSessionProvider`。

### 3. 确认退出登录逻辑

退出登录时清空本地会话：

```dart
await ref.read(authSessionControllerProvider).clearSession();
```

`authRepositoryProvider` 位于 Auth domain 层，默认由 App 组合层注入 `AuthRepositoryImpl`。`authSessionControllerProvider` 位于 `shared/services/auth`，负责把 Repository 返回的 `AuthSession` 写入唯一登录态状态源；页面或 ViewModel 不需要 import data 层实现。

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

## 📦 构建发布包

模板提供 Android 与 iOS 发布构建脚本。脚本会优先使用本机 `fvm flutter`，未安装 FVM 时使用全局 `flutter`。

```bash
# 构建 Android APK，默认输出 apk
./script/build_android.sh

# 构建 Android AAB
./script/build_android.sh aab

# 构建 iOS IPA
./script/build_ios.sh
```

构建脚本会执行：

- `flutter pub get`
- release 构建
- `--obfuscate`
- `--split-debug-info=app_release_packages/<platform>/<version>/symbols`

产物与符号文件默认归档到：

| 平台 | 发布产物 | Dart 混淆符号 | 附加符号文件 |
| --- | --- | --- | --- |
| Android | `app_release_packages/android/<version>/<app_name>_v<version>_release.apk` 或 `.aab` | `app_release_packages/android/<version>/symbols/` | `mapping.txt`、`native-debug-symbols.zip`（如存在） |
| iOS | `app_release_packages/ios/<version>/<app_name>_v<version>_release.ipa` | `app_release_packages/ios/<version>/symbols/` | `dSYMs/`（如存在） |

Android 构建前会执行 `flutter clean`，并在构建完成后校验发布产物和 Dart `.symbols` 文件是否存在。iOS 构建会在存在归档 dSYM 时复制 `dSYMs`，并在缺少 `objective_c.framework.dSYM` 且 framework binary 存在时用 `dsymutil` 补齐。

脚本不负责配置 Android keystore、Apple 证书、Provisioning Profile 或商店发布参数。接入真实项目后，应先完成对应平台签名配置，再运行发布构建脚本。

---

## 🌐 打开通用网页

模板内置通用 WebView 页面，位于 `lib/shared/webview/`，并由 App 路由组合层注册为公共路由。它属于跨业务复用能力，不作为独立业务 Feature：

| 路由 | 登录要求 | 适用场景 |
| --- | --- | --- |
| `WebPageRoute` | 无需登录 | 隐私政策、用户协议、帮助页 |
| `AuthWebPageRoute` | 需要登录 | 业务 H5、会员页、订单页 |

快速打开网页：

```dart
ref.read(appRouterProvider).push(
  const WebPageRoute(
    url: 'https://example.com/privacy',
    title: '隐私政策',
  ).location,
);
```

复杂配置通过 `extra` 传入 `WebPageConfig`：

```dart
ref.read(appRouterProvider).push(
  const AuthWebPageRoute().location,
  extra: const WebPageConfig(
    url: 'https://example.com/member',
    title: '会员中心',
    allowedHosts: ['example.com'],
    headers: {'X-App-Source': 'flutter'},
    showToolbarActions: true,
  ),
);
```

安全策略：

- 仅允许 `http/https` 地址。
- 未传 `allowedHosts` 时允许任意 `http/https`。
- 传入 `allowedHosts` 后只允许匹配白名单 host。
- `tel:`、`mailto:`、支付或地图等三方 scheme 默认拦截；如需外部 App 唤起，可后续接入 `url_launcher`。

---

## ✅ 常见开发约定

### 推荐做法

- 一个业务模块对应一个 `Feature` 目录。
- 页面继承 `BasePage`，负责 UI 结构、Widget 组合、布局和样式。
- `PageLogic` 是按需页面逻辑层；页面本地 `TextEditingController`、`FocusNode`、`ScrollController`、临时交互状态、生命周期、首帧副作用和页面级 UI 副作用可放入 `PageLogic`。
- 纯展示页面、简单 Provider 渲染页面或只有少量点击回调的页面，可以不创建 `PageLogic`。
- ViewModel / Notifier 负责页面可观察状态、业务动作编排，以及把领域/服务状态转换成 UI 状态。
- ViewModel 只依赖 Repository 抽象，不直接依赖 HTTP 客户端，也不管理页面生命周期。
- 简单页面不要机械创建空 ViewModel、空 State 或空分层目录。
- RepositoryImpl 负责把接口数据转换成业务实体。
- 公共 UI 放到 `shared/widgets`。
- 公共业务服务放到 `shared/services`。
- 全局基础设施放到 `core`。
- 新增页面时先在 Feature 内定义 `AppPageRoute`，再通过 `XxxFeature` 注册到 `features/features.dart`。
- 业务页面需要使用的 route class 或公开类型通过 `features/exports.dart` 导出，再由 `header.dart` 汇总。
- App 级路由组合放在 `lib/app/navigation/app_router_config.dart`，不要在 `core/router` 中 import 具体 Feature。

### 避免做法

- 不要在 Page 中直接写接口请求。
- 不要在 Page 中直接读写 SharedPreferences 或 SecureStorage。
- 不要让一个 Feature 直接依赖另一个 Feature 的内部实现。
- 不要把页面级 `PageLogic` 当作跨模块公共 API。
- 不要用 `PageLogic` 替代 ViewModel 承载可观察业务状态、接口编排、跨页面状态或领域逻辑。
- 不要为了保持目录形式统一而创建空 ViewModel、空 State、空 Repository 或空 DataSource。
- 不要把具体业务逻辑放进 `core`。
- 不要绕过 `authSessionControllerProvider` 手动管理 token。
- 不要在多个状态管理方案之间混用。

---

## 🧪 接入业务后的建议检查

每次完成一个 Feature 后，建议执行：

```bash
flutter analyze
flutter test
```

如果修改了国际化、资源或平台配置，也建议重新运行 App 做一次手动验证。
