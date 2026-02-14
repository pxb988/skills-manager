# Skills Manager - Add Skill (PowerShell 原生版本)
# 将技能添加到 .agents 系统并自动映射到所有 AI 助手

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Source,

    [string]$Agent = "all",
    [switch]$DryRun,
    [switch]$Force,
    [string]$GithubToken
)

# 配置
$AgentsDir = "$env:USERPROFILE\.agents"
$AgentsSkillsDir = "$AgentsDir\skills"
$LockFile = "$AgentsDir\.skill-lock.json"

# 支持的 AI 助手目录映射 (35+)
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

# === 辅助函数 ===

function Write-Info    { param([string]$Msg) Write-Host "[INFO] "    -ForegroundColor Blue   -NoNewline; Write-Host $Msg }
function Write-Ok      { param([string]$Msg) Write-Host "[SUCCESS] " -ForegroundColor Green  -NoNewline; Write-Host $Msg }
function Write-Warn    { param([string]$Msg) Write-Host "[WARN] "    -ForegroundColor Yellow -NoNewline; Write-Host $Msg }
function Write-Err     { param([string]$Msg) Write-Host "[ERROR] "   -ForegroundColor Red    -NoNewline; Write-Host $Msg }

# 解析源类型：返回 [sourceType, repoUrl]
function Get-SourceType {
    param([string]$Src)
    if ($Src -match '^[a-zA-Z0-9_-]+/[a-zA-Z0-9_.-]+$') {
        return @("github", "https://github.com/$Src")
    } elseif ($Src -match '^https?://' -or $Src -match '^git@') {
        return @("git", $Src)
    } else {
        return @("local", $Src)
    }
}

# 从 SKILL.md 的 YAML frontmatter 中提取 name 字段
function Get-SkillName {
    param([string]$SkillPath)
    $skillMd = Join-Path $SkillPath "SKILL.md"
    if (-not (Test-Path $skillMd)) {
        Write-Err "SKILL.md not found in $SkillPath"
        return $null
    }
    $lines = Get-Content $skillMd -Encoding UTF8
    foreach ($line in $lines) {
        if ($line -match '^\s*name:\s*(.+)$') {
            return ($Matches[1].Trim().Trim('"').Trim("'"))
        }
    }
    Write-Err "No 'name' field found in SKILL.md"
    return $null
}

# 安装技能到 .agents/skills，返回技能名称
function Install-Skill {
    param([string]$Src, [string]$SrcType, [string]$RepoUrl)

    # 确保目标目录存在
    if (-not (Test-Path $AgentsSkillsDir)) {
        New-Item -ItemType Directory -Path $AgentsSkillsDir -Force | Out-Null
    }

    if ($SrcType -eq "local") {
        # 本地安装：复制目录
        $resolvedSrc = (Resolve-Path $Src -ErrorAction Stop).Path
        $skillName = Get-SkillName -SkillPath $resolvedSrc
        if (-not $skillName) { return $null }

        $skillDest = Join-Path $AgentsSkillsDir $skillName
        if (Test-Path $skillDest) {
            if ($Force) {
                Write-Warn "Skill '$skillName' exists, overwriting (--Force)"
                Remove-Item $skillDest -Recurse -Force
            } else {
                Write-Warn "Skill '$skillName' already exists in $AgentsSkillsDir"
                $reply = Read-Host "Overwrite? (y/N)"
                if ($reply -notmatch '^[Yy]') { return $null }
                Remove-Item $skillDest -Recurse -Force
            }
        }
        Copy-Item -Path $resolvedSrc -Destination $skillDest -Recurse -Force
        return $skillName

    } else {
        # GitHub / Git 安装：克隆仓库
        $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("skill_" + [guid]::NewGuid().ToString("N").Substring(0,8))
        $cloneUrl = $RepoUrl
        if ($GithubToken -and $RepoUrl -match '^https://github\.com/') {
            $cloneUrl = $RepoUrl -replace '^https://', "https://$GithubToken@"
        }

        Write-Info "Cloning from: $RepoUrl"
        & git clone --depth 1 $cloneUrl $tempDir 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Err "Failed to clone $RepoUrl"
            if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
            return $null
        }

        # 判断是单技能仓库还是多技能仓库
        $skillsSubDir = Join-Path $tempDir "skills"
        if ((Test-Path $skillsSubDir) -and (Get-ChildItem $skillsSubDir -Directory).Count -gt 0) {
            # 多技能仓库：让用户选择
            Write-Info "This repository contains multiple skills:"
            $dirs = Get-ChildItem $skillsSubDir -Directory
            for ($i = 0; $i -lt $dirs.Count; $i++) {
                $n = Get-SkillName -SkillPath $dirs[$i].FullName
                if (-not $n) { $n = $dirs[$i].Name }
                Write-Host "  [$($i+1)] $n"
            }
            $choice = Read-Host "Select skill to install (1-$($dirs.Count))"
            $selectedDir = $dirs[[int]$choice - 1].FullName
            $skillName = Get-SkillName -SkillPath $selectedDir
            if (-not $skillName) { Remove-Item $tempDir -Recurse -Force; return $null }

            $skillDest = Join-Path $AgentsSkillsDir $skillName
            if (Test-Path $skillDest) {
                if ($Force) { Write-Warn "Skill '$skillName' exists, overwriting (--Force)"; Remove-Item $skillDest -Recurse -Force }
                else { Write-Warn "Skill '$skillName' already exists"; Remove-Item $tempDir -Recurse -Force; return $null }
            }
            Copy-Item $selectedDir $skillDest -Recurse -Force
        } else {
            # 单技能仓库
            $skillName = Get-SkillName -SkillPath $tempDir
            if (-not $skillName) { Remove-Item $tempDir -Recurse -Force; return $null }

            $skillDest = Join-Path $AgentsSkillsDir $skillName
            if (Test-Path $skillDest) {
                if ($Force) { Write-Warn "Skill '$skillName' exists, overwriting (--Force)"; Remove-Item $skillDest -Recurse -Force }
                else { Write-Warn "Skill '$skillName' already exists"; Remove-Item $tempDir -Recurse -Force; return $null }
            }
            # 移动整个仓库（排除 .git）
            Copy-Item $tempDir $skillDest -Recurse -Force
            $gitDir = Join-Path $skillDest ".git"
            if (Test-Path $gitDir) { Remove-Item $gitDir -Recurse -Force }
        }
        Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        return $skillName
    }
}

# 更新 .skill-lock.json（纯 PowerShell，不依赖 node）
function Update-LockFile {
    param([string]$SkillName, [string]$Src, [string]$SrcType, [string]$RepoUrl)

    $timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
    $displaySource = if ($SrcType -eq "github") { $Src -replace '^https://github\.com/', '' } else { $Src }
    $sourceUrl = if ($RepoUrl) { $RepoUrl } else { $Src }

    # 读取或初始化 lock 文件
    if (Test-Path $LockFile) {
        $lockData = Get-Content $LockFile -Raw -Encoding UTF8 | ConvertFrom-Json
    } else {
        $lockData = [PSCustomObject]@{ version = 3; skills = [PSCustomObject]@{}; dismissed = [PSCustomObject]@{} }
    }

    # 构造新的技能条目
    $entry = [PSCustomObject]@{
        source          = $displaySource
        sourceType      = $SrcType
        sourceUrl       = $sourceUrl
        skillFolderHash = ""
        installedAt     = $timestamp
        updatedAt       = $timestamp
    }

    # 添加或更新技能条目
    if ($lockData.skills.PSObject.Properties[$SkillName]) {
        $lockData.skills.$SkillName = $entry
    } else {
        $lockData.skills | Add-Member -NotePropertyName $SkillName -NotePropertyValue $entry
    }

    # 写回文件（Depth 10 确保完整序列化）
    $lockData | ConvertTo-Json -Depth 10 | Set-Content $LockFile -Encoding UTF8
    Write-Ok "Updated $LockFile"
}

# 为 AI 助手创建 Junction 链接
function New-SkillJunctions {
    param([string]$SkillName)

    $skillSource = Join-Path $AgentsSkillsDir $SkillName
    $created = 0; $skipped = 0; $total = 0

    foreach ($kv in $AgentDirs.GetEnumerator()) {
        $agentName = $kv.Key
        $agentSkillDir = $kv.Value

        # 如果指定了特定 agent，跳过其他
        if ($Agent -ne "all" -and $agentName -ne $Agent) { continue }
        $total++

        $displayPath = $agentSkillDir -replace [regex]::Escape($env:USERPROFILE), '~'

        # DryRun 模式只打印
        if ($DryRun) {
            Write-Info "[DRY-RUN]   Would link to: $displayPath\$SkillName"
            continue
        }

        # 确保父目录存在
        try {
            if (-not (Test-Path $agentSkillDir)) { New-Item -ItemType Directory -Path $agentSkillDir -Force | Out-Null }
        } catch {
            Write-Warn "  x Failed to create directory: $displayPath"; $skipped++; continue
        }

        $linkTarget = Join-Path $agentSkillDir $SkillName

        # 删除旧链接
        if (Test-Path $linkTarget) { Remove-Item $linkTarget -Force -Recurse -ErrorAction SilentlyContinue }

        # 创建 Junction
        try {
            New-Item -ItemType Junction -Path $linkTarget -Target $skillSource -ErrorAction Stop | Out-Null
            Write-Ok "  -> $displayPath\$SkillName"
            $created++
        } catch {
            Write-Warn "  x Failed to link to $displayPath\$SkillName"
            $skipped++
        }
    }

    if (-not $DryRun) {
        $targetLabel = if ($Agent -eq "all") { "$total agents" } else { $Agent }
        Write-Ok "Created $created junctions ($skipped skipped) for $targetLabel"
    }
}

# === 主流程 ===

# 验证指定的 agent 是否合法
if ($Agent -ne "all" -and -not $AgentDirs.ContainsKey($Agent)) {
    Write-Err "Unknown agent: $Agent"
    Write-Info "Available agents: $($AgentDirs.Keys -join ', ')"
    exit 1
}

# 解析源类型
$parsed = Get-SourceType -Src $Source
$sourceType = $parsed[0]
$repoUrl    = $parsed[1]

# 显示执行摘要
Write-Host ""
Write-Host ([string]::new([char]0x2501, 60)) -ForegroundColor Cyan
Write-Host "           Skills Manager - Add Skill to .agents"  -ForegroundColor Cyan
Write-Host ([string]::new([char]0x2501, 60)) -ForegroundColor Cyan
Write-Host ""
Write-Info "Source: $Source"
Write-Info "Type:   $sourceType"
Write-Info "Target: $Agent"
if ($DryRun) { Write-Info "Mode:   DRY-RUN (no changes will be made)" }
if ($Force)  { Write-Info "Overwrite: FORCE" }
Write-Host ([string]::new([char]0x2501, 60)) -ForegroundColor Cyan
Write-Host ""

# --- DryRun 模式：只预览不执行 ---
if ($DryRun) {
    Write-Host "[1/3] " -ForegroundColor Blue -NoNewline; Write-Host "[DRY-RUN] Would install skill from: $Source"
    Write-Host "[2/3] " -ForegroundColor Blue -NoNewline; Write-Host "[DRY-RUN] Would update $LockFile"
    Write-Host "[3/3] " -ForegroundColor Blue -NoNewline; Write-Host "[DRY-RUN] Would create junctions:"
    New-SkillJunctions -SkillName "dry-run-skill"
    Write-Host ""
    Write-Info "[DRY-RUN] Preview complete. No changes were made."
    Write-Info "Run without -DryRun to apply changes."
    Write-Host ""
    exit 0
}

# --- 步骤 1: 安装技能 ---
Write-Host "[1/3] " -ForegroundColor Blue -NoNewline; Write-Host "Installing skill to .agents directory..."
$skillName = Install-Skill -Src $Source -SrcType $sourceType -RepoUrl $repoUrl

if (-not $skillName) {
    Write-Err "Failed to install skill"
    exit 1
}
Write-Ok "Installed skill: $skillName"

# --- 步骤 2: 更新 lock 文件 ---
Write-Host ""
Write-Host "[2/3] " -ForegroundColor Blue -NoNewline; Write-Host "Updating .skill-lock.json..."
Update-LockFile -SkillName $skillName -Src $Source -SrcType $sourceType -RepoUrl $repoUrl

# --- 步骤 3: 创建 Junction ---
Write-Host ""
Write-Host "[3/3] " -ForegroundColor Blue -NoNewline; Write-Host "Creating junctions to AI agents..."
New-SkillJunctions -SkillName $skillName

# --- 完成摘要 ---
Write-Host ""
Write-Host ([string]::new([char]0x2501, 60)) -ForegroundColor Cyan
Write-Ok "Skill '$skillName' added successfully!"
Write-Host ""
Write-Info "Skill location: $AgentsSkillsDir\$skillName"
if ($Agent -eq "all") {
    Write-Info "The skill is now available in all $($AgentDirs.Count) supported AI coding agents."
} else {
    Write-Info "The skill is now available in: $Agent"
}
Write-Host ([string]::new([char]0x2501, 60)) -ForegroundColor Cyan
Write-Host ""
