# 更新日志

## 1.1.0 - 2026-02-14

### 新功能
- `add-skill.ps1` - PowerShell 原生版添加技能脚本（Windows 用户）
- `create-skill.sh` - Bash 版创建技能脚本（跨平台支持）

### 改进
- **中心化架构**：所有脚本现在遵循 `~/.agents/skills/` 中心仓库模式
  - `create-skill.ps1` - 先在 `~/.agents/skills/` 创建，再通过 Junction 映射到助手
  - `delete-skill.ps1` - 三步清理：删除 Junction → 删除源文件 → 更新 lock 文件
  - `list-skills.ps1` - 扫描中心仓库，标注 Junction 为 `[链接]`
  - `search-skills.ps1` - 优先搜索中心仓库，支持去重
  - `backup-skill.ps1` - 新增 `-Source` 参数（agents/claude/all，默认 agents）
  - `describe-skill.ps1` - 查找时优先搜索 `~/.agents/skills/`
  - `update-description.ps1` - 查找时优先搜索 `~/.agents/skills/`
- **Windows Junction 支持**：`add-skill.sh` 自动检测 Windows 并使用 `New-Item -ItemType Junction`
- **SKILL.md** - 强化中心化存储原则指引，添加 Windows 注意事项
- 所有脚本支持三级目录搜索：`.agents/skills/` > `.claude/skills/` > 市场目录

### 修复
- 修复 `add-skill.sh` 在 Windows 上因 `ln -sf` 需要管理员权限而导致符号链接创建失败的问题

## 1.0.0 - 2026-01-31

### 新功能
- Skills Manager 首次发布
- 支持 37+ AI 助手
- 双语文档支持 (英文/简体中文)
- 完整的技能管理脚本套件
