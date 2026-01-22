"""
Authorization backend (Section 6.6)

This service will:
- Verify Firebase ID tokens
- Enforce authorization using Firestore
- Return correct HTTP semantics (401 vs 403)

Implementation is added incrementally.
"""

from fastapi import FastAPI

app = FastAPI(title="Authorization Backend", version="0.1.0")


@app.get("/health")
def health():
    return {"status": "ok"}
