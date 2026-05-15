---
name: git-guardrails
description: Set up git safety guardrails to block dangerous git commands (push, reset --hard, clean, branch -D, etc.) before they execute. Supports Claude Code and opencode. Use when user wants to prevent destructive git operations or add git safety hooks.
---

# Setup Git Guardrails

Sets up guards that intercept and block dangerous git commands before they execute.

## What Gets Blocked

- `git push` (all variants including `--force`)
- `git reset --hard`
- `git clean -f` / `git clean -fd`
- `git branch -D`
- `git checkout .` / `git restore .`

When blocked, the agent sees a message telling it that it does not have authority to access these commands.

## Steps

### 1. Ask platform

Ask the user: which platform are you using — **Claude Code** or **opencode**?

### 2. Ask scope

Ask the user: install for **this project only** or **all projects**?

Scope paths per platform:

| | Project | Global |
|---|---------|--------|
| **Claude Code** | `.claude/settings.json` | `~/.claude/settings.json` |
| **opencode** | `./opencode.json` | `~/.config/opencode/opencode.json` |

### 3. Claude Code setup

#### 3a. Copy the hook script

The bundled script is at: [scripts/block-dangerous-git.sh](scripts/block-dangerous-git.sh)

Copy it to the target location based on scope:

- **Project**: `.claude/hooks/block-dangerous-git.sh`
- **Global**: `~/.claude/hooks/block-dangerous-git.sh`

Make it executable with `chmod +x`.

#### 3b. Add hook to settings

Add to the appropriate settings file:

**Project** (`.claude/settings.json`):

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/block-dangerous-git.sh"
          }
        ]
      }
    ]
  }
}
```

**Global** (`~/.claude/settings.json`):

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/block-dangerous-git.sh"
          }
        ]
      }
    ]
  }
}
```

If the settings file already exists, merge the hook into existing `hooks.PreToolUse` array — don't overwrite other settings.

#### 3c. Verify

Run a quick test:

```bash
echo '{"tool_input":{"command":"git push origin main"}}' | <path-to-script>
```

Should exit with code 2 and print a BLOCKED message to stderr.

### 4. opencode setup

#### 4a. Add permission rules

Add the following to the appropriate config file (project `opencode.json` or global `~/.config/opencode/opencode.json`):

```json
{
  "permission": {
    "bash": {
      "*": "ask",
      "git push": "deny",
      "git push *": "deny",
      "git reset --hard *": "deny",
      "git clean -f*": "deny",
      "git clean -fd*": "deny",
      "git branch -D *": "deny",
      "git checkout .": "deny",
      "git restore .": "deny"
    }
  }
}
```

**Important:** opencode evaluates the LAST matching rule. The broad catch-all (`"*": "ask"`) must come first, and the specific deny rules must come last. If the catch-all were last, it would override all deny rules.

If the config file already exists, merge the `permission.bash` rules into the existing config. Prepend any new deny rules before the existing catch-all (if present), keeping the catch-all as the first entry.

#### 4b. Remind user to restart

opencode loads config once at startup. Tell the user to **quit and restart opencode** for the changes to take effect.

### 5. Ask about customization

Ask if the user wants to add or remove any patterns from the blocked list.

For Claude Code: edit the copied `block-dangerous-git.sh` script.
For opencode: add or remove entries from the `permission.bash` rules in `opencode.json`.
