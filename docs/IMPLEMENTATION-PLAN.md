# Implementation Plan: Combined Engineering Skills

Combines Karpathy behavioral principles with Pocock workflow skills into a single installable skill set for **Claude Code and opencode**.

## What We're Building

- 16 invokable workflow skills (slash commands)
- 2 always-on behavioral overlay files (`CLAUDE.md` + `AGENTS.md`, identical content)
- 1 repo management file (`CONTRIBUTING.md`)
- Supporting reference files for skills that need them

## Architecture

| Layer | Source | Purpose |
|-------|--------|---------|
| CLAUDE.md / AGENTS.md | Karpathy | Always-on behavioral guardrails (verbatim 4 principles) |
| Engineering skills (12) | Pocock | Code workflow commands |
| Productivity skills (4) | Pocock | Non-code workflow commands |

Karpathy governs HOW the agent behaves (caution, simplicity, precision).
Pocock defines WHAT workflows are available (grill, triage, diagnose, architect).

## Target Platforms

| Platform | Always-on file | Skill format | Hook mechanism |
|----------|---------------|--------------|----------------|
| Claude Code | `CLAUDE.md` | `SKILL.md` + `plugin.json` | `.claude/settings.json` PreToolUse hooks |
| opencode | `AGENTS.md` | `SKILL.md` in `~/.agents/skills/` | Permission rules in `opencode.json` or plugin hooks |

## Final Folder Structure

```
combined-skills/
├── .claude-plugin/
│   └── plugin.json
├── CLAUDE.md
├── AGENTS.md
├── CONTRIBUTING.md
├── README.md
├── docs/
│   └── IMPLEMENTATION-PLAN.md
│
├── skills/
│   ├── engineering/
│   │   ├── README.md
│   │   ├── diagnose/
│   │   │   ├── SKILL.md
│   │   │   └── scripts/
│   │   │       └── hitl-loop.template.sh
│   │   │
│   │   ├── git-guardrails/
│   │   │   ├── SKILL.md
│   │   │   └── scripts/
│   │   │       └── block-dangerous-git.sh
│   │   │
│   │   ├── grill-with-docs/
│   │   │   ├── SKILL.md
│   │   │   ├── ADR-FORMAT.md
│   │   │   └── CONTEXT-FORMAT.md
│   │   │
│   │   ├── improve-codebase-architecture/
│   │   │   ├── SKILL.md
│   │   │   ├── DEEPENING.md
│   │   │   ├── INTERFACE-DESIGN.md
│   │   │   └── LANGUAGE.md
│   │   │
│   │   ├── prototype/
│   │   │   ├── SKILL.md
│   │   │   ├── LOGIC.md
│   │   │   └── UI.md
│   │   │
│   │   ├── setup-combined-skills/
│   │   │   ├── SKILL.md
│   │   │   ├── domain.md
│   │   │   ├── issue-tracker-github.md
│   │   │   ├── issue-tracker-gitlab.md
│   │   │   ├── issue-tracker-local.md
│   │   │   └── triage-labels.md
│   │   │
│   │   ├── setup-pre-commit/
│   │   │   └── SKILL.md
│   │   │
│   │   ├── tdd/
│   │   │   ├── SKILL.md
│   │   │   ├── deep-modules.md
│   │   │   ├── interface-design.md
│   │   │   ├── mocking.md
│   │   │   ├── refactoring.md
│   │   │   └── tests.md
│   │   │
│   │   ├── to-issues/
│   │   │   └── SKILL.md
│   │   │
│   │   ├── to-prd/
│   │   │   └── SKILL.md
│   │   │
│   │   ├── triage/
│   │   │   ├── SKILL.md
│   │   │   ├── AGENT-BRIEF.md
│   │   │   └── OUT-OF-SCOPE.md
│   │   │
│   │   └── zoom-out/
│   │       └── SKILL.md
│   │
│   └── productivity/
│       ├── README.md
│       ├── caveman/
│       │   └── SKILL.md
│       ├── grill-me/
│       │   └── SKILL.md
│       ├── handoff/
│       │   └── SKILL.md
│       └── write-a-skill/
│           └── SKILL.md
```

## Implementation Steps

### Step 1: Clean Up Existing Empty Folders — **DONE**

Remove folders that don't belong in the final structure:

```
skills/core/              (empty, no source equivalent)
skills/misc/              (skills moved to engineering/ or excluded)
```

**Verification:** `skills/core/` and `skills/misc/` no longer exist.

### Step 2: Copy Pocock Skills — **DONE**

Copy all files from the source directories. Each skill folder and all its supporting files must be copied as-is.

Source paths (all under `C:\Projects\01.Helper-Projects\mattpocock\skills\skills\`):

> **Note:** These paths are local copies. For reproducibility, the upstream repos are:
> - Pocock skills: `https://github.com/mattpocock/skills`
> - Karpathy guidelines: `https://github.com/anthropics/claude-code-skills` (or the Karpathy-specific fork at `C:\Projects\01.Helper-Projects\andrej-karpathy\skills`)

| Skill | Source | Destination | Files to Copy |
|-------|--------|-------------|---------------|
| diagnose | `engineering\diagnose\` | `engineering\diagnose\` | SKILL.md, scripts\hitl-loop.template.sh |
| grill-with-docs | `engineering\grill-with-docs\` | `engineering\grill-with-docs\` | SKILL.md, ADR-FORMAT.md, CONTEXT-FORMAT.md |
| improve-codebase-architecture | `engineering\improve-codebase-architecture\` | `engineering\improve-codebase-architecture\` | SKILL.md, DEEPENING.md, INTERFACE-DESIGN.md, LANGUAGE.md |
| prototype | `engineering\prototype\` | `engineering\prototype\` | SKILL.md, LOGIC.md, UI.md |
| setup-matt-pocock-skills | `engineering\setup-matt-pocock-skills\` | `engineering\setup-combined-skills\` | SKILL.md, domain.md, issue-tracker-github.md, issue-tracker-gitlab.md, issue-tracker-local.md, triage-labels.md |
| tdd | `engineering\tdd\` | `engineering\tdd\` | SKILL.md, deep-modules.md, interface-design.md, mocking.md, refactoring.md, tests.md |
| to-issues | `engineering\to-issues\` | `engineering\to-issues\` | SKILL.md |
| to-prd | `engineering\to-prd\` | `engineering\to-prd\` | SKILL.md |
| triage | `engineering\triage\` | `engineering\triage\` | SKILL.md, AGENT-BRIEF.md, OUT-OF-SCOPE.md |
| zoom-out | `engineering\zoom-out\` | `engineering\zoom-out\` | SKILL.md |
| setup-pre-commit | `misc\setup-pre-commit\` | `engineering\setup-pre-commit\` | SKILL.md |
| git-guardrails-claude-code | `misc\git-guardrails-claude-code\` | `engineering\git-guardrails\` | SKILL.md (as reference only), scripts\block-dangerous-git.sh |
| caveman | `productivity\caveman\` | `productivity\caveman\` | SKILL.md |
| grill-me | `productivity\grill-me\` | `productivity\grill-me\` | SKILL.md |
| handoff | `productivity\handoff\` | `productivity\handoff\` | SKILL.md |
| write-a-skill | `productivity\write-a-skill\` | `productivity\write-a-skill\` | SKILL.md |

**Verification:** All 16 skill folders exist under `skills\engineering\` (12) and `skills\productivity\` (4). Each has at minimum a SKILL.md. Supporting files are present where listed above.

### Step 3: Write CLAUDE.md and AGENTS.md — **DONE**

Copy the **verbatim** Karpathy principles from `C:\Projects\01.Helper-Projects\andrej-karpathy\skills\CLAUDE.md` into both files. No additions, no modifications.

The content must be exactly:
1. Header: "CLAUDE.md" (or "AGENTS.md" for the opencode version)
2. Intro paragraph ("Behavioral guidelines to reduce common LLM coding mistakes...")
3. Tradeoff note
4. Principle 1: Think Before Coding
5. Principle 2: Simplicity First
6. Principle 3: Surgical Changes
7. Principle 4: Goal-Driven Execution
8. Success criteria footer

**Critical rules:**
- No domain awareness section
- No scope clause
- No first-time setup section
- No slash-command references
- No modifications to the original Karpathy text

**Verification:**
- `CLAUDE.md` and `AGENTS.md` have identical content (except the header line)
- No occurrences of `/` followed by a skill name
- Content matches original Karpathy CLAUDE.md verbatim

### Step 4: Write CONTRIBUTING.md — **DONE**

Extract the repo management instructions from Pocock's original `CLAUDE.md` into a separate file.

Content:
- Skills bucket structure (`engineering/`, `productivity/`)
- Every skill must have a reference in `README.md` and `plugin.json`
- Each skill entry in `README.md` links skill name to its `SKILL.md`
- Each bucket folder has a `README.md` listing every skill with a one-line description

Source: `C:\Projects\01.Helper-Projects\mattpocock\skills\CLAUDE.md`

**Verification:** CONTRIBUTING.md exists and contains bucket structure rules. CLAUDE.md and AGENTS.md do NOT contain these rules.

### Step 5: Rewrite git-guardrails Skill — **DONE**

The copied `git-guardrails-claude-code` skill only supports Claude Code. Rewrite `engineering\git-guardrails\SKILL.md` to support **both platforms** with a branching setup flow.

**Skill structure:**

```
1. Ask which platform: Claude Code or opencode
2. Ask scope: project-only or global
3. Branch to platform-specific setup:
   a. Claude Code: copy shell script hook, add to .claude/settings.json (existing logic)
   b. opencode: add permission rules to opencode.json config
4. Ask about customization
5. Verify
```

**Claude Code path** (unchanged from original):
- Copy `scripts/block-dangerous-git.sh` to `.claude/hooks/` or `~/.claude/hooks/`
- Add `PreToolUse` hook to `.claude/settings.json` or `~/.claude/settings.json`

**opencode path** (new):
- Add permission rules to project `opencode.json` or `~/.config/opencode/opencode.json`:

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

**Note:** opencode evaluates the LAST matching rule, so broad rules go first (`"*": "ask"`) and narrow deny rules go last. If the catch-all were last, it would override all deny rules.

- If settings file exists, merge into existing `permission.bash` rules — don't overwrite
- Remind user to restart opencode for config to take effect

**Frontmatter:**
```yaml
---
name: git-guardrails
description: Set up git safety hooks to block dangerous git commands (push, reset --hard, clean, branch -D, etc.) before they execute. Supports Claude Code and opencode. Use when user wants to prevent destructive git operations or add git safety guardrails.
---
```

**Verification:**
- Skill name is `git-guardrails` (no platform suffix)
- Both platform paths are documented
- opencode path uses permission rules, not shell scripts
- Claude Code path is unchanged from original
- `scripts/block-dangerous-git.sh` is present for Claude Code path

### Step 6: Find-and-Replace Stale References — **DONE**

Several copied files contain references to the old setup skill name. These must be updated.

**Replace in these files:**

| File | Old String | New String |
|------|-----------|------------|
| `engineering\triage\SKILL.md` | `/setup-matt-pocock-skills` | `/setup-combined-skills` |
| `engineering\to-prd\SKILL.md` | `/setup-matt-pocock-skills` | `/setup-combined-skills` |
| `engineering\to-issues\SKILL.md` | `/setup-matt-pocock-skills` | `/setup-combined-skills` |
| `engineering\setup-combined-skills\SKILL.md` | `setup-matt-pocock-skills` (in name, description, headings, body) | `setup-combined-skills` |
| `engineering\setup-combined-skills\SKILL.md` | `Matt Pocock's Skills` | `Combined Skills` |
| `engineering\setup-combined-skills\SKILL.md` | `setup-matt-pocock-skills` (in frontmatter name) | `setup-combined-skills` |

**Verification:** Grep the entire `skills\` directory for `matt-pocock` and `Matt Pocock` — should return zero results.

### Step 7: Update setup-combined-skills SKILL.md — **DONE**

Based on the original `setup-matt-pocock-skills/SKILL.md` with these changes:

1. Frontmatter `name:` changed to `setup-combined-skills`
2. Frontmatter `description:` updated to reference "Combined Skills"
3. Heading changed from "Setup Matt Pocock's Skills" to "Setup Combined Skills"
4. Intro paragraph updated to say "combined skills" instead of "Matt Pocock's"
5. Add a one-line note: "Engineering principles (Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution) are active by default and require no configuration."
6. All body references to `setup-matt-pocock-skills` changed to `setup-combined-skills`
7. Section D for principles config — do NOT add (principles need no per-project configuration)
8. All other sections (A: Issue tracker, B: Triage labels, C: Domain docs) remain unchanged

**Verification:** Diff the new file against the original. Changes should be limited to name/description swaps and the one-line note addition. No structural changes.

### Step 8: Create plugin.json — **DONE**

```json
{
  "name": "combined-engineering-skills",
  "description": "Karpathy behavioral principles + Pocock engineering workflow skills",
  "version": "1.0.0",
  "skills": [
    "./skills/engineering/diagnose",
    "./skills/engineering/git-guardrails",
    "./skills/engineering/grill-with-docs",
    "./skills/engineering/improve-codebase-architecture",
    "./skills/engineering/prototype",
    "./skills/engineering/setup-combined-skills",
    "./skills/engineering/setup-pre-commit",
    "./skills/engineering/tdd",
    "./skills/engineering/to-issues",
    "./skills/engineering/to-prd",
    "./skills/engineering/triage",
    "./skills/engineering/zoom-out",
    "./skills/productivity/caveman",
    "./skills/productivity/grill-me",
    "./skills/productivity/handoff",
    "./skills/productivity/write-a-skill"
  ]
}
```

**Verification:** Count entries = 16. All paths match actual folder locations.

### Step 9: Create Bucket READMEs — **DONE**

Create `skills/engineering/README.md` and `skills/productivity/README.md`.

Each lists every skill in the bucket with a one-line description, skill name linked to its `SKILL.md`.

**Verification:** Both README files exist. Each skill folder has a corresponding entry.

### Step 10: Create README.md — **DONE**

Sections to include:

1. **What's Included** — list of 4 principles (always-on) + 16 slash commands
2. **How They Work Together** — synergy table (see below)
3. **Supported Platforms** — Claude Code and opencode
4. **First-Time Setup** — run the setup skill
5. **Installation** — Claude Code path and opencode path
6. **Verify Installation** — how to test
7. **Uninstall** — removal instructions
8. **What Was Excluded** — table of skipped skills with reasons
9. **Updates** — note about tracking two upstreams
10. **Why Combine These?** — brief rationale

**Synergy table:**

| Karpathy Principle | Pocock Skill | How They Reinforce Each Other |
|-------------------|--------------|-------------------------------|
| Think Before Coding | grill-me, grill-with-docs | When uncertain, interview rather than assume |
| Simplicity First | to-issues, tdd | Vertical slicing keeps each slice minimal |
| Surgical Changes | zoom-out, improve-codebase-architecture | Understand context first; deepen modules surgically |
| Goal-Driven Execution | tdd, diagnose, setup-pre-commit | Automated verification loops on every commit |

**Verification:** README contains no slash-command references in behavioral descriptions. Skill count is 16 everywhere.

### Step 11: Final Verification — **DONE**

All checks passed:

| Check | Result |
|-------|--------|
| All 16 skill folders exist | PASS |
| All supporting files present | PASS |
| No stale references | PASS |
| CLAUDE.md and AGENTS.md exist | PASS |
| CLAUDE.md = AGENTS.md | PASS |
| CONTRIBUTING.md exists | PASS |
| plugin.json has 16 entries | PASS |
| plugin.json paths match folders | PASS |
| setup-combined-skills has one-line note | PASS |
| git-guardrails has dual-platform content | PASS |
| Bucket READMEs exist | PASS |
| No core/ or misc/ folders | PASS |

### Step 12: Installation — **DONE**

**For Claude Code:**
```bash
npx skills@latest add --yes --global
```
Claude Code installation working via plugin cache at `~/.claude/plugins/cache/`.

**For opencode:**

> **Critical: opencode requires skills to be published to GitHub and installed via `npx skills add`. Local-path installation does NOT work.**

```bash
# 1. Initialize git repo and push to GitHub
git init
git add -A
git commit -m "Initial commit"
gh repo create combined-engineering-skills --public --push

# 2. Install globally via npx skills
npx skills@latest add <github-org>/combined-engineering-skills --global --yes
```

opencode discovers skills from these global locations (per [docs](https://opencode.ai/docs/skills/)):
- `~/.config/opencode/skills/<name>/SKILL.md` (primary)
- `~/.agents/skills/<name>/SKILL.md` (agent-compatible)
- `~/.claude/skills/<name>/SKILL.md` (Claude-compatible)

Skills are loaded on-demand via the `skill` tool — not listed as slash commands.

**What was tried and failed:**
- Flat copy to `~/.agents/skills/` — files on disk but not loaded without lock registration
- Manual `.skill-lock.json` entries with `sourceType: "local"` — silently ignored by opencode
- `skills.paths` in `opencode.json` — confirmed ineffective
- `npx skills add` with local path — installs Claude Code side but doesn't update `.skill-lock.json`

**What worked:**
- Push to GitHub, then `npx skills add <org>/<repo> --global` — properly registers in `.skill-lock.json` with `sourceType: "github"`

**Side effect:** `npx skills add` replaces `.skill-lock.json` contents. Previously installed skills (emil-design-eng, find-skills, microsoft-foundry) were displaced and had to be reinstalled from their original sources:
- `emilkowalski/skill@emil-design-eng`
- `vercel-labs/skills@find-skills`
- `microsoft/azure-skills@microsoft-foundry`

### Step 13: Smoke Test — **PENDING**

After installation, verify on **both platforms**:

1. `/grill-me` activates in a conversation
2. `/caveman` activates and changes communication style
3. The agent surfaces assumptions before coding (Karpathy principle)
4. `/setup-combined-skills` walks through issue tracker configuration
5. `/setup-pre-commit` installs Husky + lint-staged
6. `/git-guardrails` asks which platform and sets up appropriate hooks/permissions

## Design Decisions Log

| Decision | Choice | Why |
|----------|--------|-----|
| Target platforms | Claude Code + opencode | Two most common AI coding assistants; multi-platform support from day one |
| Always-on files | CLAUDE.md + AGENTS.md (identical content) | Each platform reads its own file; zero adaptation needed |
| Karpathy principles location | Always-on files only, not invokable skill | Principles must be always-on, not triggered on demand |
| CLAUDE.md/AGENTS.md content | Verbatim Karpathy principles only | Clean signal, no noise. Domain awareness lives in grill-with-docs. Setup is a separate skill. |
| Repo management instructions | CONTRIBUTING.md, not always-on file | Only relevant when editing the skill set, not when using it |
| Domain awareness | In grill-with-docs skill only | Not every project has CONTEXT.md/ADRs; only relevant during grilling |
| First-time setup section | Not in always-on file | setup-combined-skills handles this as an invokable skill; no proactive nagging |
| git-guardrails | One skill, dual-platform paths | Same concept ("block dangerous git ops"), different mechanism per platform |
| git-guardrails naming | `git-guardrails` (no platform suffix) | Platform is chosen at setup time, not at install time |
| setup-pre-commit | Included, in engineering/ | Generally useful JS/TS tooling that reinforces Goal-Driven Execution |
| setup-combined-skills | Independent from git-guardrails and setup-pre-commit | Project config vs tooling vs safety are separate concerns; monolithic setup is harder to skip |
| misc/core folders | Removed | No valid skills to put there; avoids confusion about scope |
| Section D in setup | Not added | Principles need no per-project configuration |
| CONTEXT.md at root | Not created | CONTEXT.md is per-project, not per-skill-set |
| Skill count | 16 | 12 engineering + 4 productivity |
| Bucket READMEs | Included | Help humans browse the repo; make gaps visible during verification |
| Source format | Local file copy, not git submodule | Easier customization; track upstream repos separately for updates |
| GitHub publishing required | opencode only loads skills from GitHub-sourced installs | All local-path approaches silently fail; `.skill-lock.json` requires `sourceType: "github"` |

## Lessons Learned

### opencode Installation Requires GitHub

opencode's skill loading is gated by `~/.agents/.skill-lock.json`. Only skills with `sourceType: "github"` are loaded. Every local-path approach was tested and failed:

| Approach | Result |
|----------|--------|
| Flat copy to `~/.agents/skills/<name>/` | Files present but ignored without lock registration |
| Manual `.skill-lock.json` with `sourceType: "local"` | Silently ignored by opencode at runtime |
| `skills.paths` in `opencode.json` | Config key recognized but does not affect skill discovery |
| `npx skills add ./local/path --global` | Installs to Claude Code but does not update `.skill-lock.json` |

The only working path: publish to GitHub, then `npx skills add <org>/<repo> --global`.

### `npx skills add` Replaces Lock File

Running `npx skills add` replaces the entire `.skill-lock.json`, not just adds to it. Any previously installed skills are removed. Always reinstall existing skills afterward.

### Skills Are On-Demand, Not Slash Commands

opencode skills are loaded via the `skill` tool when the agent decides they're relevant. They don't appear in the `/` command menu. Users interact by asking the agent to use a skill, not by typing a command.

### Windows Junction Links Work for Skill Discovery

opencode discovers skills via directory scanning (`skills/*/SKILL.md`). On Windows, junction links (not symlinks, which need admin) work correctly for this. The `npx skills` tool uses copies by default on Windows.

### `gh` CLI Not Pre-installed

The GitHub CLI (`gh`) was not installed on the target system. It was installed via `winget install --id GitHub.cli`. Authentication requires browser-based device flow (`gh auth login --web`).

## What Was Excluded

| Category | Items | Reason |
|----------|-------|--------|
| Personal skills | edit-article, obsidian-vault | Matt's personal setup |
| Misc skill | scaffold-exercises | Matt's specific course tooling (pnpm ai-hero-cli) |
| Deprecated skills | design-an-interface, qa, request-refactor-plan, ubiquitous-language | No longer maintained |
| In-progress skills | review, writing-beats, writing-fragments, writing-shape | Not yet ready |
| migrate-to-shoehorn | migrate-to-shoehorn | Matt's personal tooling |
