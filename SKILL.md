---
name: skills-manager
description: 管理 Claude Code 本地技能的工具。支持列出、查看、创建、删除、编辑、备份、搜索和描述 skills。
tags:
  - skills
  - management
  - cli
  - utilities
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
license: MIT
custom_instructions: |
  # Skills Manager - Claude Code 技能管理器

  ## 触发条件
  当用户需要管理本地 skills 时使用此技能，包括但不限于：
  - 添加技能到 .agents 系统
  - 列出已安装的 skills
  - 查看 skill 的详细信息
  - 创建新的 skill
  - 删除/卸载 skill
  - 编辑现有 skill
  - 备份/恢复 skill
  - 搜索 skills
  - **描述/生成 skill 的功能说明**

  ## 添加技能实现细节

  当用户要求添加技能时，按以下步骤执行：

  ### 1. 解析源类型
  ```bash
  # 检测输入类型
  if [[ "$source" =~ ^[a-zA-Z0-9_-]+/[a-zA-Z0-9_-]+$ ]]; then
    # GitHub shorthand: owner/repo
    source_type="github"
    repo_url="https://github.com/$source"
  elif [[ "$source" =~ ^https?:// ]] || [[ "$source" =~ ^git@ ]]; then
    # Git URL
    source_type="git"
    repo_url="$source"
  else
    # Local path
    source_type="local"
    local_path="$source"
  fi
  ```

  ### 2. 获取技能名称
  ```bash
  # 读取 SKILL.md 中的 name 字段
  skill_name=$(grep "^name:" "$source/SKILL.md" | head -1 | sed 's/name: //' | tr -d '"')
  ```

  ### 3. 安装到 .agents
  ```bash
  agents_dir="$HOME/.agents"
  agents_skills_dir="$agents_dir/skills"
  skill_dest="$agents_skills_dir/$skill_name"

  # 创建目录
  mkdir -p "$agents_skills_dir"

  if [ "$source_type" = "local" ]; then
    # 复制本地技能
    cp -r "$local_path" "$skill_dest"
  elif [ "$source_type" = "github" ] || [ "$source_type" = "git" ]; then
    # 克隆 git 仓库
    git clone --depth 1 "$repo_url" "$skill_dest"
  fi
  ```

  ### 4. 更新 .skill-lock.json
  ```bash
  lock_file="$agents_dir/.skill-lock.json"
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")

  # 读取现有配置
  if [ -f "$lock_file" ]; then
    existing=$(cat "$lock_file")
  else
    existing='{"version":3,"skills":{},"dismissed":{}}'
  fi

  # 添加新技能记录 (使用 jq 或手动 JSON 操作)
  # ...
  ```

  ### 5. 检测 AI 助手并创建符号链接
  ```bash
  # 支持的 AI 助手目录映射
  declare -A agent_dirs=(
    ["claude-code"]="$HOME/.claude/skills"
    ["codex"]="$HOME/.codex/skills"
    ["cursor"]="$HOME/.cursor/skills"
    ["gemini-cli"]="$HOME/.gemini/skills"
    ["kiro-cli"]="$HOME/.kiro/skills"
    ["trae"]="$HOME/.trae/skills"
    ["windsurf"]="$HOME/.codeium/windsurf/skills"
    # ... 更多助手
  )

  # 为每个助手创建目录和符号链接
  for agent in "${!agent_dirs[@]}"; do
    agent_skill_dir="${agent_dirs[$agent]}"
    mkdir -p "$agent_skill_dir"
    ln -sf "$skill_dest" "$agent_skill_dir/$skill_name"
  done
  ```

  ## 技能目录结构

  Claude Code skills 存储在：
  - **主技能目录**: `%USERPROFILE%\.claude\skills\`
  - **市场技能目录**: `%USERPROFILE%\.claude\plugins\marketplaces\anthropic-agent-skills\skills\`

  ## 标准 Skill 结构

  ```
  skill-name/
  ├── SKILL.md              # 必需 - 技能定义文件
  ├── README.md            # 可选 - 额外文档
  ├── LICENSE.txt          # 可选 - 许可证文件
  ├── assets/              # 可选 - 资源文件
  ├── references/          # 可选 - 参考资料
  └── scripts/             # 可选 - 脚本文件
  ```

  ## SKILL.md 文件格式

  每个 skill 的 `SKILL.md` 必须包含 YAML 前置元数据：

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
  license: 许可证信息
  ---
  ```

  ## 常用操作命令

  ### 列出所有 Skills
  ```bash
  # 列出主技能目录
  ls -la "$HOME/.claude/skills"

  # 列出市场技能目录
  ls -la "$HOME/.claude/plugins/marketplaces/anthropic-agent-skills/skills"

  # 同时列出两个目录
  ls -la "$HOME/.claude/skills" && echo "---" && ls -la "$HOME/.claude/plugins/marketplaces/anthropic-agent-skills/skills"
  ```

  ### 查看 Skill 详情
  ```powershell
  # 读取 SKILL.md
  Get-Content $env:USERPROFILE\.claude\skills\<skill-name>\SKILL.md
  ```

  ### 创建新 Skill
  ```powershell
  New-Item -ItemType Directory -Path "$env:USERPROFILE\.claude\skills\<new-skill-name>"
  ```

  ### 删除 Skill
  ```powershell
  Remove-Item -Recurse -Force "$env:USERPROFILE\.claude\skills\<skill-name>"
  ```

  ### 搜索 Skills
  ```bash
  # 在主目录搜索
  ls "$HOME/.claude/skills" | grep -i "<keyword>"

  # 在市场目录搜索
  ls "$HOME/.claude/plugins/marketplaces/anthropic-agent-skills/skills" | grep -i "<keyword>"

  # 同时搜索两个目录
  (ls "$HOME/.claude/skills"; ls "$HOME/.claude/plugins/marketplaces/anthropic-agent-skills/skills") | grep -i "<keyword>"
  ```

  ### 备份 Skill
  ```powershell
  Compress-Archive -Path "$env:USERPROFILE\.claude\skills\<skill-name>" -DestinationPath "<backup-path>.zip"
  ```

  ### 添加技能到 .agents 系统

  **推荐方式**: 使用官方 skills CLI
  ```bash
  npx skills add owner/repo
  npx skills add ./local-skill
  npx skills add https://github.com/owner/repo
  ```

  **替代方式**: 使用本 skill 提供的脚本 (支持更多选项)
  ```bash
  ~/.claude/skills/skills-manager/scripts/add-skill.sh [OPTIONS] <source>

  # 基本示例:
  add-skill.sh ./my-local-skill
  add-skill.sh owner/repo
  add-skill.sh https://github.com/owner/repo

  # 只安装到特定 AI 助手:
  add-skill.sh owner/repo --agent claude-code
  add-skill.sh ./skill --agent cursor

  # 预览模式 (不实际安装):
  add-skill.sh owner/repo --dry-run

  # 强制覆盖已存在的技能:
  add-skill.sh ./skill --force

  # 使用 GitHub token 访问私有仓库:
  add-skill.sh owner/private-repo --github-token ghp_xxx
  ```

  **命令行选项**:
  - `-a, --agent <name>` - 目标特定 AI 助手 (默认: all)
  - `--dry-run` - 预览更改而不实际安装
  - `--force` - 强制覆盖已存在的安装
  - `--github-token <token>` - GitHub token 用于私有仓库
  - `-h, --help` - 显示帮助信息

  **技能会被**: 复制/克隆到 `~/.agents/skills/<skill-name>/`，然后自动创建符号链接到所有 AI 助手目录

  **支持的源类型**:
  - `local`: 本地路径
  - `github`: owner/repo 格式
  - `git`: 任何 git URL

  ## 使用方式

  用户可以通过自然语言指令来管理 skills，例如：

  - "添加 skill-name 到 .agents 系统"
  - "从 ./my-skill 添加技能"
  - "从 GitHub 添加 owner/repo"
  - "列出所有已安装的 skills"
  - "查看 my-awesome-skill skill 的详细信息"
  - "创建一个名为 my-new-skill 的 skill"
  - "删除旧的 test-skill"
  - "备份所有 skills 到备份目录"
  - "搜索包含 'pdf' 关键字的 skills"
  - "编辑 skill-seekers 的描述"
  - **"描述 my-awesome-skill 这个 skill 是做什么的"**
  - **"给我介绍一下 skill-seekers 的功能"**
  - **"分析这个 skill 的用途和使用场景"**
  - **"为 my-skill 生成一个新的描述"**

  ## 添加技能 (Add)

  添加功能将技能安装到 `.agents` 系统并自动映射到所有检测到的 AI 助手：

  ### 工作流程

  1. **验证技能**: 检查源路径/仓库是否存在有效的 SKILL.md
  2. **安装到 .agents**: 复制/克隆技能到 `~/.agents/skills/<skill-name>/`
  3. **更新配置**: 在 `~/.agents/.skill-lock.json` 中记录技能元数据
  4. **检测 AI 助手**: 扫描系统中所有支持技能的 AI 编码助手
  5. **创建符号链接**: 为每个助手创建符号链接到 `~/.agents/skills/<skill-name>/`

  ### 支持的 AI 助手

  自动检测并支持以下 37+ AI 编码助手：
  - Claude Code (`~/.claude/skills/`)
  - Codex (`~/.codex/skills/`)
  - Cursor (`~/.cursor/skills/`)
  - Gemini CLI (`~/.gemini/skills/`)
  - Kiro (`~/.kiro/skills/`)
  - Trae (`~/.trae/skills/`)
  - Windsurf (`~/.codeium/windsurf/skills/`)
  - 以及 30+ 其他工具...

  ### .skill-lock.json 格式

  ```json
  {
    "version": 3,
    "skills": {
      "skill-name": {
        "source": "local|github|git",
        "sourceType": "local|github|git",
        "sourceUrl": "原始路径或 git URL",
        "skillFolderHash": "",
        "installedAt": "2026-01-31T12:00:00.000Z",
        "updatedAt": "2026-01-31T12:00:00.000Z"
      }
    },
    "dismissed": {}
  }
  ```

  ## 描述功能 (Describe)

  描述功能用于分析和解释某个 skill 的用途：

  1. **读取 skill 内容**: 读取目标 skill 的 SKILL.md 文件
  2. **分析功能**: 解析 description、tags、custom_instructions 等字段
  3. **生成描述**: 用自然语言向用户说明：
     - 这个 skill 是做什么的
     - 主要功能有哪些
     - 使用场景是什么
     - 需要哪些工具权限
     - 如何使用

  4. **更新描述**: 用户可以要求为 skill 生成新的描述内容

  ## 注意事项

  1. Skills 可能位于两个目录之一：
     - 主技能目录: `%USERPROFILE%\.claude\skills\`
     - 市场技能目录: `%USERPROFILE%\.claude\plugins\marketplaces\anthropic-agent-skills\skills\`
  2. 删除 skill 前请确认不再需要，或者已做好备份
  3. 编辑 SKILL.md 时确保 YAML 格式正确
  4. 创建新 skill 时至少需要包含 SKILL.md 文件
  5. 市场技能 (anthropic-agent-skills) 通常是只读的，修改后可能被覆盖
  6. 用户自定义技能建议存放在主技能目录 `%USERPROFILE%\.claude\skills\`

  ## 输出格式

  ### 技能列表
  - 技能名称
  - 来源目录 (主目录 / 市场目录)
  - 描述 (description)
  - 标签 (tags)
  - 文件路径

  ### 详细信息
  - 完整的 SKILL.md 内容
  - 目录结构
  - 相关文件列表

  ### 描述输出
  ```
  # Skill 名称: my-awesome-skill

  ## 功能说明
  [简洁描述这个 skill 做什么]

  ## 主要特性
  - 特性 1
  - 特性 2

  ## 使用场景
  [什么时候使用这个 skill]

  ## 所需工具
  - 工具1
  - 工具2

  ## 使用示例
  [示例用法]
  ```

metadata:
  trigger: 用户需要管理本地 Claude Code skills 时
  source: Custom skill for managing local Claude Code skills
  version: 1.0.0
---

# Skills Manager

这是一个用于管理 Claude Code 本地技能的工具。

## 功能

- **添加技能**: 将技能添加到 .agents 系统，自动映射到所有 AI 助手
- **列出技能**: 显示所有已安装的 skills 及其基本信息
- **查看详情**: 查看某个 skill 的完整信息和内容
- **创建技能**: 快速创建新的 skill 模板
- **删除技能**: 安全地卸载不需要的 skills
- **编辑技能**: 修改现有 skill 的配置和内容
- **备份技能**: 导出技能存档
- **搜索技能**: 按名称或描述搜索 skills
- **描述技能**: 分析和解释 skill 的功能、用途和使用场景

使用时直接用自然语言描述你的需求即可，例如：
- "添加 skill-name 到 .agents 系统"
- "列出所有 skills"
- "创建一个新的 skill"
- "描述 my-awesome-skill 这个 skill"