# Skills Manager - 列出所有已安装的 Skills

$agentsSkillsDir = "$env:USERPROFILE\.agents\skills"
$skillsDir = "$env:USERPROFILE\.claude\skills"
$marketSkillsDir = "$env:USERPROFILE\.claude\plugins\marketplaces\anthropic-agent-skills\skills"

Write-Host "`n=== Claude Code Skills 列表 ===`n" -ForegroundColor Cyan

# 中心仓库 (.agents)
if (Test-Path $agentsSkillsDir) {
    Write-Host "[中心仓库] $agentsSkillsDir`n" -ForegroundColor Green

    Get-ChildItem $agentsSkillsDir -Directory | ForEach-Object {
        $skillPath = $_.FullName
        $skillMd = Join-Path $skillPath "SKILL.md"

        if (Test-Path $skillMd) {
            $content = Get-Content $skillMd -Raw
            if ($content -match 'description:\s*(.+?)\n') {
                $desc = $matches[1].Trim()
                Write-Host "  [$($_.Name)]" -ForegroundColor Yellow
                Write-Host "    $desc`n"
            } else {
                Write-Host "  [$($_.Name)]`n" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  [$($_.Name)] (无 SKILL.md)`n" -ForegroundColor Gray
        }
    }
} else {
    Write-Host "[中心仓库] $agentsSkillsDir (不存在)`n" -ForegroundColor Gray
}

# 主技能目录
if (Test-Path $skillsDir) {
    Write-Host "[主技能目录] $skillsDir`n" -ForegroundColor Green

    Get-ChildItem $skillsDir -Directory | ForEach-Object {
        $skillPath = $_.FullName
        $skillMd = Join-Path $skillPath "SKILL.md"

        # 检测是否为 Junction/符号链接
        $isLink = $_.Attributes -band [System.IO.FileAttributes]::ReparsePoint
        $linkTag = if ($isLink) { " [链接]" } else { "" }

        if (Test-Path $skillMd) {
            $content = Get-Content $skillMd -Raw
            if ($content -match 'description:\s*(.+?)\n') {
                $desc = $matches[1].Trim()
                Write-Host "  [$($_.Name)]$linkTag" -ForegroundColor Yellow
                Write-Host "    $desc`n"
            } else {
                Write-Host "  [$($_.Name)]$linkTag`n" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  [$($_.Name)]$linkTag (无 SKILL.md)`n" -ForegroundColor Gray
        }
    }
}

# 市场技能目录
if (Test-Path $marketSkillsDir) {
    Write-Host "[市场技能目录] $marketSkillsDir`n" -ForegroundColor Green

    Get-ChildItem $marketSkillsDir -Directory | ForEach-Object {
        $skillPath = $_.FullName
        $skillMd = Join-Path $skillPath "SKILL.md"

        if (Test-Path $skillMd) {
            $content = Get-Content $skillMd -Raw
            if ($content -match 'description:\s*(.+?)\n') {
                $desc = $matches[1].Trim()
                Write-Host "  [$($_.Name)]" -ForegroundColor Yellow
                Write-Host "    $desc`n"
            } else {
                Write-Host "  [$($_.Name)]`n" -ForegroundColor Yellow
            }
        }
    }
}
