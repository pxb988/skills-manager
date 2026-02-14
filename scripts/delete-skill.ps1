# Skills Manager - 删除 Skill

param(
    [Parameter(Mandatory=$true)]
    [string]$Name,

    [switch]$Force
)

$agentsSkillsDir = "$env:USERPROFILE\.agents\skills"
$claudeSkillsDir = "$env:USERPROFILE\.claude\skills"
$marketSkillsDir = "$env:USERPROFILE\.claude\plugins\marketplaces\anthropic-agent-skills\skills"

# AI 助手目录列表（用于清理 Junction）
$AgentDirs = @{
    "claude-code"    = "$env:USERPROFILE\.claude\skills"
    "codex"          = "$env:USERPROFILE\.codex\skills"
    "cursor"         = "$env:USERPROFILE\.cursor\skills"
    "gemini-cli"     = "$env:USERPROFILE\.gemini\skills"
    "kiro-cli"       = "$env:USERPROFILE\.kiro\skills"
    "trae"           = "$env:USERPROFILE\.trae\skills"
    "windsurf"       = "$env:USERPROFILE\.codeium\windsurf\skills"
    "cline"          = "$env:USERPROFILE\.cline\skills"
    "codebuddy"      = "$env:USERPROFILE\.codebuddy\skills"
    "command-code"   = "$env:USERPROFILE\.commandcode\skills"
    "continue"       = "$env:USERPROFILE\.continue\skills"
    "crush"          = "$env:USERPROFILE\.config\crush\skills"
    "droid"          = "$env:USERPROFILE\.factory\skills"
    "goose"          = "$env:USERPROFILE\.config\goose\skills"
    "junie"          = "$env:USERPROFILE\.junie\skills"
    "kilo"           = "$env:USERPROFILE\.kilocode\skills"
    "kode"           = "$env:USERPROFILE\.kode\skills"
    "mcpjam"         = "$env:USERPROFILE\.mcpjam\skills"
    "mux"            = "$env:USERPROFILE\.mux\skills"
    "opencode"       = "$env:USERPROFILE\.config\opencode\skills"
    "openhands"      = "$env:USERPROFILE\.openhands\skills"
    "pi"             = "$env:USERPROFILE\.pi\agent\skills"
    "qoder"          = "$env:USERPROFILE\.qoder\skills"
    "qwen-code"      = "$env:USERPROFILE\.qwen\skills"
    "roo"            = "$env:USERPROFILE\.roo\skills"
    "trae-cn"        = "$env:USERPROFILE\.trae-cn\skills"
    "zencoder"       = "$env:USERPROFILE\.zencoder\skills"
    "openclaude"     = "$env:USERPROFILE\.openclaude\skills"
    "neovate"        = "$env:USERPROFILE\.neovate\skills"
    "pochi"          = "$env:USERPROFILE\.pochi\skills"
    "amp"            = "$env:USERPROFILE\.config\agents\skills"
    "antigravity"    = "$env:USERPROFILE\.gemini\antigravity\global_skills"
    "kimi-cli"       = "$env:USERPROFILE\.config\agents\skills"
    "moltbot"        = "$env:USERPROFILE\.moltbot\skills"
    "github-copilot" = "$env:USERPROFILE\.copilot\skills"
}

# 查找 skill（优先级：.agents/skills > .claude/skills > 市场目录）
$skillPath = $null
$sourceDir = $null

if (Test-Path (Join-Path $agentsSkillsDir $Name)) {
    $skillPath = Join-Path $agentsSkillsDir $Name
    $sourceDir = "中心仓库 (.agents/skills)"
} elseif (Test-Path (Join-Path $claudeSkillsDir $Name)) {
    $skillPath = Join-Path $claudeSkillsDir $Name
    $sourceDir = "Claude 技能目录"
} elseif (Test-Path (Join-Path $marketSkillsDir $Name)) {
    $skillPath = Join-Path $marketSkillsDir $Name
    $sourceDir = "市场技能目录"
} else {
    Write-Host "错误: 未找到 skill '$Name'" -ForegroundColor Red
    exit 1
}

Write-Host "`n将要删除的 Skill:" -ForegroundColor Yellow
Write-Host "  名称: $Name" -ForegroundColor Cyan
Write-Host "  位置: $skillPath" -ForegroundColor Gray
Write-Host "  来源: $sourceDir`n" -ForegroundColor Gray

# 显示文件数量
$fileCount = (Get-ChildItem $skillPath -Recurse -File | Measure-Object).Count
$dirCount = (Get-ChildItem $skillPath -Recurse -Directory | Measure-Object).Count
Write-Host "  包含: $dirCount 个目录, $fileCount 个文件`n" -ForegroundColor Gray

if (!$Force) {
    $confirm = Read-Host "确认删除? (输入 'yes' 确认)"
    if ($confirm -ne "yes") {
        Write-Host "已取消删除" -ForegroundColor Yellow
        exit 0
    }
}

# ============================================================
# [1/3] 清理所有 AI 助手目录中的 Junction/符号链接
# ============================================================
Write-Host "`n[1/3] 清理助手 Junction..." -ForegroundColor Yellow

$junctionCount = 0
foreach ($agent in $AgentDirs.GetEnumerator()) {
    $linkPath = Join-Path $agent.Value $Name
    if (Test-Path $linkPath) {
        $item = Get-Item $linkPath -Force
        if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
            Write-Host "  删除 Junction: $($agent.Key) -> $linkPath" -ForegroundColor Gray
            $item.Delete()
            $junctionCount++
        }
    }
}

if ($junctionCount -eq 0) {
    Write-Host "  未发现 Junction" -ForegroundColor Gray
} else {
    Write-Host "  已清理 $junctionCount 个 Junction" -ForegroundColor Green
}

# ============================================================
# [2/3] 删除中心仓库源文件（先备份再删除）
# ============================================================
Write-Host "`n[2/3] 删除源文件..." -ForegroundColor Yellow

# 创建备份
$backupPath = "$env:USERPROFILE\.claude\skills-backup\$Name-$(Get-Date -Format 'yyyyMMdd-HHmmss').zip"
$backupDir = Split-Path $backupPath -Parent
if (!(Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
}

Write-Host "  创建备份: $backupPath" -ForegroundColor Gray
Compress-Archive -Path $skillPath -DestinationPath $backupPath -Force

# 删除源文件
Write-Host "  删除目录: $skillPath" -ForegroundColor Gray
Remove-Item -Recurse -Force $skillPath

# ============================================================
# [3/3] 更新 .skill-lock.json（移除对应条目）
# ============================================================
Write-Host "`n[3/3] 更新 .skill-lock.json..." -ForegroundColor Yellow

$lockFile = "$env:USERPROFILE\.agents\.skill-lock.json"
if (Test-Path $lockFile) {
    $lockContent = Get-Content $lockFile -Raw | ConvertFrom-Json

    if ($lockContent.PSObject.Properties[$Name]) {
        $lockContent.PSObject.Properties.Remove($Name)
        $lockContent | ConvertTo-Json -Depth 10 | Set-Content $lockFile -Encoding UTF8
        Write-Host "  已从 .skill-lock.json 移除条目: $Name" -ForegroundColor Gray
    } else {
        Write-Host "  .skill-lock.json 中无对应条目" -ForegroundColor Gray
    }
} else {
    Write-Host "  .skill-lock.json 不存在，跳过" -ForegroundColor Gray
}

# 完成
Write-Host "`n成功删除 Skill: $Name" -ForegroundColor Green
Write-Host "备份位置: $backupPath`n" -ForegroundColor Gray
