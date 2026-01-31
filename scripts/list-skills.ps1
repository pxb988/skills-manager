# Skills Manager - 列出所有已安装的 Skills

$skillsDir = "$env:USERPROFILE\.claude\skills"
$marketSkillsDir = "$env:USERPROFILE\.claude\plugins\marketplaces\anthropic-agent-skills\skills"

Write-Host "`n=== Claude Code Skills 列表 ===`n" -ForegroundColor Cyan

# 主技能目录
if (Test-Path $skillsDir) {
    Write-Host "[主技能目录] $skillsDir`n" -ForegroundColor Green

    Get-ChildItem $skillsDir -Directory | ForEach-Object {
        $skillPath = $_.FullName
        $skillMd = Join-Path $skillPath "SKILL.md"

        if (Test-Path $skillMd) {
            # 读取 YAML frontmatter
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
