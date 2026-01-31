---
strategy: b
name: 极客硬核型 (信息密集)
style: notion
style_reason: "黑白极简线条，符合技术工具的专业感，突出'映射'这一技术概念。"
elements:
  background: grid
  decorations: [code-brackets, terminal-icon, flow-lines]
  emphasis: underline
  typography: monospace
layout: dense
image_count: 4
---

## P1 封面
**Type**: cover
**Hook**: "AI 技能管理：为什么你应该用 Symlink 而不是 Copy？"
**Visual**: 极简风格的架构图，一行代码 `ln -sf source target` 作为背景装饰。
**Layout**: sparse

## P2 原理深度解析
**Type**: educational
**Message**: "Copy vs Symlink：底层逻辑的区别"
**Content**: 
- **传统模式 (CC Switch)**：物理复制文件。占用双倍空间，IO 开销大，版本不一致。
- **Skills Manager**：符号链接 (Symbolic Links)。文件实体只存一份，系统级指针引用。
- **优势**：
  1. 空间占用 ≈ 0
  2. 实时热更新
  3. 集中化 Git 管理
**Visual**: 左右分栏对比表，清晰的技术参数对比。
**Layout**: comparison

## P3 全生命周期管理
**Type**: feature
**Message**: "不仅是分发，更是管理"
**Content**: 
- **Create**: 一键生成标准模版
- **Backup**: 自动打包备份
- **Search**: 全局关键词搜索
- **Describe**: 智能解析技能用途
**Visual**: 终端截图展示 `list-skills` 和 `describe-skill` 的输出结果。
**Layout**: list

## P4 安装与使用
**Type**: tutorial
**Message**: "一行命令，开启高效管理"
**Content**: 
- 安装：`npx skills add pxb988/skills-manager`
- 使用：直接对 Claude 说 "帮我添加这个技能..."
- 仓库：GitHub @pxb988/skills-manager
**Visual**: 代码块展示安装命令，配合简单的流程图。
**Layout**: balanced
