<# 
Reset-ReferenceApp.ps1
Resets Flutter/Gradle build artifacts that commonly cause "Access is denied" (errno=5)
Does NOT delete source code or Firebase config files.
#>

$ErrorActionPreference = "Stop"

$repoRoot = "C:\Users\Tim\AndroidDev_ToolChain"
$appRoot  = Join-Path $repoRoot "reference_app"

Write-Host "`n=== Reset Reference App Build State ===`n"

if (-not (Test-Path $appRoot)) {
  throw "reference_app not found at: $appRoot"
}

# 1) Stop common lock holders (best-effort)
$processNames = @(
  "java",          # Gradle daemon
  "kotlin-daemon",
  "gradle",
  "adb",
  "flutter",
  "dart"
)

Write-Host "Stopping common lock-holding processes (best-effort)..."
foreach ($p in $processNames) {
  Get-Process -Name $p -ErrorAction SilentlyContinue | ForEach-Object {
    try {
      Write-Host "  - Stopping $($_.Name) (PID $($_.Id))"
      Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
    } catch {}
  }
}

# 2) Stop Gradle daemons cleanly (if possible)
Write-Host "`nStopping Gradle daemon (best-effort)..."
Push-Location $appRoot
try {
  if (Test-Path ".\android\gradlew.bat") {
    cmd /c ".\android\gradlew.bat --stop" | Out-Null
  }
} catch {}
Pop-Location

# 3) Clear Flutter build outputs
Write-Host "`nRemoving Flutter build outputs..."
$pathsToRemove = @(
  (Join-Path $appRoot "build"),
  (Join-Path $appRoot ".dart_tool"),
  (Join-Path $appRoot ".flutter-plugins"),
  (Join-Path $appRoot ".flutter-plugins-dependencies"),
  (Join-Path $appRoot "ios\Pods"),                 # harmless on Windows, may not exist
  (Join-Path $appRoot "android\.gradle"),
  (Join-Path $appRoot "android\app\build"),
  (Join-Path $appRoot "android\build")
)

foreach ($p in $pathsToRemove) {
  if (Test-Path $p) {
    Write-Host "  - Deleting $p"
    Remove-Item -Recurse -Force $p
  }
}

# 4) Clear global Gradle caches (optional but effective)
# Comment out if you want to keep caches
$gradleCache = Join-Path $env:USERPROFILE ".gradle\caches"
$gradleDaemon = Join-Path $env:USERPROFILE ".gradle\daemon"
Write-Host "`nRemoving global Gradle caches (optional but effective)..."
if (Test-Path $gradleCache) { Remove-Item -Recurse -Force $gradleCache }
if (Test-Path $gradleDaemon) { Remove-Item -Recurse -Force $gradleDaemon }

# 5) Flutter clean + pub get
Write-Host "`nRunning flutter clean + flutter pub get..."
Push-Location $appRoot
flutter clean
flutter pub get
Pop-Location

Write-Host "`n=== Done. Next: rerun flutter run ===`n"
