# Copilot Instructions for combined-skills

This repository combines curated skills from upstream sources. Follow this workflow by default.

## Primary Sources of Truth

Before making changes, read:
- README.md
- AGENTS.md
- CLAUDE.md
- docs/MAINTAINER-GUIDE.md

## Default Maintenance Workflow

When asked to sync or compare with upstream Matt Pocock skills:

1. Run phase 1 sync from repository root:

```powershell
.\scripts\sync-and-install.ps1
```

2. Summarize what changed:
- auto-copied files
- manual-merge files
- stale-reference fixes

3. Do not run install phase unless user wants install/reinstall.

4. If requested, run install phase:

```powershell
.\scripts\sync-and-install.ps1 -Install
```

## Guardrails for This Repo

- Do not blindly overwrite `skills/engineering/git-guardrails/SKILL.md`.
  - This file is intentionally customized for dual-platform behavior (Claude Code + opencode).
  - Manually merge upstream changes when needed.

- `setup-combined-skills` is a renamed upstream skill.
  - The sync script now handles rename transforms automatically.

- Preserve user edits and unrelated local changes.
  - Only touch files required by the request.

## When Adding or Updating Skills

- Keep skill indexes and discovery files in sync when applicable:
  - .claude-plugin/plugin.json
  - skills/engineering/README.md or skills/productivity/README.md
  - top-level README.md skill tables/counts

- Ensure no stale references remain:
  - `setup-matt-pocock-skills`
  - `Matt Pocock`
  - `matt-pocock`

## Response Expectations

- Be explicit about what was auto-updated vs what still needs manual review.
- Prefer script-first operations over ad-hoc file copying.
- Keep changes surgical and aligned to the request.
