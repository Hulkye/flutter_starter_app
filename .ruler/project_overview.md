# 项目概览

## 定位

本项目是面向中大型 Flutter 应用的开箱即用模板，强调清晰分层、快速扩展和长期可维护性。

## 技术栈

- Flutter 3.x / Dart 3.x
- Riverpod 2.x：状态管理与依赖注入
- GoRouter：底层路由实现，但业务层通过 `core/router` 抽象访问
- Feature-First + Clean Architecture
- MVVM：`BasePage` + `PageLogic` + `BaseVM` + `BaseState` + `PresentationHelper`

## 重要目录

- `lib/app/`：应用启动、根组件、环境配置。
- `lib/core/`：全局基础设施，不承载具体业务。
- `lib/core/feature/`：`AppFeature` 模块协议。
- `lib/core/router/`：路由抽象、GoRouter 适配、Provider、守卫。
- `lib/features/`：业务功能模块，按 Feature 聚合。
- `lib/features/features.dart`：业务 Feature 注册与业务 Route class 统一导出入口。
- `lib/shared/`：跨 Feature 共享的基础表现层、服务与组件。
- `lib/header.dart`：业务常用统一导出。
- `docs/`：模板使用、测试与质量保障文档。

## 常用命令

- 获取依赖：`flutter pub get`
- 生成国际化：`./script/gen_l10n.sh`
- 格式检查：`dart format --set-exit-if-changed lib test script`
- 静态分析：`flutter analyze`
- 测试：`flutter test`

## 文档入口

- `README.md`：项目总览。
- `docs/template_usage.md`：模板使用说明。
- `docs/testing_quality.md`：测试与质量门禁。
- `lib/core/router/README.md`：路由模块说明。
- `assets/images/README.md`：图片资源规范。
