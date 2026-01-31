# Skills Manager

> A powerful skill management tool for sharing and managing skills across AI coding assistants.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Skills CLI](https://img.shields.io/badge/skills-cli-blue.svg)](https://www.npmjs.com/package/@anthropics/skills-cli)

[English](./README.md) | [简体中文](./README.zh-CN.md)

## Introduction

Skills Manager is a comprehensive toolkit for managing skills for AI coding assistants. It not only allows you to distribute skills to all supported AI assistants but also provides full local skill lifecycle management, including creating, searching, backing up, listing, and describing skills.

**Core Value:**
- **Install Once, Use Everywhere**: Add skills to the `.agents` system, automatically mapping them to all supported AI assistants.
- **Full Lifecycle Management**: Provides one-stop management tools for creating, searching, backing up, and deleting skills.
- **Dual Interaction Modes**: Supports natural language interaction (via Claude Code) and command-line script execution.
- **Flexible Configuration**: Supports local paths, GitHub repositories, Git URLs, and private repository access.

## Supported AI Assistants

Skills Manager comes pre-configured with directory mappings for 37+ popular AI coding assistants. The script automatically detects which assistants are installed on your system and creates symlinks only for those available.

**Verified Assistants** (tested and confirmed working):
- Claude Code (`~/.claude/skills/`)
- Codex (`~/.codex/skills/`)
- Cursor (`~/.cursor/skills/`)
- Gemini CLI (`~/.gemini/skills/`)
- Kiro (`~/.kiro/skills/`)
- Trae (`~/.trae/skills/`)
- Windsurf (`~/.codeium/windsurf/skills/`)
- OpenCode (`~/.config/opencode/skills/`)
- Antigravity (`~/.gemini/antigravity/global_skills`)

**Pre-configured Support** (mappings included, awaiting verification):
- Cline, CodeBuddy, CommandCode, Continue, Crush, Droid, Goose, Junie, Kilo, Kode
- MCPJam, Mux, OpenHands, Pi, Qoder, Qwen Code, Roo, Trae CN
- Zencoder, OpenClaude, Neovate, Pochi, Amp, Kimi CLI
- MoltBot, GitHub Copilot, and more...

> **Note**: The actual number of assistants that will receive skills depends on which tools you have installed on your system. Run `add-skill.sh --dry-run` to see which assistants will be targeted.

## Installation

### Method 1: Install as a Claude Code Skill (Recommended)

First, ensure you have installed this skill into Claude Code so you can manage skills using natural language:

```bash
# Method 1: Install directly from GitHub
npx skills add pxb988/skills-manager

# Method 2: Install from local path
npx skills add F:\Github\skills-manager
```

### Method 2: Use as a Local Toolkit

If you prefer to run scripts directly in the terminal, you can clone the repository locally:

```bash
# Clone the repository
git clone https://github.com/your-username/skills-manager.git
cd skills-manager

# It is recommended to add the scripts directory to your PATH environment variable
```

## Usage: Natural Language Interaction (Recommended)

Once installed, **Skills Manager works as a Skill**, allowing you to manage all skills by conversing with Claude Code in natural language.

#### Basic Management
- **Add Skill**: "Add my-awesome-skill" or "Add owner/repo from GitHub"
- **List Skills**: "List all installed skills"
- **Search Skills**: "Search for skills related to PDF"
- **Describe Skill**: "Describe what my-awesome-skill does" or "Introduce the features of skill-seekers"

#### Maintenance Operations
- **Create Skill**: "Create a new skill template named my-new-skill"
- **Backup Skills**: "Backup all skills" or "Backup my-awesome-skill"
- **Delete Skill**: "Delete the old test-skill"
- **Edit Skill**: "Edit the description of skill-seekers"

## Usage: Command Line Scripts

In addition to natural language, you can also directly run scripts located in the `scripts/` directory.

### 1. Install/Add Skill (`add-skill.sh`)

The core script for installing skills into the `.agents` system and distributing them.

```bash
# Automatically identifies GitHub repository, Git URL, or local path
add-skill.sh [OPTIONS] <source>
```

**Examples:**
```bash
add-skill.sh anthropics/skills                  # GitHub repository
add-skill.sh ./my-custom-skill                  # Local path
add-skill.sh owner/repo --agent claude-code     # Install only to Claude Code
add-skill.sh owner/repo --dry-run               # Preview mode
add-skill.sh private/repo --github-token <tok>  # Private repository
```

### 2. Skill Management Tools (PowerShell)

Provides a rich set of PowerShell scripts for daily maintenance.

#### List Skills (`list-skills.ps1`)
Lists all skills and their brief descriptions in the main skill directory and marketplace skill directory.
```powershell
.\scripts\list-skills.ps1
```

#### Search Skills (`search-skills.ps1`)
Searches for keywords in skill names, descriptions, and content.
```powershell
.\scripts\search-skills.ps1 -Keyword "pdf"
```

#### Create New Skill (`create-skill.ps1`)
Quickly generates a skill template containing a standard `SKILL.md`.
```powershell
.\scripts\create-skill.ps1 -Name "my-new-skill" -Description "This is a test skill" -Tags "test","demo"
```

#### Backup Skills (`backup-skill.ps1`)
Packages skills into a ZIP file. If no name is specified, all skills are backed up.
```powershell
# Backup all skills
.\scripts\backup-skill.ps1

# Backup a specific skill
.\scripts\backup-skill.ps1 -Name "my-awesome-skill"
```

#### Describe Skill (`describe-skill.ps1`)
Reads and displays the content of `SKILL.md` to help understand skill details.
```powershell
.\scripts\describe-skill.ps1 -Name "skills-manager"
```

#### Delete Skill (`delete-skill.ps1`)
Safely deletes a skill and its associated symbolic links (use with caution).
```powershell
.\scripts\delete-skill.ps1 -Name "unused-skill"
```

## How It Works

Skills Manager uses a centralized storage strategy:

1.  **Unified Storage**: All skills are installed to `~/.agents/skills/<skill-name>/`.
2.  **State Locking**: `.skill-lock.json` records the source, version, and installation time of each skill.
3.  **Smart Distribution**: The script automatically scans AI assistant directories in the system (such as `~/.claude/skills`, `~/.cursor/skills`, etc.) and creates symbolic links pointing to the centralized storage.

This design ensures that when you update a skill, all AI assistants can immediately use the latest version without disrupting the configuration of each assistant.

## Directory Structure

```
~/.agents/
├── skills/
│   ├── skill-1/          # Actual skill storage location
│   └── ...
└── .skill-lock.json      # Skill metadata record
```

## License

MIT License - See [LICENSE](LICENSE) file for details.

## Contribution

Issues and Pull Requests are welcome! We especially welcome support for more AI assistants and suggestions for new features.

## Acknowledgements

- Inspired by [Skill Seekers](https://github.com/yusufkaraaslan/Skill_Seekers)
- Based on [Anthropic Skills CLI](https://github.com/anthropics/skills) specification
