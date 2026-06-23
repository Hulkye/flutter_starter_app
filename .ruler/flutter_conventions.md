# Flutter 与 Dart 约定

## 代码风格

- 遵循项目 `analysis_options.yaml` 与 Dart 官方格式化。
- 新增 Dart 文件后使用项目既有 import 风格，避免无用 import。
- 优先使用 `const` 构造。
- Widget 保持职责单一，复杂 UI 拆分为私有 Widget 或 Feature 内组件。
- 不要在 Widget 中堆积复杂业务逻辑，业务动作放入 ViewModel、Service 或 Repository。

## Riverpod 使用

- 使用 Riverpod 统一状态管理和依赖注入。
- UI 读取状态使用 `ref.watch`。
- 触发动作使用 `ref.read(provider.notifier)` 或 `ref.read(serviceProvider)`。
- Provider 命名应语义明确，避免暴露实现细节。
- 测试需要替换依赖时优先使用 `ProviderScope.overrides`。

## 页面与 ViewModel

- 页面优先继承/复用 `BasePage` 体系，Page 负责 UI 结构、Widget 组合、布局、样式。
- `PageLogic` 是可选页面逻辑层；仅当页面需要 `TextEditingController`、`FocusNode`、`ScrollController`、临时交互状态、页面生命周期、首帧副作用或页面级导航/弹窗编排时，才覆盖 `createPageLogic()`。
- 纯展示页面、简单 Provider 渲染页面或只有少量点击回调的页面，可以直接在 `page(scope)` 中使用 `ref.watch` / `ref.read`，不要机械创建空 PageLogic。
- 页面中通过 `scope.logic<XxxPageLogic>()` 访问页面逻辑；PageLogic 应保持页面私有，不要作为跨模块公共 API，也不要替代 ViewModel 承载可观察业务状态。
- ViewModel / Notifier 优先继承/复用 `BaseVM` 体系，负责页面可观察状态、业务动作编排、把领域/服务状态转换成 UI 状态。
- State 建模要显式，例如 `loading`、`initialized`、`errorMessage`、`items`。
- 不要把 Toast、Loading、导航结果等一次性事件长期保存在 State 中。

## 资源规范

- 默认/亮色图片资源放在 `assets/images/` 根目录。
- 暗色资源放在 `assets/images/dark/`。
- 不需要单独维护 `assets/images/light/`。
- 修改资源目录规范时同步检查 `assets/images/README.md`。

## 导出规范

- 业务通用/常用能力优先通过 `lib/header.dart` 暴露。
- Feature route class 通过 `<feature>_feature.dart` export，再由 `features/features.dart` 汇总，最后由 `header.dart` 暴露。
- 不要为了使用某个业务路由在多个页面重复 import 深层 route 文件。
