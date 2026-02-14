# Skills Manager - 创建新 Skill（中心仓库优先模式）

param(
    [Parameter(Mandatory=$true)]
    [string]$Name,

    [Parameter(Mandatory=$true)]
    [string]$Description,

    [string[]]$Tags = @("custom"),
    [string]$License = "MIT"
)

# 中心仓库路径
$agentsDir = "$env:USERPROFILE\.agents"
$skillsDir = "$agentsDir\skills"
$lockFile = "$agentsDir\.skill-lock.json"
$skillPath = Join-Path $skillsDir $Name

# 支持的 AI 助手目录映射
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

# 检查是否已存在
if (Test-Path $skillPath) {
    Write-Host "错误: Skill '$Name' 已存在于 $skillPath" -ForegroundColor Red
    exit 1
}

# 创建中心仓库目录
New-Item -ItemType Directory -Path $skillPath -Force | Out-Null

# 创建 SKILL.md 模板
$tagsYaml = $Tags | ForEach-Object { "  - $_" } | Out-String
$tagsYaml = $tagsYaml.Trim().Replace("`n", "`n  ")

$skillMdContent = @"
---
name: $Name
description: $Description
tags:
$tagsYaml
allowed-tools:
  - Bash
  - Read
  - Write
license: $License
custom_instructions: |
  # $Name

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

# $Name

$Description

## 功能特性

- 特性 1
- 特性 2

## 使用方法

[详细说明使用方法]
"@

Set-Content -Path (Join-Path $skillPath "SKILL.md") -Value $skillMdContent

Write-Host "`n成功创建 Skill: $Name" -ForegroundColor Green
Write-Host "位置: $skillPath" -ForegroundColor Gray

# 为已存在的 AI 助手目录创建 Junction
Write-Host "`n正在为已存在的 AI 助手目录创建 Junction..." -ForegroundColor Cyan

$created = 0
$skipped = 0

foreach ($entry in $AgentDirs.GetEnumerator()) {
    $agentName = $entry.Key
    $agentSkillDir = $entry.Value
    $parentDir = Split-Path $agentSkillDir -Parent

    # 仅当 AI 助手的父目录已存在时才创建 Junction
    if (Test-Path $parentDir) {
        # 确保 skills 目录存在
        if (-not (Test-Path $agentSkillDir)) {
            New-Item -ItemType Directory -Path $agentSkillDir -Force | Out-Null
        }

        $linkTarget = Join-Path $agentSkillDir $Name

        # 如果已存在则先删除
        if (Test-Path $linkTarget) {
            Remove-Item $linkTarget -Force -Recurse
        }

        # 创建 Junction
        try {
            New-Item -ItemType Junction -Path $linkTarget -Target $skillPath | Out-Null
            Write-Host "  已链接: $agentName -> $agentSkillDir\$Name" -ForegroundColor Green
            $created++
        } catch {
            Write-Host "  失败: $agentName -> $($_.Exception.Message)" -ForegroundColor Yellow
            $skipped++
        }
    } else {
        $skipped++
    }
}

Write-Host "`n已创建 $created 个 Junction（跳过 $skipped 个）" -ForegroundColor Cyan

# 更新 .skill-lock.json
Write-Host "`n正在更新 .skill-lock.json..." -ForegroundColor Cyan

$timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")

if (Test-Path $lockFile) {
    $lockData = Get-Content $lockFile -Raw | ConvertFrom-Json
} else {
    $lockData = [PSCustomObject]@{
        version   = 3
        skills    = [PSCustomObject]@{}
        dismissed = [PSCustomObject]@{}
    }
}

# 构造新技能条目
$skillEntry = [PSCustomObject]@{
    source          = "local"
    sourceType      = "local"
    sourceUrl       = $skillPath
    skillFolderHash = ""
    installedAt     = $timestamp
    updatedAt       = $timestamp
}

# 添加或更新技能条目
if ($lockData.skills.PSObject.Properties.Name -contains $Name) {
    $lockData.skills.$Name = $skillEntry
} else {
    $lockData.skills | Add-Member -NotePropertyName $Name -NotePropertyValue $skillEntry
}

$lockData | ConvertTo-Json -Depth 10 | Set-Content $lockFile -Encoding UTF8
Write-Host "已更新: $lockFile" -ForegroundColor Green

Write-Host "`n下一步: 编辑 SKILL.md 来完善技能配置`n" -ForegroundColor Yellow
