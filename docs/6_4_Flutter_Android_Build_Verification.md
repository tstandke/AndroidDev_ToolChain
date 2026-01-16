# 6.4 — Flutter + Android Build Verification (Reference Application)

This guide implements **Section 6.4** of `Project_Prompt.md`.

## Objective

Verify that the **installed Flutter + Android toolchain** can successfully
**build, deploy, and run** a real Flutter application using the canonical
reference app located at:

- `reference_app/`

This step is a **toolchain validation**, not an application feature test.

---

## 6.4.0 Preflight — Detect Existing Reference App

### 6.4.0.1 Check for reference_app directory

From the repository root, run:

```powershell
dir reference_app
```

**If the directory exists:**  
Proceed to **6.4.1 Verify Existing Build**.

**If the directory does not exist:**  
Proceed to **6.4.2 Create Reference Application**.

---

## 6.4.1 Verify Existing Build (Preferred Path)

This path is used when `reference_app/` already exists.

1. Change into the reference app directory:
   ```powershell
   cd reference_app
   ```

2. Fetch dependencies:
   ```powershell
   flutter pub get
   ```

3. Verify available devices:
   ```powershell
   flutter devices
   ```

4. Run the application:
   ```powershell
   flutter run
   ```

### Expected Results

- Gradle build completes successfully
- APK installs and launches on emulator/device
- Debug console shows active session
- Hot reload is available

If successful, proceed to **6.4.4 Completion**.

---

## 6.4.2 Create Reference Application (Fresh Setup)

Use this path only if `reference_app/` does not exist.

From the repository root:

```powershell
flutter create reference_app
```

Then:

```powershell
cd reference_app
flutter pub get
flutter run
```

### Expected Results

- Flutter template app builds and runs successfully
- Default counter app is visible on emulator/device

---

## 6.4.3 Common Recovery Actions

If the build stalls or fails:

```powershell
flutter clean
adb kill-server
adb start-server
flutter run
```

If the emulator shows `offline`, restart the emulator and re-run.

---

## 6.4.4 Update STATUS.md

Update `STATUS.md` to reflect:

- Flutter Android debug run — **DONE**
- Reference application build verified

---

## Completion Criteria (6.4)

6.4 is complete when:

- `flutter run` succeeds for `reference_app`
- Application launches on Android emulator/device
- No Android toolchain blocking issues remain
