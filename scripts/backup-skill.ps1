# Skills Manager - 备份 Skills

param(
    [string]$Name,
    [string]$OutputPath = "$env:USERPROFILE\.claude\skills-backup",

    [ValidateSet("agents", "claude", "all")]
    [string]$Source = "agents"
)

$agentsSkillsDir = "$env:USERPROFILE\.agents\skills"
$skillsDir = "$env:USERPROFILE\.claude\skills"

if ([string]::IsNullOrWhiteSpace($Name)) {
    # 备份所有 skills
    Write-Host "`n=== 备份所有 Skills ===`n" -ForegroundColor Cyan

    if (!(Test-Path $OutputPath)) {
        New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    }

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

    switch ($Source) {
        "agents" {
            if (!(Test-Path $agentsSkillsDir)) {
                Write-Host "错误: 中心仓库目录不存在: $agentsSkillsDir" -ForegroundColor Red
                exit 1
            }
            $backupFile = Join-Path $OutputPath "agents-skills-$timestamp.zip"
            Write-Host "备份来源: 中心仓库 ($agentsSkillsDir)" -ForegroundColor Yellow
            Compress-Archive -Path "$agentsSkillsDir\*" -DestinationPath $backupFile -Force
        }
        "claude" {
            if (!(Test-Path $skillsDir)) {
                Write-Host "错误: 主技能目录不存在: $skillsDir" -ForegroundColor Red
                exit 1
            }
            $backupFile = Join-Path $OutputPath "claude-skills-$timestamp.zip"
            Write-Host "备份来源: 主技能目录 ($skillsDir)" -ForegroundColor Yellow
            Compress-Archive -Path "$skillsDir\*" -DestinationPath $backupFile -Force
        }
        "all" {
            $backupFile = Join-Path $OutputPath "all-skills-$timestamp.zip"
            Write-Host "备份来源: 全部" -ForegroundColor Yellow
            $tempDir = Join-Path $env:TEMP "skills-backup-$timestamp"
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

            if (Test-Path $agentsSkillsDir) {
                Copy-Item -Path $agentsSkillsDir -Destination (Join-Path $tempDir "agents-skills") -Recurse
            }
            if (Test-Path $skillsDir) {
                Copy-Item -Path $skillsDir -Destination (Join-Path $tempDir "claude-skills") -Recurse
            }

            Compress-Archive -Path "$tempDir\*" -DestinationPath $backupFile -Force
            Remove-Item -Recurse -Force $tempDir
        }
    }

    $size = (Get-Item $backupFile).Length / 1KB
    Write-Host "`n成功备份 Skills" -ForegroundColor Green
    Write-Host "备份文件: $backupFile" -ForegroundColor Gray
    Write-Host "文件大小: $([math]::Round($size, 2)) KB`n" -ForegroundColor Gray
} else {
    # 备份单个 skill — 优先在 .agents 查找
    $skillPath = $null

    if (Test-Path (Join-Path $agentsSkillsDir $Name)) {
        $skillPath = Join-Path $agentsSkillsDir $Name
        Write-Host "`n=== 备份 Skill: $Name (中心仓库) ===`n" -ForegroundColor Cyan
    } elseif (Test-Path (Join-Path $skillsDir $Name)) {
        $skillPath = Join-Path $skillsDir $Name
        Write-Host "`n=== 备份 Skill: $Name (主技能目录) ===`n" -ForegroundColor Cyan
    } else {
        Write-Host "错误: 未找到 skill '$Name'" -ForegroundColor Red
        exit 1
    }

    if (!(Test-Path $OutputPath)) {
        New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    }

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupFile = Join-Path $OutputPath "$Name-$timestamp.zip"

    Write-Host "创建备份..." -ForegroundColor Yellow
    Compress-Archive -Path $skillPath -DestinationPath $backupFile -Force

    $size = (Get-Item $backupFile).Length / 1KB
    Write-Host "`n成功备份 Skill: $Name" -ForegroundColor Green
    Write-Host "备份文件: $backupFile" -ForegroundColor Gray
    Write-Host "文件大小: $([math]::Round($size, 2)) KB`n" -ForegroundColor Gray
}
