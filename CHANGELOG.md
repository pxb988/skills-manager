# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2026-01-31

### Added
- Initial release of Skills Manager
- **Core Features**:
  - `add-skill.sh` - Install skills from local/GitHub/Git to .agents system
  - `list-skills.ps1` - List all installed skills
  - `describe-skill.ps1` - View detailed skill information
  - `create-skill.ps1` - Create new skill templates
  - `delete-skill.ps1` - Safely remove skills
  - `search-skills.ps1` - Search skills by keywords
  - `backup-skill.ps1` - Backup skills to ZIP archives
  - `update-description.ps1` - Update skill descriptions
- **Multi-Agent Support**: Automatic symlink creation for 35+ AI coding assistants
- **Flexible Installation**:
  - Support for local paths, GitHub repositories (owner/repo), and Git URLs
  - Target specific agent with `--agent` flag
  - Preview mode with `--dry-run`
  - Force overwrite with `--force`
  - Private repository support with `--github-token`
- **Documentation**:
  - Bilingual README (English/Chinese)
  - Natural language usage guide
  - Complete command-line reference
  - Skill specification documentation

### Supported AI Assistants
Claude Code, Codex, Cursor, Gemini CLI, Kiro, Trae, Windsurf, Cline, CodeBuddy, CommandCode, Continue, Crush, Droid, Goose, Junie, Kilo, Kode, MCPJam, Mux, OpenCode, OpenHands, Pi, Qoder, Qwen Code, Roo, Trae CN, Zencoder, OpenClaude, Neovate, Pochi, Amp, Antigravity, Kimi CLI, MoltBot, GitHub Copilot, and more...

[1.0.0]: https://github.com/pxb988/skills-manager/releases/tag/v1.0.0
