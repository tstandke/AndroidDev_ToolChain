<#
.SYNOPSIS
Stages, commits, and pushes FILE_INDEX.md updates for this repository.

.DESCRIPTION
This script is a safe, narrow automation that only commits FILE_INDEX.md.
It should be used when repository structure or file roles change.

.PARAMETER RepoPath
Path to the local repository root. Defaults to the script's directory.

.PARAMETER Message
Commit message to use. Defaults to a timestamped message.

.EXAMPLE
.\GitUpdate-FILE_INDEX.ps1

.EXAMPLE
.\GitUpdate-FILE_INDEX.ps1 -RepoPath "C:\Users\Tim\AndroidDev_ToolChain" -Message "Docs: update FILE_INDEX"
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
  Fail "Git is not installed or not on PATH."
}

if (-not (Test-Path -LiteralPath $RepoPath)) {
  Fail "RepoPath does not exist: $RepoPath"
}

Set-Location -LiteralPath $RepoPath

if (-not (Test-Path -LiteralPath ".git")) {
  Fail "RepoPath is not a Git repository: $RepoPath"
}

if (-not (Test-Path -LiteralPath "FILE_INDEX.md")) {
  Fail "FILE_INDEX.md not found in repo root."
}

# Ensure origin exists
$remotes = git remote 2>$null
if ($LASTEXITCODE -ne 0) { Fail "Failed to list git remotes." }
if (-not ($remotes -split "\r?\n" | Where-Object { $_ -eq "origin" })) {
  Fail "Remote 'origin' is not configured."
}

# Detect changes
$status = git status --porcelain -- FILE_INDEX.md
if ([string]::IsNullOrWhiteSpace($status)) {
  Write-Host "No changes detected in FILE_INDEX.md. Nothing to commit."
  exit 0
}

# Stage
git add -- FILE_INDEX.md
if ($LASTEXITCODE -ne 0) { Fail "git add failed." }

# Commit
if ([string]::IsNullOrWhiteSpace($Message)) {
  $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  $Message = "Docs: update FILE_INDEX ($ts)"
}

git commit -m $Message -- FILE_INDEX.md
if ($LASTEXITCODE -ne 0) { Fail "git commit failed." }

# Push
$branch = (git rev-parse --abbrev-ref HEAD).Trim()
git push origin $branch
if ($LASTEXITCODE -ne 0) { Fail "git push failed." }

Write-Host "Success: FILE_INDEX.md committed and pushed to origin/$branch"
