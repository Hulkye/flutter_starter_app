# 🧪 测试与质量保障

本项目内置基础测试与 CI 质量门禁，用于保障模板在扩展 Feature 后仍保持可运行、可分析、可验证。

## ✅ 本地检查命令

提交前建议依次执行：

```bash
flutter pub get
./script/gen_l10n.sh
dart format --set-exit-if-changed lib test script
flutter analyze
flutter test
```

## 🧱 测试分层

当前测试重点覆盖稳定且快速的单元/Provider/Widget 场景：

| 类型 | 说明 |
| --- | --- |
| 单元测试 | 纯 Dart 逻辑，例如 `EnvConfig`、Todo 数据源、Repository |
| Provider 测试 | Riverpod 状态与持久化，例如语言、主题、Todo ViewModel |
| Widget 测试 | App smoke test，验证核心页面可正常渲染 |

## 📁 测试目录

```text
test/
├── app/                         # 应用配置测试
├── core/                        # 核心能力测试：l10n、theme、router
├── features/                    # 业务 Feature 测试
├── helpers/                     # 测试辅助工具
└── widget_test.dart             # App smoke test
```

## 🚦 CI 质量门禁

GitHub Actions 工作流位于：

```text
.github/workflows/quality.yml
```

CI 会在 `push` 和 `pull_request` 时执行：

1. `flutter pub get`
2. `dart format --set-exit-if-changed lib test script`
3. `./script/gen_l10n.sh`
4. `git diff --exit-code`
5. `flutter analyze`
6. `flutter test`

其中 `./script/gen_l10n.sh + git diff --exit-code` 用于保证 ARB 文案和生成文件保持同步。

## ➕ 新增 Feature 后建议补充的测试

新增业务模块时，建议至少补充：

- DataSource 测试：数据源输入/输出是否符合预期
- Repository 测试：参数清洗、异常处理、实体转换
- ViewModel 测试：状态初始化、加载、提交、错误提示
- Widget smoke test：关键入口是否可见，主要交互是否可触发

以 Todo Feature 为例，已覆盖：

- 本地数据源初始数据、新增、切换、删除
- Repository 标题 trim 和空标题拒绝
- ViewModel 加载、新增、切换、删除、空输入提示

## ⚠️ 当前注意事项

`flutter analyze` 已配置为 CI 质量门禁的一环，当前项目无 analyzer 错误或警告。
