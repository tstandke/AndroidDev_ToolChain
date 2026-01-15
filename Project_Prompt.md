# Project Prompt & Reproduction Guide

## 1. Purpose (Why this document exists)
This document is the **single authoritative prompt** that can be handed to an AI assistant (or engineer) to:
- Recreate this project from scratch
- Maintain architectural, security, and tooling consistency
- Avoid rediscovering prior decisions

It is intentionally concise, modular, and update-friendly.

---

## 2. One-Paragraph System Summary (High-Level)
This project is a **Flutter mobile application** backed by **Google Cloud Platform** that implements **modern authentication, authorization, and biometric re-authentication**. Authentication uses **Google Sign-In via Firebase Authentication**. Authorization is enforced server-side via **Cloud Run (FastAPI)** using **Firestore** as the source of truth. The app uses **biometrics** only as a local unlock gate, never as an identity authority. Source control is managed via **GitHub**.

---

## 3. Technology Stack (Pinned Choices)
### Client
- Flutter (stable channel)
- firebase_core
- firebase_auth
- google_sign_in
- local_auth
- flutter_secure_storage
- go_router (preferred; use Navigator only if explicitly required)

### Backend
- Google Cloud Run
- Python FastAPI
- Firebase Admin SDK
- Firestore (Native mode)

### Platform Services
- Google Cloud Platform
- Firebase Authentication
- Firestore

### Source Control
- GitHub (single mono-repo)

---

## 4. Security Model (Non-Negotiable Principles)
1. **Client is never trusted**
2. All authorization decisions occur **server-side**
3. Firebase ID tokens (JWTs) are validated on every privileged request
4. Biometrics are used only for **local re-authentication**, not identity
5. No secrets or tokens are stored in plaintext

---

## 5. Authentication Flow (Canonical)
1. User signs in via Google Sign-In
2. Google credentials exchanged for Firebase Auth session
3. Client obtains Firebase ID token
4. Token is sent to backend
5. Backend validates token and checks authorization status

---

## 6. Authorization Model
### Firestore Collections
- users/{uid}
  - email
  - displayName
  - roles: ["admin" | "user" | "viewer"]
  - status: approved | pending | denied

- access_requests/{requestId}
  - uid
  - email
  - createdAt
  - status

Authorization logic is enforced:
- Primarily in backend APIs
- Secondarily via Firestore Security Rules

---

## 7. Biometric Usage Policy
- Required after first successful login
- Required on app relaunch (local unlock gate)
- Optional for sensitive operations (step-up auth)
- Never substitutes for server authorization

---

## 8. Repository Structure (Required)
```
repo_root/
  app/          # Flutter application
  backend/      # Cloud Run FastAPI service
  infra/        # Infrastructure (future Terraform/IaC)
  docs/         # Supplemental documentation
  README.md
```

---

## 9. Flutter App Structure
```
app/lib/
  main.dart
  core/
    auth/
    routing/
    storage/
  features/
    splash/
    login/
    home/
    admin_requests/
```

---

## 10. Backend Responsibilities
- Verify Firebase ID tokens on every request
- Enforce role-based access using Firestore as source of truth
- Expose endpoints (minimum set):
  - GET /me
  - POST /access-request
  - GET /admin/requests
  - POST /admin/requests/{id}/approve

---

## 11. Explicit Out-of-Scope Items
- Password authentication
- Client-side role enforcement as an authority
- Storing credentials locally (plaintext or otherwise)
- Anonymous authentication

---

## 12. Change Log (Keep Short)
- 2026-01-15: Initial architecture established (Flutter + Firebase Auth + Cloud Run authz + biometrics gate)

---

## 13. Prompt Usage Instructions
When providing this document to an AI assistant, prepend the following directive:

> Use this document as the authoritative specification. Do not invent alternate architectures. Ask questions only if a decision is missing or ambiguous. Update this document whenever a decision changes.

---

## 14. Maintenance Rules
- Prefer **editing existing sections** over adding new ones
- If a decision changes, update it here and nowhere else
- Keep the one-paragraph summary current

---

## 15. Lessons Learned / FAQ (Decision Guardrails)
This section captures **practical lessons learned** and common failure modes so future iterations (human or AI) avoid repeating mistakes.

### Q1. Why not rely on client-side authorization checks?
**Lesson:** Client-side checks are trivially bypassed.  
**Decision:** All authorization logic must be enforced server-side. The client may *display* UI conditionally, but the backend is the final authority.

---

### Q2. Why is Firebase Authentication used instead of custom OAuth handling?
**Lesson:** Rolling your own OAuth or token handling increases attack surface and maintenance cost.  
**Decision:** Use Firebase Authentication as the identity provider and validate Firebase-issued JWTs on the backend.

---

### Q3. Why are biometrics not treated as authentication?
**Lesson:** Biometrics authenticate a *device user*, not an *identity*.  
**Decision:** Biometrics are used only as a **local re-authentication gate** after a valid cloud-based login has already occurred.

---

### Q4. Why is Firestore the authorization source of truth?
**Lesson:** Authorization state must be centrally managed and auditable.  
**Decision:** Firestore holds user roles and approval status. Backend services query Firestore to make authorization decisions.

---

### Q5. Why verify the Firebase ID token on every backend request?
**Lesson:** Cached or assumed identity leads to privilege escalation bugs.  
**Decision:** Every privileged backend endpoint must verify the Firebase ID token and re-evaluate authorization.

---

### Q6. Why avoid storing tokens or credentials locally?
**Lesson:** Local storage is a common exfiltration vector on compromised devices.  
**Decision:** Rely on Firebase session management. Store only minimal, non-sensitive state (e.g., "hasCompletedFirstAuth").

---

### Q7. Why separate authentication from authorization explicitly?
**Lesson:** Conflating identity with permission leads to unclear security boundaries.  
**Decision:** Authentication proves *who the user is*. Authorization determines *what the user can do*. These concerns are handled independently.

---

### Q8. What is the most common architectural mistake to avoid?
**Lesson:** Letting early convenience dictate long-term security posture.  
**Decision:** Favor correctness, auditability, and server-side enforcement over short-term development speed.

---

### Q9. When adding new features, what must be checked first?
**Lesson:** Feature creep often bypasses original security assumptions.  
**Decision Checklist:**
- Does this require a new backend endpoint?
- Does it need a role or permission?
- Is server-side enforcement implemented?
- Does the prompt document need updating?

---

### Q10. When should this section be updated?
**Lesson:** Lessons lose value if not captured immediately.  
**Decision:** Add an entry here whenever:
- A bug reveals a flawed assumption
- A security concern is discovered
- A design decision is reversed
- An AI produces an incorrect but plausible solution

---

### Q11. How should new lessons be categorized?
**Lesson:** Unstructured lessons become noise over time.  
**Decision:** Every new lesson must be written using **one of two explicit patterns**:

1. **Never Do This**
   - Used for actions that create severe security, data-loss, or architectural risk
   - Examples: trusting client-side auth, storing tokens locally, bypassing backend checks

2. **Tempting but Wrong**
   - Used for approaches that appear reasonable or faster, but violate long-term correctness or security
   - Examples: relying on cached authorization, skipping token verification for "internal" endpoints

This categorization is mandatory to preserve clarity and prevent future regression.
---

### Repository Index Reference

After reviewing this document, **also review `FILE_INDEX.md`** for a stable, authoritative map of all files and directories in this repository, including their purpose and update rules.

- FILE_INDEX.md (repository structure and intent):
  https://github.com/tstandke/AndroidDev_ToolChain/blob/main/FILE_INDEX.md

This index is intended to prevent ambiguity about which files are authoritative, which are safe to edit, and how the repository is meant to evolve over time.

