# 6.6 Authorization — Locked Schema & Workflow (Option A → Option B)

This document locks the **authorization model, workflow, validation procedure, and diagnostic expectations** for the toolchain reference application.

It is explicitly written to:
- Prevent rediscovery of known pitfalls
- Provide deterministic diagnostics when authorization fails
- Enable an AI assistant (or human developer) to reason step‑by‑step through failures
- Allow Option A (manual admin via Firestore Console) to evolve into Option B (Admin App)
  **without schema changes or rework**

This document is normative for Section 6.6 of `Project_Prompt.md`.

---

## 1. Purpose & Scope

This section defines **server-side authorization only**.

It does **not** define:
- UI/UX behavior
- Product-specific business logic
- Fine-grained RBAC beyond coarse roles

The reference application exists to validate **mechanics and correctness**, not to serve as a production authorization system.

---

## 1.1 Terminology & Conventions

The following terms are used consistently throughout this document:

- **Authentication** — Proof of identity via Firebase Authentication.
- **Authorization** — Permission enforcement via Firestore and backend logic.
- **Allowlist** — Explicit authorization records keyed by Firebase `uid`.
- **Bootstrap admin** — The initial administrator created manually out-of-band.
- **Reference application** — A minimal validation artifact, not a production app.

Terminology is precise by design; ambiguous usage should be treated as a defect.

---

## 2. System Assumptions & Preconditions (REQUIRED)

Authorization testing is **invalid** unless all assumptions below are true.

### 2.1 Identity & Project Context
- Firebase project, linked GCP project, and OAuth clients belong to the **same Google account context**
- Firebase Authentication is already working interactively (Section 6.5 DONE)
- The client is using the **Web OAuth Client ID**, not the Android client ID

### 2.2 Backend Runtime
- Backend is running locally via FastAPI
- Backend is bound to all interfaces:
  ```bash
  uvicorn main:app --reload --host 0.0.0.0 --port 8000
  ```
- Backend port is fixed and known (default: `8000`)

### 2.3 Networking
- Emulator uses `http://10.0.2.2:8000` to reach the host
- Physical devices use the PC’s **LAN IPv4 address**
- PC firewall allows inbound TCP traffic on the backend port
- VPNs (even when “paused”) may block LAN routing and must be fully disconnected

### 2.4 Time & Tokens
- Firebase ID tokens are short-lived (~1 hour)
- All authorization tests must use a **fresh ID token**
- Manual token copy/paste is discouraged and error-prone

---

## 3. Core Policy (Locked)

### 3.1 Authentication vs Authorization
- **Authentication** proves identity (Firebase Auth)
- **Authorization** determines permission (Firestore + backend enforcement)

The client UI must never determine authorization outcomes.

### 3.2 HTTP Semantics (Backend)
- Missing / malformed / expired token → **401 Unauthorized**
- Valid token but not allowlisted or disabled → **403 Forbidden**
- Valid token and allowlisted + enabled → **200 OK**

These semantics are locked and must not be altered.

### 3.3 Locked vs Evolvable Elements

**Locked (must not change):**
- UID-keyed authorization documents
- `enabled` boolean gate
- HTTP status semantics (401 / 403 / 200)

**May evolve without schema migration:**
- Role taxonomy (`admin`, `user`, etc.)
- Admin experience (Option A → Option B)
- Notification and UX flow

---

## 4. Authorization Source of Truth (Locked)

### 4.1 Firestore Collection

Concrete collection used by the reference backend:

```
authz_users
```

(Document naming is case-sensitive.)

### 4.2 Document ID
- Document ID **must equal** the Firebase Auth `uid`

### 4.3 Required Fields

| Field | Type | Notes |
|-----|-----|------|
| `enabled` | boolean | **Must be true** to authorize |
| `role` | string | e.g., `admin`, `user` |
| `email` | string | For audit/debug only |
| `createdAt` | timestamp | Server-side |
| `updatedAt` | timestamp | Server-side |

### 4.4 Example (Known-Good)

```json
{
  "enabled": true,
  "role": "admin",
  "email": "admin@example.com",
  "createdAt": "<server_timestamp>",
  "updatedAt": "<server_timestamp>"
}
```

⚠️ Field names are **case-sensitive**.  
`Enabled` ≠ `enabled`.

---

## 5. Authorization Workflow (End-to-End)

1. Client signs in via Firebase Authentication
2. Client requests a **fresh Firebase ID token**
3. Client calls backend endpoint with:
   ```http
   Authorization: Bearer <id_token>
   ```
4. Backend verifies token using Firebase Admin SDK
5. Backend extracts `uid` and resolves Firestore document
6. Backend enforces:
   - document exists
   - `enabled == true`
7. Backend returns:
   - `200 OK` with identity + role, or
   - appropriate 401 / 403 error

---

## 6. Stage-by-Stage Verification Checklist (Diagnostic Ladder)

Use this **in order**. Do not skip stages.

### Stage 1 — Client Authentication
- Google Sign-In succeeds
- Firebase user object exists
- Failure here ≠ authorization problem

### Stage 2 — Token Acquisition
- ID token retrieved successfully
- Token is freshly issued
- Expired tokens cause false negatives

### Stage 3 — Backend Reachability
- `/health` reachable from client environment
- Emulator vs physical device paths differ
- Timeouts here indicate **networking**, not auth

### Stage 4 — Token Verification
- Admin SDK accepts token
- Failures here are project / OAuth / ADC issues

### Stage 5 — Firestore Lookup
- Document ID matches `uid`
- Collection name correct
- Field names correctly cased

### Stage 6 — Authorization Decision
- `enabled == true`
- Role present
- Failures here correctly return **403**

### Stage 7 — End-to-End Success
- `/whoami` returns `200 OK`
- Response includes `uid`, `email`, `role`, `enabled`

---

## 7. Common Failure Modes & Root Causes

| Symptom | Likely Cause |
|------|-------------|
| 401 immediately | Missing / expired token |
| 403 with “disabled” | `enabled` missing, false, or wrong type |
| Firestore doc exists but ignored | Field name case mismatch |
| Emulator works, phone times out | Backend bound to `127.0.0.1` |
| Phone times out | Firewall or VPN blocking LAN |
| Random failures after delay | Token expired |
| OAuth errors | Wrong Web Client ID or wrong GCP project |

---

## 8. Bootstrap Admin Policy (One-Time)

- One initial admin is created manually in Firestore
- This step is **out-of-band** and performed once
- After bootstrap:
  - Backend enforces role-based behavior
  - Option A (Firestore Console) or Option B (Admin App) manages approvals

---

## 9. Reference App Scope & Non-Goals (Authorization)

The reference app:
- Uses coarse roles only
- Does not implement multi-tenant RBAC
- Does not define business permissions
- Exists solely to validate toolchain correctness

Production deployments must additionally enforce App Check, TLS, and secret isolation; these are intentionally out of scope for the reference app.

---

## 10. Known-Good End State (Reference Snapshot)

All of the following are true:

- Emulator `/whoami` → `200 OK`
- Physical device `/whoami` → `200 OK`
- Response includes:
  ```json
  {
    "role": "admin",
    "enabled": true
  }
  ```
- No manual token copy is required
- Backend reachable from both environments

---

## 11. Minimal Test Matrix

| Environment | Base URL | Expected |
|------------|---------|----------|
| Emulator | `http://10.0.2.2:8000` | `200 OK` |
| Physical device | `http://<LAN_IP>:8000` | `200 OK` |

---

## 12. Documentation Hierarchy Note

The concrete execution history and current validation state for this workflow are recorded in `STATUS.md`.

When this snapshot is true, Section 6.6 is complete.
