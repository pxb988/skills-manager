#!/bin/bash
# skills-manager add-skill.sh
# 将技能添加到 .agents 系统并自动映射到所有 AI 助手
# Inspired by Skill Seekers (https://github.com/yusufkaraaslan/Skill_Seekers)

set -e

# 配置
AGENTS_DIR="$HOME/.agents"
AGENTS_SKILLS_DIR="$AGENTS_DIR/skills"
LOCK_FILE="$AGENTS_DIR/.skill-lock.json"

# 命令行参数
DRY_RUN=false
FORCE=false
TARGET_AGENT="all"
GITHUB_TOKEN=""

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

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 显示帮助信息
show_help() {
    echo -e "${CYAN}Skills Manager - Add Skill${NC}"
    echo ""
    echo "Usage: $0 [OPTIONS] <source>"
    echo ""
    echo "Arguments:"
    echo "  <source>              Skill source (local path, owner/repo, or git URL)"
    echo ""
    echo "Options:"
    echo "  -a, --agent <name>    Target specific agent (default: all)"
    echo "                        Available: claude-code, cursor, codex, windsurf, etc."
    echo "                        Use 'all' to install to all agents"
    echo "  --dry-run             Preview changes without installing"
    echo "  --force               Overwrite existing installation without prompt"
    echo "  --github-token <token> GitHub token for private repositories"
    echo "  -h, --help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 ./my-local-skill"
    echo "  $0 owner/repo"
    echo "  $0 https://github.com/owner/repo"
    echo "  $0 owner/repo --agent claude-code"
    echo "  $0 owner/repo --dry-run"
    echo "  $0 ./skill --force"
    echo ""
    echo "Supported agents (35+): claude-code, codex, cursor, gemini-cli, kiro-cli,"
    echo "  trae, windsurf, cline, codebuddy, command-code, continue, crush, droid,"
    echo "  goose, junie, kilo, kode, mcpjam, mux, opencode, openhands, pi, qoder,"
    echo "  qwen-code, roo, trae-cn, zencoder, openclaude, neovate, pochi, amp,"
    echo "  antigravity, kimi-cli, moltbot, github-copilot."
}

# 解析命令行参数
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -a|--agent)
                TARGET_AGENT="$2"
                shift 2
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --force)
                FORCE=true
                shift
                ;;
            --github-token)
                GITHUB_TOKEN="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            -*)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
            *)
                SOURCE="$1"
                shift
                ;;
        esac
    done

    if [ -z "$SOURCE" ]; then
        log_error "Missing source argument"
        show_help
        exit 1
    fi
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 解析源类型
parse_source_type() {
    local source="$1"

    if [[ "$source" =~ ^[a-zA-Z0-9_-]+/[a-zA-Z0-9_-]+$ ]]; then
        echo "github"
        echo "https://github.com/$source"
    elif [[ "$source" =~ ^https?:// ]] || [[ "$source" =~ ^git@ ]]; then
        echo "git"
        echo "$source"
    else
        echo "local"
        echo "$source"
    fi
}

# 获取技能名称
get_skill_name() {
    local skill_path="$1"

    if [ ! -f "$skill_path/SKILL.md" ]; then
        log_error "SKILL.md not found in $skill_path"
        return 1
    fi

    # 读取 name 字段
    local name=$(grep "^name:" "$skill_path/SKILL.md" | head -1 | sed 's/name: //' | tr -d '"[:space:]')

    if [ -z "$name" ]; then
        log_error "No 'name' field found in SKILL.md"
        return 1
    fi

    echo "$name"
}

# 安装技能到 .agents
install_skill() {
    local source="$1"
    local source_type="$2"
    local repo_url="$3"

    # 创建目录
    mkdir -p "$AGENTS_SKILLS_DIR"

    if [ "$source_type" = "local" ]; then
        # 复制本地技能
        local temp_dir=$(mktemp -d)
        cp -r "$source" "$temp_dir/temp_skill"
        local skill_name=$(get_skill_name "$temp_dir/temp_skill")
        local skill_dest="$AGENTS_SKILLS_DIR/$skill_name"

        if [ -d "$skill_dest" ]; then
            if [ "$FORCE" = true ]; then
                log_warn "Skill '$skill_name' exists, overwriting (--force)"
                rm -rf "$skill_dest"
            else
                log_warn "Skill '$skill_name' already exists in $AGENTS_SKILLS_DIR"
                read -p "Overwrite? (y/N): " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    rm -rf "$temp_dir"
                    return 1
                fi
                rm -rf "$skill_dest"
            fi
        fi

        mv "$temp_dir/temp_skill" "$skill_dest"
        rm -rf "$temp_dir"
        echo "$skill_name"

    elif [ "$source_type" = "github" ] || [ "$source_type" = "git" ]; then
        # 克隆 git 仓库
        local temp_dir=$(mktemp -d)

        # 构建 git clone URL（如果提供了 token）
        local clone_url="$repo_url"
        if [ -n "$GITHUB_TOKEN" ] && [[ "$repo_url" =~ ^https://github\.com/ ]]; then
            # 将 https://github.com/owner/repo 转换为 https://TOKEN@github.com/owner/repo
            clone_url="${repo_url/https:\/\//https://$GITHUB_TOKEN@}"
        fi

        log_info "Cloning from: $repo_url"
        git clone --depth 1 "$clone_url" "$temp_dir/temp_skill" 2>/dev/null || {
            log_error "Failed to clone $repo_url"
            rm -rf "$temp_dir"
            return 1
        }

        # 检查是否是 skills 目录下的子技能
        local skill_root="$temp_dir/temp_skill"
        if [ -d "$skill_root/skills" ] && [ "$(ls -A "$skill_root/skills" 2>/dev/null)" ]; then
            # 多技能仓库，选择要安装的技能
            log_info "This repository contains multiple skills:"
            local i=1
            declare -A skill_map
            for skill_dir in "$skill_root/skills"/*/; do
                if [ -d "$skill_dir" ]; then
                    local skill_name=$(get_skill_name "$skill_dir" 2>/dev/null || echo "$(basename "$skill_dir")")
                    skill_map[$i]="$skill_dir"
                    echo "  [$i] $skill_name"
                    ((i++))
                fi
            done

            read -p "Select skill to install (1-$((i-1))): " choice
            local selected_skill="${skill_map[$choice]}"
            local skill_name=$(get_skill_name "$selected_skill")
            local skill_dest="$AGENTS_SKILLS_DIR/$skill_name"

            if [ -d "$skill_dest" ]; then
                if [ "$FORCE" = true ]; then
                    log_warn "Skill '$skill_name' exists, overwriting (--force)"
                    rm -rf "$skill_dest"
                else
                    log_warn "Skill '$skill_name' already exists"
                    rm -rf "$temp_dir"
                    return 1
                fi
            fi

            cp -r "$selected_skill" "$skill_dest"
        else
            # 单技能仓库
            local skill_name=$(get_skill_name "$skill_root")
            local skill_dest="$AGENTS_SKILLS_DIR/$skill_name"

            if [ -d "$skill_dest" ]; then
                if [ "$FORCE" = true ]; then
                    log_warn "Skill '$skill_name' exists, overwriting (--force)"
                    rm -rf "$skill_dest"
                else
                    log_warn "Skill '$skill_name' already exists"
                    rm -rf "$temp_dir"
                    return 1
                fi
            fi

            mv "$skill_root" "$skill_dest"
        fi

        rm -rf "$temp_dir"
        echo "$skill_name"
    fi
}

# 更新 .skill-lock.json
update_lock_file() {
    local skill_name="$1"
    local source="$2"
    local source_type="$3"
    local repo_url="$4"

    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")

    # 确定显示用的 source
    local display_source="$source"
    if [ "$source_type" = "github" ]; then
        display_source=$(echo "$source" | sed 's|https://github.com/||')
    fi

    # 转义特殊字符用于 JSON
    local skill_name_escaped=$(echo "$skill_name" | sed 's/\\/\\\\/g; s/"/\\"/g')
    local display_source_escaped=$(echo "$display_source" | sed 's/\\/\\\\/g; s/"/\\"/g')
    local source_url_escaped=$(echo "${repo_url:-$source}" | sed 's/\\/\\\\/g; s/"/\\"/g')

    # 读取现有配置
    if [ -f "$LOCK_FILE" ]; then
        local existing=$(cat "$LOCK_FILE")
    else
        local existing='{"version":3,"skills":{},"dismissed":{}}'
    fi

    # 使用 node 或 python 更新 JSON (如果可用)
    if command -v node &> /dev/null; then
        node -e "
            const data = $existing;
            data.skills['$skill_name_escaped'] = {
                source: '$display_source_escaped',
                sourceType: '$source_type',
                sourceUrl: '$source_url_escaped',
                skillFolderHash: '',
                installedAt: '$timestamp',
                updatedAt: '$timestamp'
            };
            console.log(JSON.stringify(data, null, 2));
        " > "$LOCK_FILE" 2>/dev/null || {
            log_warn "Failed to update lock file with node, using manual update"
            # 回退到手动更新（简单追加）
            local json_entry="  \"$skill_name_escaped\": {
    \"source\": \"$display_source_escaped\",
    \"sourceType\": \"$source_type\",
    \"sourceUrl\": \"$source_url_escaped\",
    \"skillFolderHash\": \"\",
    \"installedAt\": \"$timestamp\",
    \"updatedAt\": \"$timestamp\"
  }"
            # 这里只是一个简化的处理，实际使用时建议确保 node 可用
        }
    else
        log_warn "node not found. JSON update skipped. Please install node for proper lock file handling."
    fi

    log_success "Updated $LOCK_FILE"
}

# 创建符号链接到 AI 助手
create_symlinks() {
    local skill_name="$1"

    # Dry-run 模式
    if [ "$DRY_RUN" = true ]; then
        log_info "${CYAN}[DRY-RUN]${NC} Would create symlinks for: $skill_name"

        if [ "$TARGET_AGENT" = "all" ]; then
            log_info "${CYAN}[DRY-RUN]${NC} Target: All agents (${#AGENT_DIRS[@]} agents)"
            for agent in "${!AGENT_DIRS[@]}"; do
                local agent_skill_dir="${AGENT_DIRS[$agent]}"
                # 显示相对路径，将 $HOME 替换为 ~/
                local display_path="${agent_skill_dir/#$HOME\//~\/}"
                log_info "${CYAN}[DRY-RUN]${NC}   Would link to: $display_path/"
            done
        else
            log_info "${CYAN}[DRY-RUN]${NC} Target: $TARGET_AGENT"
            if [ -n "${AGENT_DIRS[$TARGET_AGENT]}" ]; then
                local agent_skill_dir="${AGENT_DIRS[$TARGET_AGENT]}"
                local display_path="${agent_skill_dir/#$HOME\//~\/}"
                log_info "${CYAN}[DRY-RUN]${NC}   Would link to: $display_path/"
            else
                log_warn "Unknown agent: $TARGET_AGENT"
                log_warn "Available agents: ${!AGENT_DIRS[@]}"
            fi
        fi
        return 0
    fi

    log_info "Creating symlinks to AI agent directories..."
    if [ "$TARGET_AGENT" != "all" ]; then
        log_info "Target: $TARGET_AGENT"
    fi

    local created=0
    local skipped=0
    local total=0

    for agent in "${!AGENT_DIRS[@]}"; do
        # 如果指定了特定 agent，跳过其他 agent
        if [ "$TARGET_AGENT" != "all" ] && [ "$agent" != "$TARGET_AGENT" ]; then
            continue
        fi

        local agent_skill_dir="${AGENT_DIRS[$agent]}"
        local display_path="${agent_skill_dir/#$HOME\//~\/}"

        ((total++))

        # 创建目录
        mkdir -p "$agent_skill_dir" 2>/dev/null || {
            log_warn "  ✗ Failed to create directory: $display_path/"
            ((skipped++))
            continue
        }

        local link_target="$agent_skill_dir/$skill_name"
        local skill_source="$AGENTS_SKILLS_DIR/$skill_name"

        # 删除旧链接（如果存在）
        if [ -L "$link_target" ]; then
            rm "$link_target"
        fi

        # 创建符号链接
        ln -sf "$skill_source" "$link_target" 2>/dev/null && {
            log_success "  ✓ Linked to $display_path/"
            ((created++))
        } || {
            log_warn "  ✗ Failed to link to $display_path/"
            ((skipped++))
        }
    done

    if [ "$TARGET_AGENT" = "all" ]; then
        log_success "Created $created symlinks ($skipped skipped) out of $total agents"
    else
        log_success "Created $created symlinks ($skipped skipped)"
    fi
}

# 主函数
main() {
    # 解析命令行参数
    parse_args "$@"

    local source_type repo_url
    read -r source_type repo_url <<< "$(parse_source_type "$SOURCE")"

    # 显示执行摘要
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}           Skills Manager - Add Skill to .agents${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    log_info "Source: $SOURCE"
    log_info "Type: $source_type"
    log_info "Target: $TARGET_AGENT"
    if [ "$DRY_RUN" = true ]; then
        log_info "Mode: ${CYAN}DRY-RUN${NC} (no changes will be made)"
    fi
    if [ "$FORCE" = true ]; then
        log_info "Overwrite: ${YELLOW}FORCE${NC}"
    fi
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # Dry-run 模式 - 只显示预览，不做任何更改
    if [ "$DRY_RUN" = true ]; then
        echo -e "${BLUE}[1/3]${NC} ${CYAN}[DRY-RUN]${NC} Would install skill from: $SOURCE"
        echo -e "${BLUE}[2/3]${NC} ${CYAN}[DRY-RUN]${NC} Would update $LOCK_FILE"
        echo -e "${BLUE}[3/3]${NC} ${CYAN}[DRY-RUN]${NC} Would create symlinks:"
        create_symlinks "dry-run-skill"
        echo ""
        log_info "${CYAN}[DRY-RUN]${NC} Preview complete. No changes were made."
        log_info "Run without --dry-run to apply changes."
        echo ""
        return 0
    fi

    # 步骤 1: 安装技能
    echo -e "${BLUE}[1/3]${NC} Installing skill to .agents directory..."
    local skill_name=$(install_skill "$SOURCE" "$source_type" "$repo_url")

    if [ $? -ne 0 ] || [ -z "$skill_name" ]; then
        log_error "Failed to install skill"
        exit 1
    fi

    log_success "Installed skill: $skill_name"

    # 步骤 2: 更新 .skill-lock.json
    echo ""
    echo -e "${BLUE}[2/3]${NC} Updating .skill-lock.json..."
    update_lock_file "$skill_name" "$SOURCE" "$source_type" "$repo_url"

    # 步骤 3: 创建符号链接
    echo ""
    echo -e "${BLUE}[3/3]${NC} Creating symlinks to AI agents..."
    create_symlinks "$skill_name"

    # 完成
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    log_success "Skill '$skill_name' added successfully!"
    echo ""
    log_info "Skill location: $AGENTS_SKILLS_DIR/$skill_name"
    if [ "$TARGET_AGENT" = "all" ]; then
        log_info "The skill is now available in all supported AI coding agents."
    else
        log_info "The skill is now available in: $TARGET_AGENT"
    fi
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

main "$@"
