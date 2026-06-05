# 测试与质量规则

## 本地质量门禁

提交前建议执行：

```bash
flutter pub get
./script/gen_l10n.sh
dart format --set-exit-if-changed lib test script
flutter analyze
flutter test
```

## 最低验证要求

- 修改 Dart 代码后至少运行 `flutter analyze`。
- 修改 ViewModel、Repository、DataSource 或核心逻辑后，优先补充或运行相关测试。
- 修改国际化资源后运行 `./script/gen_l10n.sh`，并检查生成文件差异。
- 修改格式相关内容后使用 Dart 格式化。

## 测试分层

- 单元测试：纯 Dart 逻辑、实体转换、参数校验、工具类。
- Provider 测试：Riverpod 状态、依赖替换、ViewModel 状态流转。
- Widget 测试：页面 smoke test、关键交互、空态/错误态展示。

## 新增 Feature 建议测试

- DataSource：输入输出、异常、Mock 数据。
- Repository：参数清洗、异常转换、实体转换。
- ViewModel：初始状态、加载成功、加载失败、提交动作、边界输入。
- Widget：关键入口可见，主要按钮可触发。

## CI 对齐

- CI 质量门禁见 `docs/testing_quality.md`。
- 不要为了让测试通过而删除有价值的断言。
- 不要忽略 analyzer warning；优先修复根因。
