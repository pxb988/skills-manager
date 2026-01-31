# Skills Manager - 备份 Skills

param(
    [string]$Name,
    [string]$OutputPath = "$env:USERPROFILE\.claude\skills-backup"
)

$skillsDir = "$env:USERPROFILE\.claude\skills"

if ([string]::IsNullOrWhiteSpace($Name)) {
    # 备份所有 skills
    Write-Host "`n=== 备份所有 Skills ===`n" -ForegroundColor Cyan

    if (!(Test-Path $OutputPath)) {
        New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    }

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupFile = Join-Path $OutputPath "all-skills-$timestamp.zip"

    Write-Host "创建备份..." -ForegroundColor Yellow
    Compress-Archive -Path "$skillsDir\*" -DestinationPath $backupFile -Force

    $size = (Get-Item $backupFile).Length / 1KB
    Write-Host "`n成功备份所有 Skills" -ForegroundColor Green
    Write-Host "备份文件: $backupFile" -ForegroundColor Gray
    Write-Host "文件大小: $([math]::Round($size, 2)) KB`n" -ForegroundColor Gray
} else {
    # 备份单个 skill
    $skillPath = Join-Path $skillsDir $Name

    if (!(Test-Path $skillPath)) {
        Write-Host "错误: 未找到 skill '$Name'" -ForegroundColor Red
        exit 1
    }

    if (!(Test-Path $OutputPath)) {
        New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    }

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupFile = Join-Path $OutputPath "$Name-$timestamp.zip"

    Write-Host "`n=== 备份 Skill: $Name ===`n" -ForegroundColor Cyan
    Write-Host "创建备份..." -ForegroundColor Yellow
    Compress-Archive -Path $skillPath -DestinationPath $backupFile -Force

    $size = (Get-Item $backupFile).Length / 1KB
    Write-Host "`n成功备份 Skill: $Name" -ForegroundColor Green
    Write-Host "备份文件: $backupFile" -ForegroundColor Gray
    Write-Host "文件大小: $([math]::Round($size, 2)) KB`n" -ForegroundColor Gray
}
