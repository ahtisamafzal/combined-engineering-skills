<#
.SYNOPSIS
    Sync combined-skills from upstream Pocock repo and install across all platforms.

.DESCRIPTION
    Phase 1: Pull upstream, diff, auto-copy safe files, flag manual-merge files.
    Phase 2 (run with -Install): Commit, push, install via npx skills, fix opencode paths.

.PARAMETER Install
    Run Phase 2 after reviewing Phase 1 changes. Requires git push confirmation.

.PARAMETER Verbose
    Show detailed diff output.

.EXAMPLE
    .\sync-and-install.ps1            # Phase 1 only: sync + report
    .\sync-and-install.ps1 -Install   # Phase 1 + Phase 2: sync + install everything
#>

param(
    [switch]$Install,
    [switch]$VerboseOutput,
    [string]$CommitMessage = "Sync upstream Pocock skills"
)

$ErrorActionPreference = "Continue"

$UpstreamRoot  = "C:\Projects\01.Helper-Projects\mattpocock\skills"
$CombinedRoot  = "C:\Projects\01.Helper-Projects\combined-skills"
$OpenCodeSkills = "C:\Users\ahti_\.config\opencode\skills"
$OpenCodeCmds   = "C:\Users\ahti_\.config\opencode\commands"
$GithubRepo     = "ahtisamafzal/combined-engineering-skills"

# --- Skill mapping ---
# type: 'copy' = safe to overwrite, 'rename' = needs find-and-replace after copy,
#       'rewrite' = manual merge only (never auto-copy)
$SkillMapping = @(
  # Engineering (straight copies)
  @{ src = "skills\engineering\diagnose";                      dst = "skills\engineering\diagnose";                      type = "copy" },
  @{ src = "skills\engineering\grill-with-docs";               dst = "skills\engineering\grill-with-docs";               type = "copy" },
  @{ src = "skills\engineering\improve-codebase-architecture"; dst = "skills\engineering\improve-codebase-architecture"; type = "copy" },
  @{ src = "skills\engineering\prototype";                     dst = "skills\engineering\prototype";                     type = "copy" },
  @{ src = "skills\in-progress\review";                        dst = "skills\engineering\review";                        type = "copy" },
  @{ src = "skills\engineering\tdd";                           dst = "skills\engineering\tdd";                           type = "copy" },
  @{ src = "skills\engineering\to-issues";                     dst = "skills\engineering\to-issues";                     type = "copy" },
  @{ src = "skills\engineering\to-prd";                        dst = "skills\engineering\to-prd";                        type = "copy" },
  @{ src = "skills\engineering\triage";                        dst = "skills\engineering\triage";                        type = "copy" },
  @{ src = "skills\engineering\zoom-out";                      dst = "skills\engineering\zoom-out";                      type = "copy" },
  # Misc -> Engineering
  @{ src = "skills\misc\setup-pre-commit";                     dst = "skills\engineering\setup-pre-commit";              type = "copy" },
  # Renamed skill (needs find-and-replace after copy)
  @{ src = "skills\engineering\setup-matt-pocock-skills";      dst = "skills\engineering\setup-combined-skills";         type = "rename" },
  # Rewritten skill (manual merge only)
  @{ src = "skills\misc\git-guardrails-claude-code";           dst = "skills\engineering\git-guardrails";                type = "rewrite" },
  # Productivity (straight copies)
  @{ src = "skills\productivity\caveman";                      dst = "skills\productivity\caveman";                      type = "copy" },
  @{ src = "skills\productivity\grill-me";                     dst = "skills\productivity\grill-me";                     type = "copy" },
  @{ src = "skills\productivity\handoff";                      dst = "skills\productivity\handoff";                      type = "copy" },
  @{ src = "skills\productivity\write-a-skill";                dst = "skills\productivity\write-a-skill";                type = "copy" }
)

function Write-Header($text) {
  Write-Output ""
  Write-Output "============================================"
  Write-Output "  $text"
  Write-Output "============================================"
}

function Write-Status($icon, $msg) {
  Write-Output "  $($icon) $msg"
}

function Convert-RenamedSkillContent([string]$content) {
  $updated = $content
  $updated = $updated -replace 'setup-matt-pocock-skills', 'setup-combined-skills'
  $updated = $updated -replace "Matt Pocock's Skills", 'Combined Skills'
  $updated = $updated -replace "# Setup Matt Pocock's Skills", "# Setup Combined Skills"

  $principlesNote = "Engineering principles (Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution) are active by default and require no configuration."
  if ($updated -match '(?m)^# Setup Combined Skills\s*$' -and $updated -notmatch [regex]::Escape($principlesNote)) {
    $updated = $updated -replace '(?m)^# Setup Combined Skills\s*$', "# Setup Combined Skills`r`n`r`n$principlesNote"
  }

  return $updated
}

function Copy-RenamedSkillFile([string]$srcF, [string]$dstF) {
  $dir = Split-Path $dstF -Parent
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }

  $raw = Get-Content -LiteralPath $srcF -Raw
  $converted = Convert-RenamedSkillContent $raw
  Set-Content -LiteralPath $dstF -Value $converted -NoNewline
}

# ============================================================
# PHASE 1: SYNC
# ============================================================

Write-Header "PHASE 1: Sync from upstream"

# --- Pull upstream ---
Write-Output "Pulling upstream Pocock repo..."
Push-Location $UpstreamRoot
git pull origin main 2>&1 | Select-String -NotMatch "^From " | ForEach-Object { Write-Output "  $($_.ToString().Trim())" }
Pop-Location

# --- Diff and categorize ---
Write-Header "Diffing skills"

$autoCopied     = @()
$newFiles       = @()
$manualRequired = @()
$unchanged      = 0

foreach ($m in $SkillMapping) {
  $srcDir = Join-Path $UpstreamRoot $m.src
  $dstDir = Join-Path $CombinedRoot $m.dst

  if (-not (Test-Path $srcDir)) {
    Write-Status "?" "Source missing: $($m.src)"
    continue
  }

  $srcFiles = Get-ChildItem $srcDir -File -Recurse

  foreach ($f in $srcFiles) {
    $rel  = $f.FullName.Substring($srcDir.Length + 1)
    $srcF = $f.FullName
    $dstF = Join-Path $dstDir $rel

    # New file (doesn't exist in combined)
    if (-not (Test-Path $dstF)) {
      $newFiles += @{ src = $srcF; dst = $dstF; rel = "$($m.dst)\$rel"; type = $m.type }
      Write-Status "+" "NEW: $($m.dst)\$rel"
      continue
    }

    # Compare content
    $diff = Compare-Object (Get-Content $srcF) (Get-Content $dstF)
    if (-not $diff) {
      $unchanged++
      continue
    }

    # File differs
    switch ($m.type) {
      "copy" {
        # Safe to auto-copy
        Copy-Item -LiteralPath $srcF -Destination $dstF -Force
        $autoCopied += @{ rel = "$($m.dst)\$rel"; type = "copy" }
        Write-Status "`u{2713}" "COPIED: $($m.dst)\$rel"
      }
      "rename" {
        Copy-RenamedSkillFile -srcF $srcF -dstF $dstF
        $autoCopied += @{ rel = "$($m.dst)\$rel"; type = "rename" }
        Write-Status "`u{2713}" "COPIED+RENAMED: $($m.dst)\$rel"
      }
      "rewrite" {
        $manualRequired += @{ rel = "$($m.dst)\$rel"; type = "rewrite"; src = $srcF; dst = $dstF }
        Write-Status "!" "MANUAL (rewrite): $($m.dst)\$rel"
      }
    }
  }
}

# --- Auto-copy new files (safe ones only) ---
if ($newFiles.Count -gt 0) {
  Write-Header "New files from upstream"
  foreach ($nf in $newFiles) {
    $dir = Split-Path $nf.dst -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }

    switch ($nf.type) {
      "copy" {
        Copy-Item -LiteralPath $nf.src -Destination $nf.dst -Force
        Write-Status "`u{2713}" "COPIED: $($nf.rel)"
        $autoCopied += @{ rel = $nf.rel; type = "new" }
      }
      "rename" {
        Copy-RenamedSkillFile -srcF $nf.src -dstF $nf.dst
        Write-Status "`u{2713}" "COPIED+RENAMED: $($nf.rel)"
        $autoCopied += @{ rel = $nf.rel; type = "rename-new" }
      }
      "rewrite" {
        Write-Status "!" "MANUAL (rewrite): $($nf.rel) - merge manually"
        $manualRequired += $nf
      }
    }
  }
}

# --- Stale reference check + auto-fix ---
Write-Header "Checking and fixing stale references"
$staleRefs = @()
$staleFixed = 0
Get-ChildItem "$CombinedRoot\skills" -Filter "*.md" -Recurse | ForEach-Object {
  $content = Get-Content $_.FullName -Raw
  if ($content -match "matt-pocock|Matt Pocock|setup-matt-pocock") {
    $relPath = $_.FullName.Substring($CombinedRoot.Length + 1)

    # Auto-fix: apply find-and-replace
    $fixed = $content
    $fixed = $fixed -replace 'setup-matt-pocock-skills', 'setup-combined-skills'
    $fixed = $fixed -replace "Matt Pocock's Skills", 'Combined Skills'
    $fixed = $fixed -replace "# Setup Matt Pocock's Skills", "# Setup Combined Skills"
    Set-Content -LiteralPath $_.FullName -Value $fixed -NoNewline

    # Re-check after fix
    $recheck = Get-Content $_.FullName -Raw
    if ($recheck -match "matt-pocock|Matt Pocock|setup-matt-pocock") {
      $staleRefs += $relPath
      Write-Status "!" "STALE (still has refs after auto-fix): $relPath"
    } else {
      $staleFixed++
      Write-Status "`u{2713}" "FIXED: $relPath"
    }
  }
}
if ($staleRefs.Count -eq 0 -and $staleFixed -eq 0) {
  Write-Status "`u{2713}" "No stale references found"
} elseif ($staleFixed -gt 0) {
  Write-Output "  Auto-fixed: $staleFixed files"
}

# --- Summary ---
Write-Header "Phase 1 Summary"
Write-Output "  Unchanged:    $unchanged files"
Write-Output "  Auto-copied:  $($autoCopied.Count) files"
Write-Output "  New files:    $($newFiles.Count) found"
Write-Output "  Manual merge: $($manualRequired.Count) files"
Write-Output "  Stale refs:   $($staleRefs.Count) remaining ($staleFixed auto-fixed)"

if ($manualRequired.Count -gt 0) {
  Write-Output ""
  Write-Output "  Files needing manual review:"
  foreach ($mr in $manualRequired) {
    Write-Output "    [$($mr.type)] $($mr.rel)"
  }
}

if ($staleRefs.Count -gt 0) {
  Write-Output ""
  Write-Output "  Files still stale after auto-fix (need manual edit):"
  foreach ($ref in $staleRefs) {
    Write-Output "    $ref"
  }
}

# --- Stop here if no Install flag ---
if (-not $Install) {
  Write-Output ""
  Write-Output "Review changes above. When ready, re-run with -Install flag."
  exit 0
}

# ============================================================
# PHASE 2: INSTALL
# ============================================================

Write-Header "PHASE 2: Install"

# --- Commit and push ---
Write-Output "Checking for uncommitted changes..."
Push-Location $CombinedRoot
$status = git status --porcelain 2>&1
if ($status) {
  Write-Output "  Uncommitted changes found. Committing..."
  git add -A 2>&1 | Select-String -NotMatch "^$" | ForEach-Object { Write-Output "  $($_.ToString().Trim())" }
  git commit -m $CommitMessage 2>&1 | Select-String -NotMatch "^$" | ForEach-Object { Write-Output "  $($_.ToString().Trim())" }
  Write-Output "  Pushing to GitHub..."
  git push origin master 2>&1 | Select-String -NotMatch "^(From|remote:)" | ForEach-Object { Write-Output "  $($_.ToString().Trim())" }
} else {
  Write-Status "`u{2713}" "No uncommitted changes"
}
Pop-Location

# --- npx skills install ---
Write-Header "Installing via npx skills"

Write-Output "  Project-level install..."
Push-Location (Split-Path $CombinedRoot -Parent)
npx skills@latest add $GithubRepo --all 2>&1 | ForEach-Object { Write-Output "  $_" }
Pop-Location

Write-Output "  Global install..."
npx skills@latest add $GithubRepo --global --all 2>&1 | ForEach-Object { Write-Output "  $_" }

# --- opencode: ensure junction links ---
Write-Header "Fixing opencode skill paths"

$globalAgentsSkills = "C:\Users\ahti_\.agents\skills"
$skillDirs = Get-ChildItem $globalAgentsSkills -Directory -ErrorAction SilentlyContinue

$junctionsCreated = 0
$junctionsExisting = 0

foreach ($dir in $skillDirs) {
  $name = $dir.Name
  $target = Join-Path $OpenCodeSkills $name
  if (-not (Test-Path $target)) {
    New-Item -ItemType Junction -Path $target -Target $dir.FullName -Force | Out-Null
    Write-Status "+" "Junction: $name"
    $junctionsCreated++
  } else {
    $junctionsExisting++
  }
}
Write-Output "  Created: $junctionsCreated | Existing: $junctionsExisting"

# --- opencode: generate command files ---
Write-Header "Generating opencode command files"

$commandsCreated = 0
$commandsUpdated = 0

foreach ($dir in $skillDirs) {
  $name = $dir.Name
  $skillMd = Join-Path $dir.FullName "SKILL.md"
  if (-not (Test-Path $skillMd)) { continue }

  # Extract description from frontmatter
  $content = Get-Content $skillMd -Raw
  if ($content -notmatch '(?s)^---\s*\n.*?description:\s*(.+?)(\n|$).*?---') { continue }
  $desc = $Matches[1].Trim()

  # Build command file content
  $cmdContent = @"
---
description: $desc
---
Load the skill "$name" using the skill tool and follow its instructions. `$ARGUMENTS
"@

  $cmdPath = Join-Path $OpenCodeCmds "$name.md"
  if (-not (Test-Path $cmdPath)) {
    Set-Content -LiteralPath $cmdPath -Value $cmdContent -NoNewline
    Write-Status "+" "Command: /$name"
    $commandsCreated++
  } else {
    $existing = Get-Content $cmdPath -Raw
    if ($existing -ne $cmdContent) {
      Set-Content -LiteralPath $cmdPath -Value $cmdContent -NoNewline
      Write-Status "~" "Updated: /$name"
      $commandsUpdated++
    }
  }
}
Write-Output "  Created: $commandsCreated | Updated: $commandsUpdated"

# --- Final verification ---
Write-Header "Verification"

$opencodeSkills = (Get-ChildItem $OpenCodeSkills -Directory -ErrorAction SilentlyContinue).Count
$opencodeCmds   = (Get-ChildItem $OpenCodeCmds -Filter "*.md" -ErrorAction SilentlyContinue).Count
Write-Output "  opencode skills dir:   $opencodeSkills entries"
Write-Output "  opencode commands dir: $opencodeCmds entries"

Write-Output ""
Write-Output "Done. Restart opencode, Claude Code, and VS Code for changes to take effect."
