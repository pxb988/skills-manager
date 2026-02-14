# Skills Manager - 搜索 Skills

param(
    [Parameter(Mandatory=$true)]
    [string]$Keyword
)

$agentsSkillsDir = "$env:USERPROFILE\.agents\skills"
$skillsDir = "$env:USERPROFILE\.claude\skills"
$marketSkillsDir = "$env:USERPROFILE\.claude\plugins\marketplaces\anthropic-agent-skills\skills"

Write-Host "`n=== 搜索结果: '$Keyword' ===`n" -ForegroundColor Cyan

# 已显示的技能名称（用于去重）
$displayedSkills = @{}

function Search-InDirectory($dir, $dirName) {
    if (!(Test-Path $dir)) { return }

    $found = $false

    Get-ChildItem $dir -Directory | ForEach-Object {
        $skillPath = $_.FullName
        $skillMd = Join-Path $skillPath "SKILL.md"

        # 搜索名称
        $nameMatch = $_.Name -like "*$Keyword*"

        # 搜索描述
        $descMatch = $false
        $desc = ""
        if (Test-Path $skillMd) {
            $content = Get-Content $skillMd -Raw
            if ($content -match 'description:\s*(.+?)\n') {
                $desc = $matches[1].Trim()
                $descMatch = $desc -like "*$Keyword*"
            }
        }

        # 搜索内容
        $contentMatch = $false
        if (Test-Path $skillMd) {
            $content = Get-Content $skillMd -Raw
            $contentMatch = $content -like "*$Keyword*"
        }

        if ($nameMatch -or $descMatch -or $contentMatch) {
            # 去重：如果已在中心仓库显示过，跳过
            if ($script:displayedSkills.ContainsKey($_.Name)) {
                return
            }
            $script:displayedSkills[$_.Name] = $true

            if (!$found) {
                Write-Host "[$dirName]" -ForegroundColor Green
                $found = $true
            }

            $matchReason = if ($nameMatch) { "名称" } else { if ($descMatch) { "描述" } else { "内容" } }
            Write-Host "  [$($_.Name)] - 匹配: $matchReason" -ForegroundColor Yellow
            if ($desc) {
                Write-Host "    $desc`n" -ForegroundColor White
            } else {
                Write-Host ""
            }
        }
    }
}

# 搜索顺序：中心仓库 > 主技能目录 > 市场技能目录
Search-InDirectory $agentsSkillsDir "中心仓库 (.agents)"
Search-InDirectory $skillsDir "主技能目录"
Search-InDirectory $marketSkillsDir "市场技能目录"
