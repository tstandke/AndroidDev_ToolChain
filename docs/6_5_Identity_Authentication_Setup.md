# 6.5 — Identity & Authentication Setup (Reference Application)

This guide implements **Section 6.5** of `Project_Prompt.md`.

## Objective

Add **Firebase Authentication (Google Sign-In)** to the canonical
`reference_app/` and verify successful interactive sign-in on Android.

This step establishes **identity only**. Authorization is handled in Section 6.6.

---

## 6.5.0 Preflight — Check Firebase Integration State

From `reference_app/`, check for existing Firebase files:

```powershell
dir lib\firebase_options.dart
dir android\app\google-services.json
```

**If files exist:**  
Proceed to **6.5.3 Verify Existing Authentication**.

**If files do not exist:**  
Proceed to **6.5.1 Firebase Project Setup**.

---

## 6.5.1 Firebase Project and Android App Registration

1. Create or select a Firebase project.
2. Add an **Android app** to the project.
   - Package name must match `applicationId`
     (default: `com.example.reference_app`).
3. Download `google-services.json` and place it at:
   - `reference_app/android/app/google-services.json`

---

## 6.5.2 Register Debug Signing Certificates

From `reference_app/android`, run:

```powershell
./gradlew signingReport
```

Copy **SHA-1** and **SHA-256** for the **debug** variant and add them in:
Firebase Console → Project Settings → Android App → SHA certificates.

---

## 6.5.3 Configure Flutter App with FlutterFire CLI

1. Ensure tools are installed:
   ```powershell
   firebase --version
   dart pub global list | findstr flutterfire
   ```

2. If missing:
   ```powershell
   npm install -g firebase-tools
   firebase login
   dart pub global activate flutterfire_cli
   ```

3. Configure Firebase:
   ```powershell
   cd reference_app
   flutterfire configure
   ```

Expected:
- `lib/firebase_options.dart` created
- Android platform configured

---

## 6.5.4 Enable Google Sign-In Provider

Firebase Console → Authentication → Sign-in method:
- Enable **Google** provider

---

## 6.5.5 Implement Minimal Sign-In Test

1. Add dependencies:
   - `firebase_core`
   - `firebase_auth`
   - `google_sign_in`

2. Initialize Firebase in `main.dart`.
3. Add a minimal sign-in button.
4. Run:
   ```powershell
   flutter run
   ```

### Expected Results

- Google account chooser appears
- Firebase returns a valid user (uid/email)
- Auth state is stable across runs

---

## 6.5.6 Update STATUS.md

Record:

- Firebase Authentication — **DONE**
- Google Sign-In verified on Android

---

## Completion Criteria (6.5)

6.5 is complete when:

- User can sign in with Google on Android
- Firebase returns valid authenticated user
- No auth-related errors appear in logs
