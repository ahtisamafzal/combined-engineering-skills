# Combined Engineering Skills

Karpathy behavioral principles + Pocock engineering workflow skills, packaged as a single installable skill set for **Claude Code** and **opencode**.

## What's Included

### Always-On Principles (4)

These are active in every conversation without any command:

1. **Think Before Coding** — Don't assume. Surface tradeoffs. Ask when uncertain.
2. **Simplicity First** — Minimum code that solves the problem. Nothing speculative.
3. **Surgical Changes** — Touch only what you must. Clean up only your own mess.
4. **Goal-Driven Execution** — Define success criteria. Loop until verified.

### Slash Commands (16)

#### Engineering (12)

| Skill | What It Does |
|-------|-------------|
| `/diagnose` | Disciplined diagnosis loop for hard bugs and performance regressions |
| `/git-guardrails` | Block dangerous git commands (push, reset --hard, clean, branch -D) |
| `/grill-with-docs` | Grilling session that challenges your plan against domain model and docs |
| `/improve-codebase-architecture` | Find deepening opportunities informed by domain language and ADRs |
| `/prototype` | Build a throwaway prototype to flesh out a design |
| `/setup-combined-skills` | Scaffold per-repo config (issue tracker, triage labels, domain docs) |
| `/setup-pre-commit` | Set up Husky + lint-staged + Prettier pre-commit hooks |
| `/tdd` | Test-driven development with red-green-refactor loop |
| `/to-issues` | Break a plan into independently-grabbable issues using vertical slices |
| `/to-prd` | Turn conversation context into a PRD and publish to issue tracker |
| `/triage` | Triage issues through a state machine driven by triage roles |
| `/zoom-out` | Get broader context or a higher-level perspective on code |

#### Productivity (4)

| Skill | What It Does |
|-------|-------------|
| `/caveman` | Ultra-compressed communication mode (~75% fewer tokens) |
| `/grill-me` | Relentless interview about a plan or design |
| `/handoff` | Compact conversation into a handoff document for another agent |
| `/write-a-skill` | Create new agent skills with proper structure |

## How They Work Together

| Karpathy Principle | Pocock Skill | How They Reinforce Each Other |
|-------------------|--------------|-------------------------------|
| Think Before Coding | grill-me, grill-with-docs | When uncertain, interview rather than assume |
| Simplicity First | to-issues, tdd | Vertical slicing keeps each slice minimal |
| Surgical Changes | zoom-out, improve-codebase-architecture | Understand context first; deepen modules surgically |
| Goal-Driven Execution | tdd, diagnose, setup-pre-commit | Automated verification loops on every commit |

## Supported Platforms

| Platform | Always-on file | Skill discovery |
|----------|---------------|-----------------|
| Claude Code | `CLAUDE.md` | `SKILL.md` + `plugin.json` |
| opencode | `AGENTS.md` | `SKILL.md` in `~/.agents/skills/` |

## First-Time Setup

After installation, run `/setup-combined-skills` in your project to configure the issue tracker, triage labels, and domain doc layout. This only needs to be done once per project.

## Installation

### Claude Code

```bash
npx skills@latest add ./path/to/combined-skills
```

### opencode

1. Copy skills to `~/.agents/skills/combined-engineering-skills/` (opencode auto-loads from this directory):
   ```bash
   cp -r skills/ ~/.agents/skills/combined-engineering-skills/skills/
   ```

2. Copy `AGENTS.md` to your project root or reference it in `opencode.json`:
   ```json
   {
     "$schema": "https://opencode.ai/config.json",
     "instructions": ["AGENTS.md"]
   }
   ```

3. Restart opencode for changes to take effect.

## Verify Installation

1. Start a new conversation
2. The agent should surface assumptions before coding (Karpathy principle)
3. Try `/grill-me` — it should activate and start interviewing you
4. Try `/setup-combined-skills` — it should walk through issue tracker configuration

## Uninstall

### Claude Code

Remove the skill set from your Claude Code configuration:

```bash
npx skills@latest remove combined-engineering-skills
```

### opencode

Remove the skills directory and clean up `AGENTS.md` reference:

```bash
rm -rf ~/.agents/skills/combined-engineering-skills/
```

Then remove the `instructions` entry from your `opencode.json` or delete `AGENTS.md` from your project root.

## What Was Excluded

| Category | Items | Reason |
|----------|-------|--------|
| Personal skills | edit-article, obsidian-vault | Matt's personal setup |
| Misc skill | scaffold-exercises | Matt's specific course tooling (pnpm ai-hero-cli) |
| Deprecated skills | design-an-interface, qa, request-refactor-plan, ubiquitous-language | No longer maintained |
| In-progress skills | review, writing-beats, writing-fragments, writing-shape | Not yet ready |
| Personal tooling | migrate-to-shoehorn | Matt's personal tooling |

## Updates

This skill set tracks two upstream sources:
- **Pocock skills**: `https://github.com/mattpocock/skills`
- **Karpathy guidelines**: Karpathy's behavioral principles for AI coding

To update, re-copy from upstream sources and re-apply the find-and-replace changes from the implementation plan in `docs/IMPLEMENTATION-PLAN.md`.

## Why Combine These?

Karpathy's principles govern **how** the agent behaves (caution, simplicity, precision). Pocock's skills define **what** workflows are available (grill, triage, diagnose, architect). Together they create an agent that is both well-behaved and well-equipped.
