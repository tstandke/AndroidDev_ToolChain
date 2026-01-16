# 6.2 — Flutter Toolchain Installation (Windows 11 / PowerShell)

This guide implements **Section 6.2** of `Project_Prompt.md`.

## Objective

Ensure the **Flutter SDK (stable)** is installed, on PATH, and healthy, and achieve a **non-blocking** `flutter doctor` result (Flutter SDK is OK; Android tooling may still be pending until Section 6.3).

---

## 6.2.0 Preflight — Detect Existing Flutter and Upgrade if Present (RECOMMENDED)

Before installing anything, determine whether Flutter is already installed and reachable.

### 6.2.0.1 Check Flutter on PATH

Run:
```powershell
flutter --version
```

**If this works:** Flutter is already installed and on PATH.

Proceed to **6.2.0.2 Upgrade / Repair (in-place)**.

**If this fails** with “not recognized”:
- Proceed to **6.2.0.3 Locate Existing Flutter (PATH missing)**, or
- If not installed, continue with **6.2.1 Download Flutter SDK (Stable)**.

---

### 6.2.0.2 Upgrade / Repair (in-place)

If Flutter is installed, normalize to stable channel and update:

```powershell
flutter channel stable
flutter upgrade
```

Then validate:

```powershell
flutter doctor
```

**Expected:** Flutter SDK is OK. Android-related warnings may remain until Section 6.3.

If `flutter doctor` reports Flutter SDK errors (corruption), stop and repair before proceeding (see 6.2.0.4).

---

### 6.2.0.3 Locate Existing Flutter (PATH missing)

If `flutter --version` fails, try:

```powershell
where flutter
```

If `where flutter` returns a path, you can run Flutter directly via:
```powershell
<flutter_root>\bin\flutter.bat --version
```

If Flutter runs, add it to PATH (example):
```powershell
setx PATH "$env:PATH;<flutter_root>\bin"
```

Close all PowerShell windows, open a new one, and re-run:
```powershell
flutter --version
```

If you cannot locate Flutter, proceed with **6.2.1** (fresh install).

---

### 6.2.0.4 Repair (only if needed)

If Flutter is present but `flutter doctor` reports SDK errors:

1. Capture verbose output:
   ```powershell
   flutter doctor -v
   ```
2. Attempt a safe in-place refresh:
   ```powershell
   flutter channel stable
   flutter upgrade
   flutter doctor
   ```

If errors persist, stop and investigate before reinstalling.

---

## 6.2.1 Download Flutter SDK (Stable) (Fresh Install)

Use this section only if Flutter is not already installed or you intentionally want a clean install.

1. Download Flutter for Windows (stable channel) from the official docs:
   - https://docs.flutter.dev/get-started/install/windows

2. Choose an install location **outside** your repo and user profile.
   - Recommended: `C:\flutter`

3. Extract the ZIP so that you end up with:
   - `C:\flutter\bin\flutter.bat`

**Avoid installing under:**
- `C:\Program Files`
- Your Git repository directory
- OneDrive-synced folders

---

## 6.2.2 Add Flutter to PATH (PowerShell) (Fresh Install)

1. Open **PowerShell** (normal user; admin not required).

2. Add Flutter to PATH:
   ```powershell
   setx PATH "$env:PATH;C:\flutter\bin"
   ```

3. Close **all** PowerShell windows. Open a **new** PowerShell window.

4. Verify Flutter is on PATH:
   ```powershell
   flutter --version
   ```

**Expected:** A Flutter version output that indicates the **stable** channel and Dart version.

If `flutter` is not found, stop here and fix PATH before proceeding.

---

## 6.2.3 Flutter Validation

Run:
```powershell
flutter doctor
```

**Expected at this stage:**
- Flutter SDK: **OK**
- Android toolchain: may be **NOT ready** (expected until Section 6.3)
- Android Studio: may be **NOT installed** (expected until Section 6.3)

Do **not** attempt to resolve Android Studio / SDK issues yet—those are handled in **6.3**.

---

## 6.2.4 Accept Android Licenses (only if prompted)

If `flutter doctor` instructs you to accept Android licenses, run:
```powershell
flutter doctor --android-licenses
```

Accept all licenses, then re-run:
```powershell
flutter doctor
```

---

## 6.2.5 Update STATUS.md

Update `STATUS.md` to reflect progress (example):

```markdown
### Flutter Toolchain

- Flutter SDK — DONE
  - Verify: flutter --version
  - Result: <version>, stable channel
  - Install path: <path>

- Flutter Doctor — IN PROGRESS
  - Android toolchain pending (expected until 6.3)
```

Commit with:
```powershell
.\scripts\GitUpdate-STATUS.ps1 -Message "Status: verify/upgrade Flutter toolchain (6.2)"
```

---

## Completion Criteria (6.2)

6.2 is complete when:

- `flutter --version` works
- `flutter doctor` runs successfully
- No Flutter SDK installation errors exist
- Any remaining warnings are primarily Android Studio / Android SDK related (to be addressed in 6.3)

---

## Next Step

Proceed to **6.3 — Android Development Environment** once 6.2 completion criteria are met.
