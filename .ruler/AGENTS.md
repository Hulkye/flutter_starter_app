# Flutter Starter App AI 指令

你正在协助维护一个 Flutter Starter App 模板项目。默认使用中文回复，保持结论明确、行动具体。

## 必须遵守

- 遵循 Feature-First + Clean Architecture + MVVM。
- 新增或修改业务模块时，优先保持 `data / domain / presentation` 分层。
- 不要让一个 Feature 的 `presentation` 直接依赖另一个 Feature 的 `presentation` 或 ViewModel。
- 跨 Feature 复用能力时，优先通过 `core`、`shared`、domain 抽象、application/service、Repository 抽象或稳定 Provider 暴露。
- 业务路由通过 `AppRouteDefine` 定义，通过 `XxxFeature extends AppFeature` 暴露，并在 `features/features.dart` 汇聚。
- 业务页面导航优先使用 `package:flutter_starter_app/header.dart` 中统一导出的路由与 `appRouterProvider`。
- 修改代码后优先运行 `flutter analyze`；涉及测试逻辑时补充或运行 `flutter test`。
- 修改项目结构、路由机制、模板用法、资源规范或公共组件后，同步检查并更新相关文档。
- 每次完成用户任务后，基于当前实际变动文件给出一条建议的 git commit 文本。

## 不要做

- 不要在业务层直接 import `go_router`。
- 不要把一次性 UI 事件混入长期可渲染状态。
- 不要把页面级 ViewModel 当作跨模块公共 API。
- 不要手动修改由 Ruler 生成的目标指令文件；应修改 `.ruler/` 源文件后重新执行 `ruler apply`。

## 输出要求

- 任务完成总结中包含“本阶段建议 commit 文本”。
- commit 文本主体使用中文，优先采用简洁的 Conventional Commits 风格，例如 `docs: 补充Ruler指令管理说明`。
- commit 文本应根据当前实际变动文件生成，不要给出与变更无关的描述。
