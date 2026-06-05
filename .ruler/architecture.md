# 架构规则

## 总体原则

- 使用 Feature-First 组织业务代码。
- 每个 Feature 内部优先保持 `data / domain / presentation` 三层结构。
- Clean Architecture 依赖方向为：`presentation -> domain <- data`。
- `core` 提供全局基础设施，不依赖具体 Feature。
- `shared` 提供跨 Feature 可复用能力，不承载具体业务流程。

## Feature 内部分层

- `data/datasources/`：远程或本地数据源。
- `data/repositories/`：Repository 实现，负责数据转换、异常处理、数据源组合。
- `domain/entities/`：业务实体和值对象。
- `domain/repositories/`：Repository 抽象。
- `presentation/pages/`：页面与 UI 组合。
- `presentation/viewmodels/`：页面状态与业务动作。
- `presentation/<feature>_routes.dart`：当前 Feature 的路由定义。
- `<feature>_feature.dart`：当前 Feature 对 App 暴露的模块声明与路由导出。

## 跨 Feature 依赖边界

- 一个 Feature 的 `presentation` 不应直接依赖另一个 Feature 的 `presentation`、Page、Widget 或 ViewModel。
- ViewModel 是页面/Feature 表现层对象，不作为跨模块公共 API。
- 跨 Feature 调用应依赖稳定能力，例如：
  - `core` 中的全局服务或协议；
  - `shared` 中的跨业务服务；
  - domain repository 抽象；
  - application/service 层能力；
  - 语义明确的 Riverpod Provider；
  - Feature 暴露的稳定 route class。

## 认证与会话示例

- 登录页可以使用 `AuthViewModel` 管理登录表单状态。
- Profile 页退出登录不应直接调用 `AuthViewModel`。
- 退出登录这类 App 级会话能力应通过 `authSessionProvider`、`AuthService`、`SessionController` 或共享服务暴露。
- 路由守卫应监听稳定的会话状态，而不是页面 ViewModel。

## MVVM 边界

- Page 负责 UI 展示、生命周期桥接和用户交互入口。
- ViewModel 负责状态变更与业务动作，不持有 `BuildContext`。
- Repository 负责业务数据获取与持久化抽象。
- DataSource 负责具体 API、本地缓存或 Mock 数据来源。
- 一次性 UI 反馈使用 `PresentationHelper` 或专门事件机制，不污染长期可渲染状态。
