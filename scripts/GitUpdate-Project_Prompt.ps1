<#
.SYNOPSIS
Update Project_Prompt.md

.DESCRIPTION
Safe, narrow automation that stages, commits, and pushes Project_Prompt.md.
This version auto-detects the repository root by walking up from this script's
directory until it finds a `.git` folder. You may also provide -RepoPath.

.PARAMETER RepoPath
Optional explicit path to the repository root. If omitted, the script will
auto-detect the root by searching parent directories for `.git`.

.PARAMETER Message
Commit message to use. Defaults to a timestamped message.
#>

[CmdletBinding()]
param(
  [Parameter(Mandatory=$false)]
  [string]$RepoPath,

  [Parameter(Mandatory=$false)]
  [string]$Message
)

function Fail([string]$msg) {
  Write-Error $msg
  exit 1
}

function Find-GitRoot([string]$startPath) {
  $p = (Resolve-Path -LiteralPath $startPath).Path
  while ($true) {
    if (Test-Path -LiteralPath (Join-Path $p ".git")) { return $p }
    $parent = Split-Path -Path $p -Parent
    if ([string]::IsNullOrWhiteSpace($parent) -or $parent -eq $p) { break }
    $p = $parent
  }
  return $null
}

# Preconditions
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Fail "Git is not installed or not on PATH. Verify with: git --version"
}

# Resolve repo root
if ([string]::IsNullOrWhiteSpace($RepoPath)) {
  $RepoPath = Find-GitRoot -startPath $PSScriptRoot
  if ([string]::IsNullOrWhiteSpace($RepoPath)) {
    Fail "Unable to locate repository root (no .git found above: $PSScriptRoot). Provide -RepoPath explicitly."
  }
} else {
  if (-not (Test-Path -LiteralPath $RepoPath)) {
    Fail "RepoPath does not exist: $RepoPath"
  }
  $RepoPath = (Resolve-Path -LiteralPath $RepoPath).Path
  if (-not (Test-Path -LiteralPath (Join-Path $RepoPath ".git"))) {
    Fail "RepoPath is not a Git repository (missing .git): $RepoPath"
  }
}

Set-Location -LiteralPath $RepoPath

if (-not (Test-Path -LiteralPath "Project_Prompt.md")) {
  Fail "Project_Prompt.md not found in repo root: $RepoPath"
}

# Detect changes
$status = git status --porcelain -- Project_Prompt.md
if ($LASTEXITCODE -ne 0) { Fail "Failed to read git status." }

if ([string]::IsNullOrWhiteSpace($status)) {
  Write-Host "No changes detected in Project_Prompt.md. Nothing to commit."
  exit 0
}

# Stage
git add -- Project_Prompt.md
if ($LASTEXITCODE -ne 0) { Fail "git add failed." }

# Commit message
if ([string]::IsNullOrWhiteSpace($Message)) {
  $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  $Message = "Docs: update Project_Prompt ($ts)"
}

git commit -m $Message -- Project_Prompt.md
if ($LASTEXITCODE -ne 0) { Fail "git commit failed." }

# Push current branch
$branch = (git rev-parse --abbrev-ref HEAD).Trim()
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($branch)) { Fail "Unable to determine current branch." }

git push origin $branch
if ($LASTEXITCODE -ne 0) { Fail "git push failed." }

Write-Host "Success: Project_Prompt.md committed and pushed to origin/$branch"
