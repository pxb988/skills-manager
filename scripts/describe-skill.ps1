# Skills Manager - 描述 Skill 功能

param(
    [Parameter(Mandatory=$true)]
    [string]$SkillName
)

$skillsDir = "$env:USERPROFILE\.claude\skills"
$marketSkillsDir = "$env:USERPROFILE\.claude\plugins\marketplaces\anthropic-agent-skills\skills"

# 查找 skill
$skillPath = $null

if (Test-Path (Join-Path $skillsDir $SkillName)) {
    $skillPath = Join-Path $skillsDir $SkillName
} elseif (Test-Path (Join-Path $marketSkillsDir $SkillName)) {
    $skillPath = Join-Path $marketSkillsDir $SkillName
} else {
    Write-Host "错误: 未找到 skill '$SkillName'" -ForegroundColor Red
    exit 1
}

$skillMd = Join-Path $skillPath "SKILL.md"

if (!(Test-Path $skillMd)) {
    Write-Host "错误: Skill 缺少 SKILL.md 文件" -ForegroundColor Red
    exit 1
}

Write-Host "`n=== Skill: $SkillName ===`n" -ForegroundColor Cyan

# 解析 SKILL.md
$content = Get-Content $skillMd -Raw

# 提取 YAML 字段
$name = if ($content -match 'name:\s*(.+)') { $matches[1].Trim() } else { "未知" }
$description = if ($content -match 'description:\s*(.+?)\n') { $matches[1].Trim() } else { "无描述" }
$license = if ($content -match 'license:\s*(.+?)\n') { $matches[1].Trim() } else { "未指定" }

Write-Host "名称: $name" -ForegroundColor Yellow
Write-Host "描述: $description" -ForegroundColor White
Write-Host "许可证: $license`n" -ForegroundColor Gray

# 提取 tags
if ($content -match 'tags:\s*\n((?:\s*-\s*.+\n)+)') {
    Write-Host "标签:" -ForegroundColor Yellow
    $tags = $matches[1] -split '\n'
    $tags | Where-Object { $_ -match '-\s*(.+)'} | ForEach-Object {
        Write-Host "  - $($matches[1].Trim())" -ForegroundColor White
    }
    Write-Host ""
}

# 提取 allowed-tools
if ($content -match 'allowed-tools:\s*\n((?:\s*-\s*.+\n)+)') {
    Write-Host "可用工具:" -ForegroundColor Yellow
    $tools = $matches[1] -split '\n'
    $tools | Where-Object { $_ -match '-\s*(.+)'} | ForEach-Object {
        Write-Host "  - $($matches[1].Trim())" -ForegroundColor White
    }
    Write-Host ""
}

# 提取 custom_instructions
if ($content -match 'custom_instructions:\s*\|(.+?)---') {
    Write-Host "使用说明:" -ForegroundColor Yellow
    $instructions = $matches[1].Trim() -replace '^\s+', ''
    Write-Host $instructions -ForegroundColor White
    Write-Host ""
}

# 显示目录结构
Write-Host "文件结构:" -ForegroundColor Yellow
Get-ChildItem $skillPath -Recurse | ForEach-Object {
    $indent = "  " * ($_.FullName.Replace($skillPath, "").Split("\").Count - 1)
    $name = $_.FullName.Replace($skillPath, "").Trim("\")
    if ($_.PSIsContainer) {
        Write-Host "$indent$name/" -ForegroundColor Blue
    } else {
        Write-Host "$indent$name" -ForegroundColor Gray
    }
}
