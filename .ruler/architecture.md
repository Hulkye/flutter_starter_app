# 架构规则

## 总体原则

- 使用 Feature-First 组织业务代码；`features/` 只承载业务功能域，不放通用页面能力。
- 复杂 Feature 内部优先保持 `data / domain / presentation` 三层结构；简单展示页或设置页可以只保留实际需要的 `presentation`、路由与 Feature 声明，不创建空分层。
- Clean Architecture 依赖方向为：`presentation -> domain <- data`。
- `core` 提供全局基础设施，不依赖具体 Feature。
- `core/config` 承载 App 环境配置，供 `main_*`、`app`、`core/network` 与业务页面读取；避免 `core` 反向依赖 `app`。
- `core/router` 不装配具体 App/Feature 路由；App 层通过 `AppRouterConfig` 注入路由图。
- `shared` 提供跨 Feature 可复用能力，不承载具体业务流程；较完整的通用能力可按能力名建目录，例如 `shared/webview/`；跨页面、跨模块的低频业务通知使用 `shared/services/event_bus`。

## Feature 内部分层

- `data/datasources/`：远程或本地数据源。
- `data/repositories/`：Repository 实现，负责数据转换、异常处理、数据源组合。
- `domain/entities/`：业务实体和值对象。
- `domain/exceptions/`：领域异常，表达业务失败语义，不携带 UI 文案兜底逻辑。
- `domain/repositories/`：Repository 抽象与抽象 Provider；公开 Provider 只暴露抽象，默认 data 实现通过 binding Provider 由 `XxxFeature.providerOverrides` 声明并由 App 组合层汇聚注入。
- `presentation/pages/`：页面与 UI 组合。
- `presentation/viewmodels/`：页面状态与业务动作。
- `presentation/<feature>_routes.dart`：当前 Feature 的路由定义。
- `<feature>_feature.dart`：当前 Feature 对 App 暴露的模块声明，包括路由、Tab 入口和默认 Provider 覆盖项。
- `lib/core/feature/`：定义 `AppFeatureMetadata` 与 `AppFeatureRegistry`；注册表统一负责环境筛选、稳定排序、冲突校验和 routes/tabs/provider overrides 派生。
- `lib/features/features.dart`：保留 App Feature 候选列表，并按 `EnvTag` 创建唯一注册表实例。
- `lib/features/exports.dart`：业务页面公共导出入口，只导出 route class 和明确需要跨模块使用的公开类型，避免通过 `header.dart` 暴露默认 data 装配。
- 简单页面不要为了保持目录形式统一而创建空 ViewModel、空 State、空 Repository、空 DataSource 或空目录。

## 跨 Feature 依赖边界

- 一个 Feature 的 `presentation` 不应直接依赖另一个 Feature 的 `presentation`、Page、Widget 或 ViewModel。
- ViewModel 是页面/Feature 表现层对象，不作为跨模块公共 API。
- 跨 Feature 调用应依赖稳定能力，例如：
  - `core` 中的全局服务或协议；
  - `shared` 中的跨业务服务；
  - domain repository 抽象；
  - Controller 或 Service 层能力；
  - 语义明确的 Riverpod Provider；
  - Feature 暴露的稳定 route class。

## 认证与会话示例

- 登录页可以使用 `AuthViewModel` 管理登录表单状态。
- Profile 页退出登录不应直接调用 `AuthViewModel`。
- `AuthRepositoryImpl` 只负责调用数据源、校验响应并返回 `AuthSession`，不直接写 `authSessionProvider`。
- 登录成功后的会话写入由 `AuthSessionController` 或共享会话服务负责，保持登录态单一状态源。
- 退出登录这类 App 级会话能力应通过 `AuthSessionController` 或共享服务暴露。
- 路由守卫只消费 App 组合层注入的 `RouteAccessDecision`，不直接枚举具体业务状态；
  登录、启动、升级、资料、权限和租户等状态由组合层按业务优先级解析为最终决策。

## MVVM 边界

- Page 负责 UI 结构、Widget 组合、布局、样式。
- PageLogic 是按需使用的页面本地逻辑层，负责当前页面私有的 controller、FocusNode、临时交互状态、生命周期和 UI 副作用，不作为跨页面公共 API。
- 纯展示页面、简单 Provider 渲染页面或只有少量点击回调的页面，不需要为了保持形式统一而创建空 PageLogic。
- PageLogic 可以调用 VM/Provider，但不承载可观察业务状态、接口编排、跨页面状态或领域逻辑；这些职责应放入 ViewModel、Service、Repository 或稳定 Provider。
- ViewModel / Notifier 负责页面可观察状态、业务动作编排、把领域/服务状态转换成 UI 状态，不持有 `BuildContext`，不直接调用一次性 UI 反馈服务。
- 没有可观察业务状态或动作编排的简单页面，不需要创建空 ViewModel / State。
- ViewModel 只 import domain 抽象、shared/core 服务或稳定 Provider，不直接 import `data/repositories` 或 `data/datasources`。
- Repository 负责业务数据获取与持久化抽象。
- DataSource 负责具体 API、本地缓存或 Mock 数据来源。
- 一次性 UI 反馈使用注入式 `PresentationFeedbackService`（`presentationFeedbackProvider`、`PageScope.presentation`、`PageLogic.presentation`）或专门事件机制，不污染长期可渲染状态。
