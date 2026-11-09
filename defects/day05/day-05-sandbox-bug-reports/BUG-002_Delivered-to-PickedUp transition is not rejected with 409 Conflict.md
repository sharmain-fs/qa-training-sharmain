## BUG-002 — Delivered-to-PickedUp transition is not rejected with 409 Conflict

**Environment:**
- Sandbox version: v3.4.0
- User/role: merchant_staff, merchant_admin

**Request:**
```http
PATCH /api/shipments/{id}/status
```
```json
{"status":"PickedUp"}
```

**Expected:** `409 Conflict`; shipment remains `Delivered`.

**README rule:** “Delivered, Returned, Cancelled are final (no further changes).” “A disallowed move returns **409**.”

**Actual:** 200 OK response is returned; shipment change to InTransit

**Severity:** High  
**Priority:** High

**Evidence:** ![alt text](<BUG 002_Evidence.png>)