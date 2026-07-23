---
name: flutter-feature
description: "Use when: creating or refactoring a Flutter business Feature in this project, including Feature-First folders, Clean Architecture layers, MVVM ViewModel, routes, tests, and docs."
---

# Flutter Feature 工作流

当需要新增或重构业务 Feature 时，遵循本技能。

## 目标结构

复杂业务 Feature 使用完整分层；简单展示页或设置页只保留实际需要的页面、路由与 Feature 声明，不创建空目录或空 ViewModel。

```text
lib/features/<feature>/
├── <feature>_feature.dart
├── data/
│   ├── datasources/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── exceptions/
│   └── repositories/
└── presentation/
    ├── pages/
    ├── viewmodels/
    └── <feature>_routes.dart
```

## 步骤

1. 明确 Feature 的业务边界，避免把多个无关业务塞进同一模块。
2. 先设计 domain 抽象，再实现 data 层。
3. 在 domain 层暴露 Repository 抽象 Provider 与 binding Provider，在 `XxxFeature.providerOverrides` 中声明默认 data 实现，由 App 组合层汇聚注入，再暴露 ViewModel；跨模块或 App 级状态写入优先使用 shared/core 的 Controller 或 Service。
4. 页面使用 `BasePage` / `BaseVM` / `BaseAutoDisposeVM` 项目范式，并按需使用 `PageLogic`；只服务当前页面且无需跨页面保留状态的 ViewModel 优先使用 `BaseAutoDisposeVM`。
5. 在 `<feature>_routes.dart` 定义 `XxxRoute extends AppPageRoute`。
6. 在 `<feature>_feature.dart` 定义 `XxxFeature extends AppFeature`，暴露 routes、tabs 与 providerOverrides。
7. 如该 Feature 需要底部 Tab，在 `XxxFeature.tabs` 中返回 `AppTabEntry`。
8. 在 `features/features.dart` 注册该 Feature；如 route class 或公开类型需要给业务页面使用，在 `features/exports.dart` 导出。
9. 如该 Feature 是模板示例或公共流程，更新 `README.md` 或 `docs/template_usage.md`。
10. 运行 `flutter analyze`；涉及逻辑时补充/运行测试。

## 架构边界

- 不要直接依赖其他 Feature 的 ViewModel。
- 跨 Feature 能力通过 Service、Repository 抽象、Controller、Provider 或 route class 暴露。
- Page 负责 UI 结构、Widget 组合、布局、样式。
- PageLogic 是按需页面逻辑层，负责页面私有 controller、FocusNode、临时交互状态、生命周期、首帧副作用和页面级 UI 副作用。
- 纯展示页面、简单 Provider 渲染页面或只有少量点击回调的页面，不要机械创建空 PageLogic。
- 没有可观察业务状态或动作编排的简单页面，不要机械创建空 ViewModel / State。
- PageLogic 可以调用 VM/Provider，但不承载可观察业务状态、接口编排、跨页面状态或领域逻辑。
- ViewModel / Notifier 负责页面可观察状态、业务动作编排、把领域/服务状态转换成 UI 状态。
- ViewModel 不持有 `BuildContext`，不直接依赖 GoRouter。
- ViewModel 不直接 import `data/repositories` 或 `data/datasources`；presentation 只能依赖 domain 抽象 Provider、shared/core 服务或稳定 Provider。

## 输出检查

- Feature 目录是否符合分层。
- 是否注册到 `features/features.dart`。
- Repository 抽象 Provider 是否位于 domain，默认 data 实现是否通过 `XxxFeature.providerOverrides` override domain binding Provider 装配。
- 是否通过 `header.dart` 间接可用。
- 是否存在无用 import。
- 是否完成文档和测试检查。
