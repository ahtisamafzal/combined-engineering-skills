# Maintainer's Guide

Everything you need to sync upstream changes, add new skills, and install across all three platforms without re-discovering the gotchas.

---

## 1. Sync from Upstream Pocock

Source: `C:\Projects\01.Helper-Projects\mattpocock\skills` (local clone of `https://github.com/mattpocock/skills`)

```powershell
# Pull latest upstream
cd C:\Projects\01.Helper-Projects\mattpocock\skills
git pull origin main
```

### Diff all skills

Run this to find every file that differs between upstream and combined-skills:

```powershell
$mapping = @(
  # Format: @{ src = '<upstream path>'; dst = '<combined path>'; rename = $false },
  #
  # --- Engineering ---
  @{ src = 'skills\engineering\diagnose';                           dst = 'skills\engineering\diagnose' },
  @{ src = 'skills\engineering\grill-with-docs';                    dst = 'skills\engineering\grill-with-docs' },
  @{ src = 'skills\engineering\improve-codebase-architecture';      dst = 'skills\engineering\improve-codebase-architecture' },
  @{ src = 'skills\engineering\prototype';                          dst = 'skills\engineering\prototype' },
  @{ src = 'skills\engineering\tdd';                                dst = 'skills\engineering\tdd' },
  @{ src = 'skills\engineering\to-issues';                          dst = 'skills\engineering\to-issues' },
  @{ src = 'skills\engineering\to-prd';                             dst = 'skills\engineering\to-prd' },
  @{ src = 'skills\engineering\triage';                             dst = 'skills\engineering\triage' },
  @{ src = 'skills\engineering\zoom-out';                           dst = 'skills\engineering\zoom-out' },
  @{ src = 'skills\engineering\setup-matt-pocock-skills';           dst = 'skills\engineering\setup-combined-skills'; rename = $true },
  # --- Misc → Engineering ---
  @{ src = 'skills\misc\git-guardrails-claude-code';                dst = 'skills\engineering\git-guardrails'; rewritten = $true },
  @{ src = 'skills\misc\setup-pre-commit';                          dst = 'skills\engineering\setup-pre-commit' },
  # --- Productivity ---
  @{ src = 'skills\productivity\caveman';                           dst = 'skills\productivity\caveman' },
  @{ src = 'skills\productivity\grill-me';                          dst = 'skills\productivity\grill-me' },
  @{ src = 'skills\productivity\handoff';                           dst = 'skills\productivity\handoff' },
  @{ src = 'skills\productivity\write-a-skill';                     dst = 'skills\productivity\write-a-skill' }
)

$upstreamRoot = 'C:\Projects\01.Helper-Projects\mattpocock\skills'
$combinedRoot = 'C:\Projects\01.Helper-Projects\combined-skills'

foreach ($m in $mapping) {
  $srcDir  = Join-Path $upstreamRoot $m.src
  $dstDir  = Join-Path $combinedRoot $m.dst
  $files   = Get-ChildItem $srcDir -File -Recurse
  foreach ($f in $files) {
    $rel    = $f.FullName.Substring($srcDir.Length + 1)
    $srcF   = $f.FullName
    $dstF   = Join-Path $dstDir $rel
    if (-not (Test-Path $dstF)) {
      Write-Output "NEW FILE: $($m.dst)\$rel"
      continue
    }
    $diff = Compare-Object (Get-Content $srcF) (Get-Content $dstF)
    if ($diff) {
      $tag = if ($m.rename) { " (RENAMED)" } elseif ($m.rewritten) { " (REWRITTEN)" } else { "" }
      Write-Output "DIFFERS: $($m.dst)\$rel$tag"
    }
  }
}
```

### Apply upstream changes

For each file that differs, there are three cases:

| Case | Action |
|------|--------|
| **Plain copy** (no rename, no rewrite) | Copy upstream file over combined file |
| **Renamed skill** (`setup-combined-skills`) | Copy upstream, then re-apply find-and-replace: `setup-matt-pocock-skills` → `setup-combined-skills`, `Matt Pocock's Skills` → `Combined Skills`, plus add the one-line principles note |
| **Rewritten skill** (`git-guardrails`) | Read upstream diff, manually merge changes into the dual-platform combined version. Do NOT blindly overwrite |

After applying changes:

1. Grep the entire `skills/` directory for `matt-pocock` and `Matt Pocock` — must return zero results
2. Verify all supporting files (scripts, reference .md files) are present in both upstream and combined

### Check for new upstream files

```powershell
# Compare file lists — find files in upstream that combined-skills is missing
foreach ($m in $mapping) {
  $srcDir = Join-Path $upstreamRoot $m.src
  $dstDir = Join-Path $combinedRoot $m.dst
  $srcFiles = Get-ChildItem $srcDir -File -Recurse | ForEach-Object { $_.FullName.Substring($srcDir.Length + 1) }
  $dstFiles = Get-ChildItem $dstDir -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName.Substring($dstDir.Length + 1) }
  foreach ($f in $srcFiles) {
    if ($dstFiles -notcontains $f) { Write-Output "MISSING: $($m.dst)\$f" }
  }
}
```

---

## 2. Add a New Skill

### Checklist

- [ ] Source skill copied to `skills/engineering/<name>/` or `skills/productivity/<name>/`
- [ ] `SKILL.md` has frontmatter with `name:` and `description:` (required by opencode)
- [ ] `name` matches directory name exactly, lowercase, hyphens only (`^[a-z0-9]+(-[a-z0-9]+)*$`)
- [ ] Supporting files (scripts, reference .md) copied alongside `SKILL.md`
- [ ] No references to `matt-pocock`, `Matt Pocock`, or `setup-matt-pocock-skills` — run grep
- [ ] Entry added to `.claude-plugin/plugin.json` skills array
- [ ] Entry added to `skills/engineering/README.md` or `skills/productivity/README.md`
- [ ] Entry added to top-level `README.md` table (engineering or productivity section)
- [ ] Skill count updated in README.md (currently 16)

### opencode-specific: create a command file

opencode skills are invisible in the `/` menu. Each skill needs a companion command file so users can type `/<skill-name>` and see it listed.

Create `~/.config/opencode/commands/<skill-name>.md`:

```markdown
---
description: <one-line description matching SKILL.md>
---
Load the skill "<skill-name>" using the skill tool and follow its instructions. $ARGUMENTS
```

This is the bridge that makes skills discoverable in opencode's slash command menu.

---

## 3. Install / Reinstall

All commands run from the combined-skills repo root.

### Step 1: Commit and push

```powershell
git add -A
git commit -m "Sync upstream: <description of changes>"
git push origin master
```

### Step 2: Install via npx skills

```powershell
# Project-level (for all agents in this project)
cd C:\Projects\01.Helper-Projects
npx skills@latest add ahtisamafzal/combined-engineering-skills --all

# Global (for all agents across all projects)
npx skills@latest add ahtisamafzal/combined-engineering-skills --global --all
```

### Step 3: opencode — create junction links

`npx skills` installs to `~/.agents/skills/` but opencode primarily discovers from `~/.config/opencode/skills/`. Create junction links for any new skills:

```powershell
$skillName = '<new-skill-name>'
$src = "C:\Users\ahti_\.agents\skills\$skillName"
$dst = "C:\Users\ahti_\.config\opencode\skills\$skillName"
if (-not (Test-Path $dst)) {
  New-Item -ItemType Junction -Path $dst -Target $src -Force
}
```

### Step 4: Verify

```powershell
# Check global skills
npx skills@latest list --global

# Check opencode junction links
Get-ChildItem 'C:\Users\ahti_\.config\opencode\skills' -Directory | ForEach-Object { $_.Name }

# Check opencode commands
Get-ChildItem 'C:\Users\ahti_\.config\opencode\commands' -Filter '*.md' | ForEach-Object { $_.BaseName }
```

Restart opencode, Claude Code, and VS Code for changes to take effect.

---

## 4. Platform Gotchas

### opencode: skills ≠ commands

| Concept | How it works | Where it lives |
|---------|-------------|----------------|
| **Skills** | Loaded on-demand via `skill` tool; invisible in `/` menu | `~/.config/opencode/skills/<name>/SKILL.md` |
| **Commands** | Appear in `/` menu as slash commands | `~/.config/opencode/commands/<name>.md` |

Every skill needs a companion command file. Without it, the user cannot discover or invoke the skill via the slash menu.

### opencode: directory discovery

opencode scans 6 paths for `*/SKILL.md`:

| Scope | Path |
|-------|------|
| Project | `.opencode/skills/<name>/SKILL.md` |
| Project (Claude-compat) | `.claude/skills/<name>/SKILL.md` |
| Project (agent-compat) | `.agents/skills/<name>/SKILL.md` |
| Global | `~/.config/opencode/skills/<name>/SKILL.md` |
| Global (Claude-compat) | `~/.claude/skills/<name>/SKILL.md` |
| Global (agent-compat) | `~/.agents/skills/<name>/SKILL.md` |

`npx skills` writes to `~/.agents/skills/` (universal) and `~/.claude/skills/` (Claude). Neither is opencode's primary path. Junction links to `~/.config/opencode/skills/` are required.

### npx skills: lock file warning

`npx skills add` replaces `~/.agents/.skill-lock.json`. Previously installed skills from other sources may be removed. Check with `npx skills list --global` afterward and reinstall any lost skills.

### git-guardrails: dual-platform

This skill was rewritten to support both Claude Code (shell hooks) and opencode (permission rules). Do NOT blindly copy from upstream — upstream only supports Claude Code. Merge changes manually.

### setup-combined-skills: renamed + modified

This skill is `setup-matt-pocock-skills` upstream but renamed to `setup-combined-skills` here, with a one-line note about Karpathy principles being active by default. After copying upstream changes, re-apply the find-and-replace:

| Old (upstream) | New (combined) |
|----------------|----------------|
| `setup-matt-pocock-skills` | `setup-combined-skills` |
| `Matt Pocock's Skills` | `Combined Skills` |
| `# Setup Matt Pocock's Skills` | `# Setup Combined Skills` + blank line + one-line principles note |

---

## 5. File Inventory

Current files that require special handling (not plain copies):

| File | Treatment |
|------|-----------|
| `skills/engineering/git-guardrails/SKILL.md` | Rewritten for dual-platform (Claude Code + opencode). Do NOT overwrite from upstream. |
| `skills/engineering/setup-combined-skills/SKILL.md` | Renamed + one-line principles note added. Re-apply find-and-replace after upstream copy. |
| `skills/engineering/to-issues/SKILL.md` | Contains `/setup-combined-skills` reference (intentional rename from upstream). |
| `skills/engineering/to-prd/SKILL.md` | Same as to-issues. |
| `skills/engineering/triage/SKILL.md` | Same as to-issues. |

All other skill files are verbatim copies from upstream and can be overwritten safely.
