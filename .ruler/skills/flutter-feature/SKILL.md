---
name: flutter-feature
description: "Use when: creating or refactoring a Flutter business Feature in this project, including Feature-First folders, Clean Architecture layers, MVVM ViewModel, routes, tests, and docs."
---

# Flutter Feature 工作流

当需要新增或重构业务 Feature 时，遵循本技能。

## 目标结构

```text
lib/features/<feature>/
├── <feature>_feature.dart
├── data/
│   ├── datasources/
│   └── repositories/
├── domain/
│   ├── entities/
│   └── repositories/
└── presentation/
    ├── pages/
    ├── viewmodels/
    └── <feature>_routes.dart
```

## 步骤

1. 明确 Feature 的业务边界，避免把多个无关业务塞进同一模块。
2. 先设计 domain 抽象，再实现 data 层。
3. 使用 Riverpod 暴露 Repository、Service、ViewModel。
4. 页面使用 `BasePage` / `PageLogic` / `BaseVM` 项目范式。
5. 在 `<feature>_routes.dart` 定义 `XxxRoute extends AppPageRoute`。
6. 在 `<feature>_feature.dart` 定义 `XxxFeature extends AppFeature`，并 export route 文件。
7. 如该 Feature 需要底部 Tab，在 `XxxFeature.tabs` 中返回 `AppTabEntry`。
8. 在 `features/features.dart` 注册并导出该 Feature。
9. 如该 Feature 是模板示例或公共流程，更新 `README.md` 或 `docs/template_usage.md`。
10. 运行 `flutter analyze`；涉及逻辑时补充/运行测试。

## 架构边界

- 不要直接依赖其他 Feature 的 ViewModel。
- 跨 Feature 能力通过 Service、Repository 抽象、Controller、Provider 或 route class 暴露。
- Page 负责 UI 结构、Widget 组合、布局、样式。
- PageLogic 负责页面本地 controller、FocusNode、临时交互状态、生命周期、调用 VM/Provider。
- ViewModel / Notifier 负责页面可观察状态、业务动作编排、把领域/服务状态转换成 UI 状态。
- ViewModel 不持有 `BuildContext`，不直接依赖 GoRouter。

## 输出检查

- Feature 目录是否符合分层。
- 是否注册到 `features/features.dart`。
- 是否通过 `header.dart` 间接可用。
- 是否存在无用 import。
- 是否完成文档和测试检查。
