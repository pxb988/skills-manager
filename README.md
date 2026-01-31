# Skills Manager

> 一个强大的技能管理工具，支持 37+ AI 编码助手的跨平台技能共享

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Skills CLI](https://img.shields.io/badge/skills-cli-blue.svg)](https://www.npmjs.com/package/@anthropics/skills-cli)

## 简介

Skills Manager 是一个用于管理 AI 编码助手技能的工具。它允许你：

- **一次安装，到处使用**：将技能添加到 `.agents` 系统，自动映射到所有支持的 AI 助手
- **支持多种来源**：本地路径、GitHub 仓库、Git URL
- **灵活配置**：指定目标助手、预览模式、强制覆盖等
- **私有仓库支持**：使用 GitHub Token 访问私有技能仓库

## 支持的 AI 助手 (37+)

- Claude Code, Codex, Cursor, Gemini CLI, Kiro, Trae
- Windsurf, Cline, CodeBuddy, CommandCode, Continue
- Crush, Droid, Goose, Junie, Kilo, Kode
- MCPJam, Mux, OpenCode, OpenHands, Pi, Qoder
- Qwen Code, Roo, Trae CN, Zencoder, OpenClaude
- Neovate, Pochi, Amp, Antigravity, Kimi CLI
- MoltBot, GitHub Copilot, and more...

## 安装

### 方式一：使用官方 npm 包（推荐）

```bash
# 全局安装
npm install -g @anthropics/skills-cli

# 使用 npx（无需安装）
npx skills add owner/repo
```

### 方式二：使用本脚本

```bash
# 下载脚本
git clone https://github.com/your-username/skills-manager.git
cd skills-manager

# 赋予执行权限（Linux/macOS）
chmod +x scripts/add-skill.sh

# 添加到 PATH（可选）
export PATH="$PATH:$(pwd)/scripts"
```

## 使用方式

### 自然语言调用（推荐）

**Skills Manager 是一个 Claude Code Skill**，你可以直接用自然语言与 Claude Code 对话来使用它！

首先确保已安装此 skill 到 Claude Code：

```bash
# 方法一：直接从 GitHub 安装
npx skills add pxb988/skills-manager

# 方法二：从本地安装
npx skills add F:\Github\skills-manager
```

安装后，你可以直接用自然语言与 Claude Code 对话：

#### 基本用法示例

```
你: "帮我添加 xyz-dl 这个技能"

你: "从 GitHub 添加 anthropics/skills 这个仓库"

你: "把本地的 ./my-skill 添加到 .agents 系统"

你: "添加技能 owner/repo，但只安装到 Cursor"
```

#### 高级用法示例

```
你: "添加这个技能，但先预览一下会发生什么"
# Claude 会自动使用 --dry-run 模式

你: "强制重新安装 owner/repo 这个技能"
# Claude 会自动使用 --force 标志

你: "我有私有仓库 my-org/private-skill，帮我添加，token 是 ghp_xxx"
# Claude 会自动使用 --github-token

你: "列出所有已安装的技能"

你: "描述一下 xyz-dl 这个技能是做什么的"
```

#### Claude Code 如何理解你的请求

Claude Code 会解析你的自然语言请求，自动转换为对应的命令：

| 你的自然语言 | 自动执行的命令 |
|-------------|---------------|
| "添加技能 xyz-dl" | `add-skill.sh xyz-dl` |
| "只安装到 Cursor" | `add-skill.sh xyz-dl --agent cursor` |
| "先预览一下" | `add-skill.sh xyz-dl --dry-run` |
| "强制覆盖" | `add-skill.sh xyz-dl --force` |
| "私有仓库，token 是 xxx" | `add-skill.sh repo --github-token xxx` |

#### 支持的自然语言模式

- **添加技能**："添加"、"安装"、"从 GitHub 添加"、"把本地技能添加到"
- **指定目标**："只安装到"、"仅针对"、"只要助手"
- **预览模式**："预览"、"dry run"、"先看一下"
- **强制操作**："强制"、"覆盖"、"重新安装"
- **私有仓库**："私有"、"private"、"需要 token"

### 命令行调用

如果你想直接使用命令行脚本（不通过 Claude Code）：

```bash
add-skill.sh [OPTIONS] <source>
```

### 参数说明

| 参数 | 说明 |
|------|------|
| `source` | 技能来源（本地路径、owner/repo、Git URL） |

### 选项说明

| 选项 | 说明 |
|------|------|
| `-a, --agent <name>` | 目标特定 AI 助手（默认：all） |
| `--dry-run` | 预览更改而不实际安装 |
| `--force` | 强制覆盖已存在的安装 |
| `--github-token <token>` | GitHub token 用于访问私有仓库 |
| `-h, --help` | 显示帮助信息 |

### 支持的源类型

| 类型 | 格式 | 示例 |
|------|------|------|
| 本地路径 | 相对或绝对路径 | `./my-skill`, `/path/to/skill` |
| GitHub | `owner/repo` | `anthropics/skills` |
| Git URL | HTTPS 或 SSH | `https://github.com/owner/repo` |

## 使用示例

### 示例 1：从 GitHub 添加技能

```bash
# 添加公开仓库（简写）
add-skill.sh anthropics/skills

# 添加公开仓库（完整 URL）
add-skill.sh https://github.com/anthropics/skills

# 添加私有仓库
add-skill.sh my-org/private-skill --github-token ghp_xxxxxxxxxxxx
```

### 示例 2：从本地添加技能

```bash
# 添加本地技能目录
add-skill.sh ./my-custom-skill

# 添加绝对路径
add-skill.sh /path/to/my-skill
```

### 示例 3：指定目标助手

```bash
# 只安装到 Claude Code
add-skill.sh owner/repo --agent claude-code

# 只安装到 Cursor
add-skill.sh ./my-skill --agent cursor

# 只安装到 Windsurf
add-skill.sh owner/repo -a windsurf
```

### 示例 4：预览模式

```bash
# 预览将要执行的操作（不实际安装）
add-skill.sh owner/repo --dry-run
```

输出示例：
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
           Skills Manager - Add Skill to .agents
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[INFO] Source: anthropics/skills
[INFO] Type: github
[INFO] Target: all
[INFO] Mode: DRY-RUN (no changes will be made)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[1/3] [DRY-RUN] Would install skill from: anthropics/skills
[2/3] [DRY-RUN] Would update /Users/mason/.agents/.skill-lock.json
[3/3] [DRY-RUN] Would create symlinks:
[INFO] [DRY-RUN] Target: All agents (37 agents)
[INFO] [DRY-RUN]   Would link to: ~/.claude/skills/
[INFO] [DRY-RUN]   Would link to: ~/.codex/skills/
[INFO] [DRY-RUN]   Would link to: ~/.cursor/skills/
...
```

### 示例 5：强制覆盖

```bash
# 强制覆盖已存在的技能
add-skill.sh ./my-skill --force
```

### 示例 6：多技能仓库

当仓库包含多个技能时（`skills/` 目录下有多个子目录），脚本会提示你选择：

```bash
add-skill.sh multi-skills-repo

# 输出：
[INFO] This repository contains multiple skills:
  [1] skill-one
  [2] skill-two
  [3] skill-three

Select skill to install (1-3): 2
```

## 工作原理

### 安装流程

```
┌─────────────────────────────────────────────────────────────┐
│  1. 解析源类型                                               │
│     - local: 本地路径                                       │
│     - github: owner/repo 格式                               │
│     - git: 任何 Git URL                                     │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  2. 获取技能名称                                             │
│     - 读取 SKILL.md 中的 name 字段                          │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  3. 安装到 .agents 系统                                      │
│     - 复制/克隆到 ~/.agents/skills/<skill-name>/            │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  4. 更新 .skill-lock.json                                   │
│     - 记录技能元数据（来源、安装时间等）                     │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│  5. 创建符号链接                                             │
│     - 为每个 AI 助手创建符号链接                             │
│     - ~/.claude/skills/<skill-name> → ~/.agents/skills/...  │
└─────────────────────────────────────────────────────────────┘
```

### 目录结构

```
~/.agents/
├── skills/
│   ├── skill-1/          # 实际技能存储位置
│   │   └── SKILL.md
│   ├── skill-2/
│   │   └── SKILL.md
│   └── ...
└── .skill-lock.json      # 技能元数据
```

符号链接示例：
```
~/.claude/skills/skill-1 → ~/.agents/skills/skill-1
~/.cursor/skills/skill-1 → ~/.agents/skills/skill-1
~/.windsurf/skills/skill-1 → ~/.agents/skills/skill-1
```

### .skill-lock.json 格式

```json
{
  "version": 3,
  "skills": {
    "skill-name": {
      "source": "owner/repo",
      "sourceType": "github",
      "sourceUrl": "https://github.com/owner/repo",
      "skillFolderHash": "",
      "installedAt": "2026-01-31T12:00:00.000Z",
      "updatedAt": "2026-01-31T12:00:00.000Z"
    }
  },
  "dismissed": {}
}
```

## 技能规范

### 标准 Skill 结构

```
skill-name/
├── SKILL.md              # 必需 - 技能定义文件
├── README.md            # 可选 - 额外文档
├── LICENSE.txt          # 可选 - 许可证文件
├── assets/              # 可选 - 资源文件
├── references/          # 可选 - 参考资料
└── scripts/             # 可选 - 脚本文件
```

### SKILL.md 格式

```yaml
---
name: skill-name
description: 简短的技能描述
tags:
  - tag1
  - tag2
allowed-tools:
  - Read
  - Write
  - Bash
license: MIT
custom_instructions: |
  这里是技能的自定义指令...
---

# 技能名称

更详细的文档...
```

## 支持的 AI 助手完整列表

| 名称 | 技能目录 |
|------|---------|
| claude-code | `~/.claude/skills/` |
| codex | `~/.codex/skills/` |
| cursor | `~/.cursor/skills/` |
| gemini-cli | `~/.gemini/skills/` |
| kiro-cli | `~/.kiro/skills/` |
| trae | `~/.trae/skills/` |
| windsurf | `~/.codeium/windsurf/skills/` |
| cline | `~/.cline/skills/` |
| codebuddy | `~/.codebuddy/skills/` |
| command-code | `~/.commandcode/skills/` |
| continue | `~/.continue/skills/` |
| crush | `~/.config/crush/skills/` |
| droid | `~/.factory/skills/` |
| goose | `~/.config/goose/skills/` |
| junie | `~/.junie/skills/` |
| kilo | `~/.kilocode/skills/` |
| kode | `~/.kode/skills/` |
| mcpjam | `~/.mcpjam/skills/` |
| mux | `~/.mux/skills/` |
| opencode | `~/.config/opencode/skills/` |
| openhands | `~/.openhands/skills/` |
| pi | `~/.pi/agent/skills/` |
| qoder | `~/.qoder/skills/` |
| qwen-code | `~/.qwen/skills/` |
| roo | `~/.roo/skills/` |
| trae-cn | `~/.trae-cn/skills/` |
| zencoder | `~/.zencoder/skills/` |
| openclaude | `~/.openclaude/skills/` |
| neovate | `~/.neovate/skills/` |
| pochi | `~/.pochi/skills/` |
| amp | `~/.config/agents/skills/` |
| antigravity | `~/.gemini/antigravity/global_skills` |
| kimi-cli | `~/.config/agents/skills/` |
| moltbot | `~/.moltbot/skills/` |
| github-copilot | `~/.copilot/skills/` |

## 常见问题

### Q: 为什么技能被复制而不是创建符号链接？

A: `.agents` 系统的设计是集中管理技能的副本，这样：
- 技能独立存在，不受原始来源影响
- 可以修改技能而不影响源文件
- marketplace 技能更新时不会破坏已安装的版本

### Q: 如何卸载技能？

A: 删除 `.agents` 中的技能目录和所有符号链接：

```bash
# 删除技能
rm -rf ~/.agents/skills/skill-name

# 删除符号链接（需要手动或使用脚本）
find ~/.claude/skills ~/.cursor/skills ... -lname "*/.agents/skills/skill-name" -delete
```

### Q: 如何更新已安装的技能？

A: 使用 `--force` 标志重新安装：

```bash
add-skill.sh owner/repo --force
```

### Q: 私有仓库如何添加？

A: 使用 `--github-token` 选项：

```bash
add-skill.sh my-org/private-repo --github-token ghp_xxxxxxxxxxxx
```

## 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

## 贡献

欢迎提交 Issue 和 Pull Request！

## 致谢

- 灵感来自 [Skill Seekers](https://github.com/yusufkaraaslan/Skill_Seekers)
- 基于 [Anthropic Skills CLI](https://github.com/anthropics/skills) 规范
