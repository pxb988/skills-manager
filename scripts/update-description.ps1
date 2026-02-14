# Skills Manager - 更新 Skill 描述

param(
    [Parameter(Mandatory=$true)]
    [string]$Name,

    [Parameter(Mandatory=$true)]
    [string]$NewDescription
)

$agentsSkillsDir = "$env:USERPROFILE\.agents\skills"
$skillsDir = "$env:USERPROFILE\.claude\skills"

# 查找 skill（优先中心仓库）
$skillPath = $null

if (Test-Path (Join-Path $agentsSkillsDir $Name)) {
    $skillPath = Join-Path $agentsSkillsDir $Name
} elseif (Test-Path (Join-Path $skillsDir $Name)) {
    $skillPath = Join-Path $skillsDir $Name
} else {
    Write-Host "错误: 未找到 skill '$Name'" -ForegroundColor Red
    exit 1
}

$skillMd = Join-Path $skillPath "SKILL.md"

if (!(Test-Path $skillMd)) {
    Write-Host "错误: Skill 缺少 SKILL.md 文件" -ForegroundColor Red
    exit 1
}

# 读取内容
$content = Get-Content $skillMd -Raw

# 备份原文件
$backupPath = "$skillMd.bak"
Copy-Item $skillMd $backupPath

# 更新描述
if ($content -match 'description:\s*.+?\n') {
    $content = $content -replace 'description:\s*.+?\n', "description: $NewDescription`n"
    Set-Content -Path $skillMd -Value $content -NoNewline

    Write-Host "`n成功更新描述" -ForegroundColor Green
    Write-Host "Skill: $Name" -ForegroundColor Cyan
    Write-Host "位置: $skillPath" -ForegroundColor Gray
    Write-Host "新描述: $NewDescription`n" -ForegroundColor White
    Write-Host "备份: $backupPath`n" -ForegroundColor Gray
} else {
    Write-Host "错误: 无法在 SKILL.md 中找到 description 字段" -ForegroundColor Red
    exit 1
}
