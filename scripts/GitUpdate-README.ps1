<#
.SYNOPSIS
Stages, commits, and pushes README.md updates for this repository.

.DESCRIPTION
This script is a safe, narrow automation that only commits README.md.
It is intended to reduce repeated typing for a common workflow.

.PARAMETER RepoPath
Path to the local repository root. Defaults to the script's directory.

.PARAMETER Message
Commit message to use. Defaults to a timestamped message.

.EXAMPLE
.\GitUpdate-README.ps1

.EXAMPLE
.\GitUpdate-README.ps1 -RepoPath "C:\Users\Tim\AndroidDev_ToolChain" -Message "Docs: update README"
#>

[CmdletBinding()]
param(
  [Parameter(Mandatory=$false)]
  [string]$RepoPath = $PSScriptRoot,

  [Parameter(Mandatory=$false)]
  [string]$Message
)

function Fail($msg) {
  Write-Error $msg
  exit 1
}

# Preconditions
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Fail "Git is not installed or not on PATH. Verify with: git --version"
}

if (-not (Test-Path -LiteralPath $RepoPath)) {
  Fail "RepoPath does not exist: $RepoPath"
}

Set-Location -LiteralPath $RepoPath

if (-not (Test-Path -LiteralPath ".git")) {
  Fail "RepoPath is not a Git repository (missing .git): $RepoPath"
}

if (-not (Test-Path -LiteralPath "README.md")) {
  Fail "README.md not found in repo root: $RepoPath"
}

# Ensure remote exists (origin)
$remotes = git remote 2>$null
if ($LASTEXITCODE -ne 0) { Fail "Failed to list git remotes." }
if (-not ($remotes -split "\r?\n" | Where-Object { $_ -eq "origin" })) {
  Fail "Remote 'origin' is not configured. Run: git remote -v"
}

# Check if README has changes (tracked changes only)
$statusLine = git status --porcelain -- README.md
if ($LASTEXITCODE -ne 0) { Fail "Failed to read git status." }

if ([string]::IsNullOrWhiteSpace($statusLine)) {
  Write-Host "No changes detected in README.md. Nothing to commit."
  exit 0
}

# Stage README.md
git add -- README.md
if ($LASTEXITCODE -ne 0) { Fail "git add failed." }

# Commit message
if ([string]::IsNullOrWhiteSpace($Message)) {
  $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  $Message = "Docs: update README ($ts)"
}

git commit -m $Message -- README.md
if ($LASTEXITCODE -ne 0) {
  # If commit failed due to nothing to commit, treat as clean exit
  $postStatus = git status --porcelain -- README.md
  if ([string]::IsNullOrWhiteSpace($postStatus)) {
    Write-Host "README.md was staged but no commit was created (nothing to commit)."
    exit 0
  }
  Fail "git commit failed."
}

# Push current branch to origin
$branch = (git rev-parse --abbrev-ref HEAD).Trim()
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($branch)) { Fail "Unable to determine current branch." }

git push origin $branch
if ($LASTEXITCODE -ne 0) { Fail "git push failed. Ensure you have network access and credentials." }

Write-Host "Success: README.md committed and pushed to origin/$branch"
