# Skills Manager

> 一个强大的技能管理工具，支持 37+ AI 编码助手的跨平台技能共享与管理

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Skills CLI](https://img.shields.io/badge/skills-cli-blue.svg)](https://www.npmjs.com/package/@anthropics/skills-cli)

## 简介

Skills Manager 是一个用于管理 AI 编码助手技能的综合工具集。它不仅允许你将技能分发到所有支持的 AI 助手，还提供了完整的本地技能生命周期管理功能，包括创建、搜索、备份、列出和描述技能。

**核心价值：**
- **一次安装，到处使用**：将技能添加到 `.agents` 系统，自动映射到所有支持的 AI 助手
- **全生命周期管理**：提供创建、搜索、备份、删除等一站式管理工具
- **双模交互**：支持自然语言交互（通过 Claude Code）和命令行脚本调用
- **灵活配置**：支持本地路径、GitHub 仓库、Git URL，以及私有仓库访问

## 支持的 AI 助手 (37+)

- Claude Code, Codex, Cursor, Gemini CLI, Kiro, Trae
- Windsurf, Cline, CodeBuddy, CommandCode, Continue
- Crush, Droid, Goose, Junie, Kilo, Kode
- MCPJam, Mux, OpenCode, OpenHands, Pi, Qoder
- Qwen Code, Roo, Trae CN, Zencoder, OpenClaude
- Neovate, Pochi, Amp, Antigravity, Kimi CLI
- MoltBot, GitHub Copilot, and more...

## 安装

### 方式一：作为 Claude Code Skill 安装（推荐）

首先确保已安装此 skill 到 Claude Code，这样你就可以直接用自然语言管理技能：

```bash
# 方法一：直接从 GitHub 安装
npx skills add pxb988/skills-manager

# 方法二：从本地安装
npx skills add F:\Github\skills-manager
```

### 方式二：作为本地工具集使用

如果你更喜欢在终端直接运行脚本，可以将仓库克隆到本地：

```bash
# 下载脚本
git clone https://github.com/your-username/skills-manager.git
cd skills-manager

# 建议将 scripts 目录添加到你的 PATH 环境变量中
```

## 使用方式：自然语言交互（推荐）

安装后，**Skills Manager 作为一个 Skill**，让你能通过自然语言与 Claude Code 对话来管理所有技能。

#### 基本管理
- **添加技能**："添加 xyz-dl 这个技能" 或 "从 GitHub 添加 owner/repo"
- **列出技能**："列出所有已安装的技能"
- **搜索技能**："搜索跟 PDF 相关的技能"
- **描述技能**："描述一下 xyz-dl 这个技能是做什么的" 或 "给我介绍一下 skill-seekers 的功能"

#### 维护操作
- **创建技能**："创建一个名为 my-new-skill 的新技能模板"
- **备份技能**："备份所有技能" 或 "备份 xyz-dl 技能"
- **删除技能**："删除旧的 test-skill"
- **编辑技能**："编辑 skill-seekers 的描述"

## 使用方式：命令行脚本

除了自然语言，你也直接运行 `scripts/` 目录下的脚本。

### 1. 安装/添加技能 (`add-skill.sh`)

核心脚本，用于将技能安装到 `.agents` 系统并分发。

```bash
# 自动识别 GitHub 仓库、Git URL 或本地路径
add-skill.sh [OPTIONS] <source>
```

**示例：**
```bash
add-skill.sh anthropics/skills                  # GitHub 仓库
add-skill.sh ./my-custom-skill                  # 本地路径
add-skill.sh owner/repo --agent claude-code     # 仅安装到 Claude Code
add-skill.sh owner/repo --dry-run               # 预览模式
add-skill.sh private/repo --github-token <tok>  # 私有仓库
```

### 2. 技能管理工具 (PowerShell)

提供了丰富的 PowerShell 脚本用于日常维护。

#### 列出技能 (`list-skills.ps1`)
列出主技能目录和市场技能目录下的所有技能及其简介。
```powershell
.\scripts\list-skills.ps1
```

#### 搜索技能 (`search-skills.ps1`)
在技能名称、描述和内容中搜索关键词。
```powershell
.\scripts\search-skills.ps1 -Keyword "pdf"
```

#### 创建新技能 (`create-skill.ps1`)
快速生成包含标准 `SKILL.md` 的技能模版。
```powershell
.\scripts\create-skill.ps1 -Name "my-new-skill" -Description "这是一个测试技能" -Tags "test","demo"
```

#### 备份技能 (`backup-skill.ps1`)
将技能打包为 ZIP 文件。如果不指定名称，则备份所有技能。
```powershell
# 备份所有技能
.\scripts\backup-skill.ps1

# 备份特定技能
.\scripts\backup-skill.ps1 -Name "xyz-dl"
```

#### 描述技能 (`describe-skill.ps1`)
读取并展示技能的 `SKILL.md` 内容，帮助了解技能详情。
```powershell
.\scripts\describe-skill.ps1 -Name "skills-manager"
```

#### 删除技能 (`delete-skill.ps1`)
安全删除技能及其关联的符号链接（需小心使用）。
```powershell
.\scripts\delete-skill.ps1 -Name "unused-skill"
```

## 工作原理

Skills Manager 采用中心化存储策略：

1. **统一存储**：所有技能被安装到 `~/.agents/skills/<skill-name>/`。
2. **状态锁定**：`.skill-lock.json` 记录了每个技能的来源、版本和安装时间。
3. **智能分发**：脚本自动扫描系统中的 AI 助手目录（如 `~/.claude/skills`, `~/.cursor/skills` 等），并创建指向中心存储的符号链接。

这种设计确保了当你更新一个技能时，所有 AI 助手都能立即使用最新版本，且不会破坏各个助手原本的配置。

## 目录结构

```
~/.agents/
├── skills/
│   ├── skill-1/          # 实际技能存储位置
│   └── ...
└── .skill-lock.json      # 技能元数据记录
```

## 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

## 贡献

欢迎提交 Issue 和 Pull Request！我们尤其欢迎对更多 AI 助手的支持和新功能的建议。

## 致谢

- 灵感来自 [Skill Seekers](https://github.com/yusufkaraaslan/Skill_Seekers)
- 基于 [Anthropic Skills CLI](https://github.com/anthropics/skills) 规范