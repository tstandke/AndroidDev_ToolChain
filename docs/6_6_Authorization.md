# 6.6 Authorization — Locked Schema & Workflow (Option A → Option B)

This document locks the authorization schema and workflow for the toolchain reference application.
It is designed so Option A (manual admin via Firestore Console) can evolve into Option B (Admin App)
without schema changes or rework.

---

## 1. Goals

- Enforce authorization server-side (client UI never determines access).
- Provide a deterministic workflow for:
  - User authorization requests
  - Admin approval/denial
  - User notification in-app
- Preserve forward compatibility:
  - Option A (Firestore Console) → Option B (Admin App) with no schema migration.

---

## 2. Core Policy (Locked)

### 2.1 Authentication vs Authorization
- Authentication proves identity (Firebase Auth).
- Authorization determines permission (Firestore + server enforcement).

### 2.2 HTTP Semantics (Backend)
- Missing/invalid/expired token → **401 Unauthorized**
- Valid token but not allowlisted or disabled → **403 Forbidden**
- Valid token and allowlisted/enabled → **200 OK**

### 2.3 Bootstrap Admin (One-time)
- A single initial administrator is created manually in Firestore (out-of-band).
- After bootstrap, all approvals/denials are performed via the defined workflow (Option A or B).
- The backend must be the authority for role assignment and privileged writes.

---

## 3. Firestore Schema (Locked)

### 3.1 Collection: `users`
Document ID: `{uid}` (Firebase Auth UID)

Minimal fields:
- `enabled` (bool)
- `role` (string; e.g., `admin`, `user`)
- `email` (string)
- `createdAt` (timestamp; server)
- `updatedAt` (timestamp; server)

Example:
```json
{
  "enabled": true,
  "role": "admin",
  "email": "admin@example.com",
  "createdAt": "<server_timestamp>",
  "updatedAt": "<server_timestamp>"
}
