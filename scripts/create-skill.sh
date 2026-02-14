#!/bin/bash
# skills-manager create-skill.sh
# 创建新的自定义技能并自动映射到所有 AI 助手

set -e

# 配置
AGENTS_DIR="$HOME/.agents"
AGENTS_SKILLS_DIR="$AGENTS_DIR/skills"
LOCK_FILE="$AGENTS_DIR/.skill-lock.json"

# OS 检测
detect_os() {
    case "$(uname -s)" in
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        Darwin*)               echo "macos" ;;
        *)                     echo "linux" ;;
    esac
}
OS_TYPE=$(detect_os)

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# 命令行参数默认值
SKILL_NAME=""
DESCRIPTION=""
TAGS="custom"
LICENSE="MIT"
TARGET_AGENT="all"

# 支持的 AI 助手目录映射
declare -A AGENT_DIRS=(
    ["claude-code"]="$HOME/.claude/skills"
    ["codex"]="$HOME/.codex/skills"
    ["cursor"]="$HOME/.cursor/skills"
    ["gemini-cli"]="$HOME/.gemini/skills"
    ["kiro-cli"]="$HOME/.kiro/skills"
    ["trae"]="$HOME/.trae/skills"
    ["windsurf"]="$HOME/.codeium/windsurf/skills"
    ["cline"]="$HOME/.cline/skills"
    ["codebuddy"]="$HOME/.codebuddy/skills"
    ["command-code"]="$HOME/.commandcode/skills"
    ["continue"]="$HOME/.continue/skills"
    ["crush"]="$HOME/.config/crush/skills"
    ["droid"]="$HOME/.factory/skills"
    ["goose"]="$HOME/.config/goose/skills"
    ["junie"]="$HOME/.junie/skills"
    ["kilo"]="$HOME/.kilocode/skills"
    ["kode"]="$HOME/.kode/skills"
    ["mcpjam"]="$HOME/.mcpjam/skills"
    ["mux"]="$HOME/.mux/skills"
    ["opencode"]="$HOME/.config/opencode/skills"
    ["openhands"]="$HOME/.openhands/skills"
    ["pi"]="$HOME/.pi/agent/skills"
    ["qoder"]="$HOME/.qoder/skills"
    ["qwen-code"]="$HOME/.qwen/skills"
    ["roo"]="$HOME/.roo/skills"
    ["trae-cn"]="$HOME/.trae-cn/skills"
    ["zencoder"]="$HOME/.zencoder/skills"
    ["openclaude"]="$HOME/.openclaude/skills"
    ["neovate"]="$HOME/.neovate/skills"
    ["pochi"]="$HOME/.pochi/skills"
    ["amp"]="$HOME/.config/agents/skills"
    ["antigravity"]="$HOME/.gemini/antigravity/global_skills"
    ["kimi-cli"]="$HOME/.config/agents/skills"
    ["moltbot"]="$HOME/.moltbot/skills"
    ["github-copilot"]="$HOME/.copilot/skills"
)

# 显示帮助信息
show_help() {
    echo -e "${CYAN}Skills Manager - Create Skill${NC}"
    echo ""
    echo "Usage: $0 -n <name> -d <description> [OPTIONS]"
    echo ""
    echo "Required:"
    echo "  -n, --name <name>          Skill name"
    echo "  -d, --description <desc>   Skill description"
    echo ""
    echo "Options:"
    echo "  -t, --tags <tags>          Comma-separated tags (default: custom)"
    echo "  -l, --license <license>    License type (default: MIT)"
    echo "  -a, --agent <name>         Target agent (default: all)"
    echo "  -h, --help                 Show this help message"
}

# 解析命令行参数
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -n|--name)        SKILL_NAME="$2"; shift 2 ;;
            -d|--description) DESCRIPTION="$2"; shift 2 ;;
            -t|--tags)        TAGS="$2"; shift 2 ;;
            -l|--license)     LICENSE="$2"; shift 2 ;;
            -a|--agent)       TARGET_AGENT="$2"; shift 2 ;;
            -h|--help)        show_help; exit 0 ;;
            *) log_error "未知参数: $1"; show_help; exit 1 ;;
        esac
    done
    if [ -z "$SKILL_NAME" ]; then log_error "缺少必需参数: -n/--name"; show_help; exit 1; fi
    if [ -z "$DESCRIPTION" ]; then log_error "缺少必需参数: -d/--description"; show_help; exit 1; fi
}

# 创建跨平台链接
create_link() {
    local source="$1"
    local target="$2"
    if [ "$OS_TYPE" = "windows" ]; then
        local win_source=$(cygpath -w "$source" 2>/dev/null || echo "$source" | sed 's|/|\\|g')
        local win_target=$(cygpath -w "$target" 2>/dev/null || echo "$target" | sed 's|/|\\|g')
        powershell.exe -NoProfile -Command "
            if (Test-Path '$win_target') { Remove-Item '$win_target' -Force -Recurse }
            New-Item -ItemType Junction -Path '$win_target' -Target '$win_source' | Out-Null
        " 2>/dev/null
    else
        ln -sf "$source" "$target" 2>/dev/null
    fi
}

# 生成 tags YAML 片段
generate_tags_yaml() {
    IFS=',' read -ra tag_array <<< "$TAGS"
    for tag in "${tag_array[@]}"; do
        local trimmed=$(echo "$tag" | xargs)
        echo "  - $trimmed"
    done
}

# 创建 SKILL.md 模板
create_skill_md() {
    local skill_path="$1"
    local tags_yaml=$(generate_tags_yaml)

    cat > "$skill_path/SKILL.md" << EOF
---
name: $SKILL_NAME
description: $DESCRIPTION
tags:
$tags_yaml
allowed-tools:
  - Bash
  - Read
  - Write
license: $LICENSE
custom_instructions: |
  # $SKILL_NAME

  ## 使用场景
  [描述什么时候使用这个 skill]

  ## 使用方式
  [描述如何使用这个 skill]

  ## 注意事项
  [列出使用时的注意事项]

metadata:
  trigger: [描述触发条件]
  source: Custom skill
  version: 1.0.0
---

# $SKILL_NAME

$DESCRIPTION

## 功能特性

- 特性 1
- 特性 2

## 使用方法

[详细说明使用方法]
EOF
}

# 更新 .skill-lock.json
update_lock_file() {
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
    local existing='{"version":3,"skills":{},"dismissed":{}}'
    [ -f "$LOCK_FILE" ] && existing=$(cat "$LOCK_FILE")

    if command -v node &> /dev/null; then
        node -e "
            const data = $existing;
            data.skills[process.argv[1]] = {
                source: 'local',
                sourceType: 'local',
                sourceUrl: '',
                skillFolderHash: '',
                installedAt: process.argv[2],
                updatedAt: process.argv[2]
            };
            console.log(JSON.stringify(data, null, 2));
        " "$SKILL_NAME" "$timestamp" > "$LOCK_FILE" 2>/dev/null && \
            log_success "已更新 $LOCK_FILE" || \
            log_warn "node 更新 lock 文件失败，跳过"
    else
        log_warn "未找到 node，跳过 lock 文件更新"
    fi
}

# 为 AI 助手创建符号链接
create_symlinks() {
    log_info "正在为 AI 助手创建链接..."
    local created=0 skipped=0

    for agent in "${!AGENT_DIRS[@]}"; do
        if [ "$TARGET_AGENT" != "all" ] && [ "$agent" != "$TARGET_AGENT" ]; then continue; fi

        local agent_dir="${AGENT_DIRS[$agent]}"
        local parent_dir=$(dirname "$agent_dir")

        # 仅为已存在的助手目录创建链接
        if [ ! -d "$parent_dir" ]; then ((skipped++)); continue; fi

        mkdir -p "$agent_dir" 2>/dev/null || { ((skipped++)); continue; }
        create_link "$AGENTS_SKILLS_DIR/$SKILL_NAME" "$agent_dir/$SKILL_NAME" && {
            log_success "  -> ${agent_dir/#$HOME\//~\/}/"
            ((created++))
        } || ((skipped++))
    done

    log_info "链接完成: ${GREEN}$created${NC} 成功, ${YELLOW}$skipped${NC} 跳过"
}

# 主函数
main() {
    parse_args "$@"

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}           Skills Manager - Create Skill${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    log_info "名称: $SKILL_NAME"
    log_info "描述: $DESCRIPTION"
    log_info "标签: $TAGS"
    log_info "许可: $LICENSE"
    log_info "目标: $TARGET_AGENT"
    echo ""

    # 步骤 1: 创建技能目录和模板
    local skill_path="$AGENTS_SKILLS_DIR/$SKILL_NAME"
    if [ -d "$skill_path" ]; then
        log_error "技能 '$SKILL_NAME' 已存在: $skill_path"
        exit 1
    fi

    mkdir -p "$skill_path"
    create_skill_md "$skill_path"
    log_success "已创建 SKILL.md: $skill_path/SKILL.md"

    # 步骤 2: 更新 lock 文件
    update_lock_file

    # 步骤 3: 创建符号链接
    create_symlinks

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    log_success "技能 '$SKILL_NAME' 创建成功!"
    log_info "位置: $skill_path"
    log_info "下一步: 编辑 SKILL.md 来完善技能配置"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

main "$@"
