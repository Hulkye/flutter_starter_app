# 状态管理规则

## Riverpod 基线

- Riverpod 是项目统一状态管理和依赖注入方案。
- Provider 负责暴露状态、服务、Repository 或基础设施能力。
- UI 层通过 `ref.watch` 订阅状态，通过 `ref.read` 触发动作。
- 可替换依赖应通过 Provider 暴露，便于测试覆盖。

## ViewModel 规则

- ViewModel 只服务所属页面或所属 Feature 的表现状态。
- ViewModel 不应作为跨 Feature 公共 API。
- ViewModel 不持有 `BuildContext`。
- ViewModel 不直接操作 Navigator；需要导航时通常由 Page 响应状态或事件后调用 `appRouterProvider`。
- ViewModel 调用 Repository 抽象或 Service，不直接堆积底层请求细节。

## State 建模

- State 是可渲染状态，应保持可预测、可序列化倾向和语义明确。
- 页面常用字段显式建模：`loading`、`initialized`、`errorMessage`、`items`、`selectedId`。
- 一次性 UI 事件不要长期放在 State 中。

## 跨模块状态

- 认证会话、主题、语言、网络状态等 App 级状态应放在 `core` 或 `shared` 的稳定 Provider/Service 中。
- 业务模块之间需要共享状态时，优先抽象为 Service、Repository、Controller 或明确的 Provider。
- 避免 `profile` 直接依赖 `auth` 的 `AuthViewModel` 这类 presentation 对象。

## 测试

- Provider 和 ViewModel 应优先通过 ProviderContainer 或 ProviderScope overrides 测试。
- 新增状态逻辑时，至少覆盖初始化、成功、失败和边界输入。
