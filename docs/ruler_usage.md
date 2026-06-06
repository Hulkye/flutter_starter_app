# 🤖 Ruler AI 指令管理

本项目使用 [Ruler](https://github.com/intellectronica/ruler) 统一管理 AI Coding Assistant 指令。

Ruler 的目标是把 Copilot、Cursor、Claude Code、Codex 等工具的项目指令收敛到同一套源文件，避免多个 AI 配置文件长期手动维护导致规则漂移。

## 📁 目录结构

当前项目的 Ruler 源文件位于：

```text
.ruler/
├── AGENTS.md                         # 项目 AI 指令总入口
├── ruler.toml                        # Ruler 配置
├── project_overview.md               # 项目概览
├── architecture.md                   # 架构规则
├── flutter_conventions.md            # Flutter / Dart 约定
├── routing.md                        # 路由规则
├── state_management.md               # 状态管理规则
├── testing.md                        # 测试与质量规则
├── documentation.md                  # 文档维护规则
└── skills/
    ├── flutter-feature/
    │   └── SKILL.md                  # 新增/重构 Feature 工作流
    └── route-module/
        └── SKILL.md                  # 路由模块工作流
```

`.ruler/` 是人工维护的唯一源头，应纳入版本控制。

## 🎯 当前支持的 AI 工具

`ruler.toml` 当前启用：

```toml
default_agents = ["copilot", "cursor", "claude", "codex", "agentsmd"]
```

对应目标：

| Agent | 作用 |
| --- | --- |
| `copilot` | GitHub Copilot / VS Code Copilot 指令与技能分发 |
| `cursor` | Cursor 指令与技能分发 |
| `claude` | Claude Code 指令与技能分发 |
| `codex` | Codex CLI 指令与技能分发 |
| `agentsmd` | 生成根目录 `AGENTS.md`，兼容通用 Agent 读取 |

## 🔄 生成文件策略

Ruler 会根据 `.ruler/` 源文件生成不同 AI 工具的目标文件，例如：

```text
AGENTS.md
CLAUDE.md
.claude/skills/
.cursor/skills/
.codex/config.toml
.codex/skills/
```

这些生成文件不应手动修改，也不需要提交。项目通过 `.gitignore` 中的 Ruler 管理块忽略它们：

```text
# START Ruler Generated Files
...
# END Ruler Generated Files
```

如果需要修改 AI 指令，请修改 `.ruler/` 下的源文件，然后重新执行 `ruler apply`。

## 🧭 常用命令

预览 Ruler 将生成或修改的内容：

```bash
ruler apply --dry-run --verbose
```

正式应用：

```bash
ruler apply
```

只查看当前变更：

```bash
git status --short --ignored
```

## 🛠 维护规则

- 只维护 `.ruler/` 源文件。
- 不手动修改 `AGENTS.md`、`CLAUDE.md`、`.claude/skills/`、`.cursor/skills/`、`.codex/` 等生成文件。
- 修改 `.ruler/` 后，先运行 `ruler apply --dry-run --verbose` 预览。
- 预览无误后再运行 `ruler apply`。
- 提交时包含 `.ruler/` 源文件与 `.gitignore` 的 Ruler 管理块。
- 不提交 Ruler 生成文件。

## 🧾 任务完成输出约定

AI 完成一次用户任务后，应基于当前实际变动文件给出一条建议的 git commit 文本，便于开发者直接参考。

建议格式：

```text
<type>: <中文变更说明>
```

示例：

```text
docs: 补充Ruler指令管理说明
```

要求：

- commit 文本主体使用中文。
- 优先使用简洁的 Conventional Commits 风格。
- 文案必须匹配当前实际变动文件，不要给出与变更无关的描述。

## 🧩 技能说明

当前项目内置两个 Ruler Skill：

| Skill | 使用场景 |
| --- | --- |
| `flutter-feature` | 新增或重构业务 Feature，确保符合 Feature-First + Clean Architecture + MVVM |
| `route-module` | 新增、修改、审查或文档化路由、`AppFeature` 路由汇聚、导航与守卫 |

这些 Skill 会被分发到支持 Skill 的工具目录中，例如 `.claude/skills/`、`.cursor/skills/`、`.codex/skills/`。

## ⚠️ 注意事项

- 当前未启用 Ruler 的 MCP 分发能力：`[mcp].enabled = false`。
- 当前未启用 Ruler 的原生 subagents 分发能力：`[agents].enabled = false`。
- 如果后续新增 Cursor、Claude Code、Codex 的特定配置，优先通过 `.ruler/ruler.toml` 管理。
- 若 Ruler 版本升级导致生成路径变化，应同步检查 `.gitignore` 与本说明文档。
