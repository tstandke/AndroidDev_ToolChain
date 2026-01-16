# 6.3 — Android Toolchain Installation (Windows 11 / PowerShell)

This guide implements **Section 6.3** of `Project_Prompt.md`.

## Objective

Install and verify the **Android development environment** required for Flutter Android builds, including **Android Studio**, **Android SDK components**, **Android Emulator (AVD)**, and **adb connectivity**, resulting in a **non-blocking Android toolchain** status in `flutter doctor`.

---

## 6.3.0 Preflight — Detect Existing Android Tooling (RECOMMENDED)

Before installing or modifying anything, determine whether Android Studio and SDK tools are already present.

### 6.3.0.1 Check Android Studio via Flutter

Run:
```powershell
flutter doctor
```

**If Android Studio is detected:**
- Proceed to **6.3.0.2 Verify Existing Installation**.

**If Android Studio is NOT detected:**
- Proceed to **6.3.1 Install Android Studio (Stable)**.

---

### 6.3.0.2 Verify Existing Installation

If Android Studio is detected:

1. Launch **Android Studio** manually.
2. Confirm it reaches the welcome screen or opens a project without blocking setup errors.

If Android Studio launches cleanly, proceed to **6.3.2 Android SDK Component Verification**.

If Android Studio fails to launch or reports missing SDKs, proceed to **6.3.1** to reinstall or repair.

---

## 6.3.1 Install Android Studio (Stable)

Use this section only if Android Studio is not installed or is non-functional.

1. Download Android Studio (Stable) from:
   - https://developer.android.com/studio

2. Install using default options.
   - Allow Android Studio to install the bundled JDK.
   - Do **not** override SDK paths unless required.

3. Launch Android Studio once after installation to complete first-run setup.

**Expected:**
- Android Studio launches without blocking dialogs.

---

## 6.3.2 Android SDK Component Installation & Verification

### 6.3.2.1 Confirm SDK Location

Default expected SDK location:
- `C:\Users\<User>\AppData\Local\Android\sdk`

Open Android Studio →  
Settings → Appearance & Behavior → System Settings → Android SDK

---

### 6.3.2.2 SDK Platforms

Ensure **at least one** Android SDK Platform is installed.

Recommended:
- The most recent stable API level appropriate for your environment.

---

### 6.3.2.3 SDK Tools (Required)

In the **SDK Tools** tab, ensure the following are installed:

- Android SDK Platform-Tools
- Android SDK Build-Tools
- Android SDK Command-line Tools (latest)
- Android Emulator

Apply changes and allow all downloads to complete.

---

## 6.3.3 Environment Variables (Recommended)

### 6.3.3.1 ANDROID_HOME

Set `ANDROID_HOME` to the SDK path, for example:
- `C:\Users\<User>\AppData\Local\Android\sdk`

---

### 6.3.3.2 PATH Additions

Ensure PATH includes:

- `%ANDROID_HOME%\platform-tools`
- `%ANDROID_HOME%\cmdline-tools\latest\bin`

If needed, add via:
```powershell
setx PATH "$env:PATH;<path>"
```

Close **all** PowerShell windows and open a new one after changes.

---

## 6.3.4 adb Verification

### 6.3.4.1 Verify adb on PATH

Run:
```powershell
adb --version
where adb
```

**Expected:**
- `adb --version` prints a version
- `where adb` resolves to `...\\Android\\sdk\\platform-tools\\adb.exe`

If `adb` is not found, stop and correct PATH before proceeding.

---

### 6.3.4.2 Verify Device Enumeration

Run:
```powershell
adb devices
```

**Expected:**
- At least one device listed with status `device`  
  (physical device and/or emulator)

If you see `unauthorized`:
- Unlock the device
- Accept the RSA prompt
- Re-run `adb devices`

If no devices are listed, proceed to **6.3.5 Emulator Setup**.

---

## 6.3.5 Android Emulator (AVD) Setup

### 6.3.5.1 Create Emulator (GUI)

Android Studio → Tools → Device Manager → Create Device

Recommended:
- Pixel-class device
- x86_64 system image (Google APIs acceptable)

---

### 6.3.5.2 Verify Emulator (CLI)

Run:
```powershell
flutter emulators
```

Optionally start it:
```powershell
flutter emulators --launch <emulator_id>
```

Then verify:
```powershell
adb devices
```

**Expected:**
- Emulator appears with status `device`

---

## 6.3.6 Final Verification

Run:
```powershell
flutter doctor -v
```

**Expected:**
- Android toolchain reports **no blocking issues**
- Emulator detected (if installed)
- Any remaining warnings are informational or out of scope

---

## 6.3.7 Update STATUS.md

Update `STATUS.md` to reflect progress (example):

```markdown
### Android Tooling

- Android Studio (stable) — DONE
- Android SDK Platform Tools — DONE
- Android Emulator (AVD) — DONE
- Physical device (USB debugging) — DONE
  - Verify: adb devices
```

Commit with:
```powershell
.\scripts\GitUpdate-STATUS.ps1 -Message "Status: Android toolchain installation complete (6.3)"
```

---

## Completion Criteria (6.3)

6.3 is complete when:

- Android Studio launches successfully
- Required SDK components are installed
- `adb --version` works
- `adb devices` shows at least one `device`
- `flutter doctor` reports no Android blocking issues

---

## Next Step

Proceed to **6.4 — Flutter + Android Build Verification**.

