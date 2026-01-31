# Skills Manager - 创建新 Skill

param(
    [Parameter(Mandatory=$true)]
    [string]$Name,

    [Parameter(Mandatory=$true)]
    [string]$Description,

    [string[]]$Tags = @("custom"),
    [string]$License = "MIT"
)

$skillsDir = "$env:USERPROFILE\.claude\skills"
$skillPath = Join-Path $skillsDir $Name

# 检查是否已存在
if (Test-Path $skillPath) {
    Write-Host "错误: Skill '$Name' 已存在" -ForegroundColor Red
    exit 1
}

# 创建目录
New-Item -ItemType Directory -Path $skillPath -Force | Out-Null

# 创建 SKILL.md 模板
$tagsYaml = $tags | ForEach-Object { "  - $_" } | Out-String
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
Write-Host "位置: $skillPath`n" -ForegroundColor Gray
Write-Host "下一步: 编辑 SKILL.md 来完善技能配置`n" -ForegroundColor Yellow
