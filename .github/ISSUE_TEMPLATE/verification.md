##  Purpose

This issue is for community members to help verify which AI coding assistants work with Skills Manager. Your feedback will help us:

- Confirm which assistants are actually working
- Update the documentation with accurate information
- Improve compatibility for more assistants

---

##  How to Verify

### Step 1: Check if an assistant is installed

```bash
# Run this command to see which assistants are on your system
ls -d ~/.claude ~/.codex ~/.cursor ~/.gemini ~/.kiro ~/.trae ~/.codeium/windsurf 2>/dev/null
```

### Step 2: Test with dry-run

```bash
# Preview what would happen
bash path/to/skills-manager/scripts/add-skill.sh --dry-run ./test-skill
```

### Step 3: Report your results

Comment below with your OS and which assistants work for you!

---

##  Pre-configured Assistants

### Already Verified
- Claude Code, Codex, Cursor, Gemini CLI, Kiro, Trae, Windsurf, OpenCode, Antigravity

### Awaiting Verification
Cline, CodeBuddy, CommandCode, Continue, Crush, Droid, Goose, Junie, Kilo, Kode, MCPJam, Mux, OpenHands, Pi, Qoder, Qwen Code, Roo, Trae CN, Zencoder, OpenClaude, Neovate, Pochi, Amp, Kimi CLI, MoltBot, GitHub Copilot

---

##  Additional Assistants?

If you use an AI coding assistant not on this list, please let us know!

**Thank you for helping improve Skills Manager!**
