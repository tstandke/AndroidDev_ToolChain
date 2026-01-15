<#
.SYNOPSIS
Stages, commits, and pushes STATUS.md updates for this repository.

.DESCRIPTION
This script is a safe, narrow automation that only commits STATUS.md.
Use it to record progress as the toolchain evolves.

.PARAMETER RepoPath
Path to the local repository root. Defaults to the script's directory.

.PARAMETER Message
Commit message to use. Defaults to a timestamped message.

.EXAMPLE
.\GitUpdate-STATUS.ps1

.EXAMPLE
.\GitUpdate-STATUS.ps1 -RepoPath "C:\Users\Tim\AndroidDev_ToolChain" -Message "Status: Android Studio installed"
#>

[CmdletBinding()]
param(
  [Parameter(Mandatory=$false)]
  [string]$RepoPath = $PSScriptRoot,

  [Parameter(Mandatory=$false)]
  [string]$Message
)

function Fail($msg) {{
  Write-Error $msg
  exit 1
}}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {{
  Fail "Git is not installed or not on PATH."
}}

if (-not (Test-Path -LiteralPath $RepoPath)) {{
  Fail "RepoPath does not exist: $RepoPath"
}}

Set-Location -LiteralPath $RepoPath

if (-not (Test-Path -LiteralPath ".git")) {{
  Fail "RepoPath is not a Git repository."
}}

if (-not (Test-Path -LiteralPath "STATUS.md")) {{
  Fail "STATUS.md not found in repo root."
}}

$status = git status --porcelain -- STATUS.md
if ([string]::IsNullOrWhiteSpace($status)) {{
  Write-Host "No changes detected in STATUS.md. Nothing to commit."
  exit 0
}}

git add -- STATUS.md
if ($LASTEXITCODE -ne 0) {{ Fail "git add failed." }}

if ([string]::IsNullOrWhiteSpace($Message)) {{
  $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  $Message = "Status update ($ts)"
}}

git commit -m $Message -- STATUS.md
if ($LASTEXITCODE -ne 0) {{ Fail "git commit failed." }}

$branch = (git rev-parse --abbrev-ref HEAD).Trim()
git push origin $branch
if ($LASTEXITCODE -ne 0) {{ Fail "git push failed." }}

Write-Host "Success: STATUS.md committed and pushed to origin/$branch"
