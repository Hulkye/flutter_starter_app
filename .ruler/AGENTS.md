# Flutter Starter App AI 指令

你正在协助维护一个 Flutter Starter App 模板项目。默认使用中文回复，保持结论明确、行动具体。

## 必须遵守

- 遵循 Feature-First + Clean Architecture + MVVM。
- 新增或修改业务模块时，优先保持 `data / domain / presentation` 分层。
- 不要让一个 Feature 的 `presentation` 直接依赖另一个 Feature 的 `presentation` 或 ViewModel。
- 跨 Feature 复用能力时，优先通过 `core`、`shared`、domain 抽象、application/service、Repository 抽象或稳定 Provider 暴露。
- 业务页面路由通过 `AppPageRoute` 定义，底部 Tab 入口通过 `AppTabEntry` 声明，并由 `XxxFeature extends AppFeature` 暴露到 `features/features.dart` 汇聚。
- 业务页面导航优先使用 `package:flutter_starter_app/header.dart` 中统一导出的路由与 `appRouterProvider`。
- 模板使用者的业务背景、业务术语和项目特殊约束优先维护在 `.ruler/project_profile.md`；不要为了补充业务介绍而改动模板通用规则。
- 如存在本地私有补充文件 `.ruler/local_profile.md`，可结合其中信息理解当前工作区，但不要要求提交该文件，也不要在其中记录密钥、Token、账号密码等敏感信息。
- 修改代码后优先运行 `flutter analyze`；涉及测试逻辑时补充或运行 `flutter test`。
- 修改项目结构、路由机制、模板用法、资源规范或公共组件后，同步检查并更新相关文档。
- 修改项目基建能力后，需判断现有 Ruler 规则是否仍准确；如影响 AI 协作方式、目录约定、开发流程、质量门禁或生成物管理，应同步优化 `.ruler/` 源指令。
- 当一次用户任务产生文件改动时，基于当前实际变动文件给出一条建议的 git commit 文本；未产生文件改动时不输出 commit 文本。

## 用户项目插槽

- `.ruler/project_profile.md` 是模板预留的业务信息插槽，clone 模板后通常只需要修改该文件来补充项目介绍。
- 模板通用规则文件（如 `architecture.md`、`routing.md`、`state_management.md`、`testing.md`）应保持稳定，除非业务项目确实改变模板架构约定。
- 理解需求时的优先级为：用户当前请求 > `.ruler/local_profile.md`（如存在）> `.ruler/project_profile.md` > 模板通用规则。
- 当业务插槽中的约束与模板通用规则冲突时，先指出冲突并询问用户是否需要调整模板规则。

## 不要做

- 不要在业务层直接 import `go_router`。
- 不要把一次性 UI 事件混入长期可渲染状态。
- 不要把页面级 ViewModel 当作跨模块公共 API。
- 不要手动修改由 Ruler 生成的目标指令文件；应修改 `.ruler/` 源文件后重新执行 `ruler apply`。

## 输出要求

- 仅当本次任务产生文件改动时，任务完成总结中包含“本阶段建议 commit 文本”。
- commit 文本主体使用中文，优先采用简洁的 Conventional Commits 风格，例如 `docs: 补充Ruler指令管理说明`。
- commit 文本应根据当前实际变动文件生成，不要给出与变更无关的描述。
