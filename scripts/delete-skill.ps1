# Skills Manager - 删除 Skill

param(
    [Parameter(Mandatory=$true)]
    [string]$Name,

    [switch]$Force
)

$skillsDir = "$env:USERPROFILE\.claude\skills"
$marketSkillsDir = "$env:USERPROFILE\.claude\plugins\marketplaces\anthropic-agent-skills\skills"

# 查找 skill
$skillPath = $null
$sourceDir = $null

if (Test-Path (Join-Path $skillsDir $Name)) {
    $skillPath = Join-Path $skillsDir $Name
    $sourceDir = "主技能目录"
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

# 创建备份
$backupPath = "$env:USERPROFILE\.claude\skills-backup\$Name-$(Get-Date -Format 'yyyyMMdd-HHmmss').zip"
$backupDir = Split-Path $backupPath -Parent
if (!(Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
}

Write-Host "创建备份: $backupPath" -ForegroundColor Gray
Compress-Archive -Path $skillPath -DestinationPath $backupPath -Force

# 删除
Write-Host "删除 Skill..." -ForegroundColor Yellow
Remove-Item -Recurse -Force $skillPath

Write-Host "`n成功删除 Skill: $Name" -ForegroundColor Green
Write-Host "备份位置: $backupPath`n" -ForegroundColor Gray
