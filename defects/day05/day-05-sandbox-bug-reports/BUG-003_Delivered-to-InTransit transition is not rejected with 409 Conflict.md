## BUG-003 — Delivered-to-InTransit transition is not rejected with 409 Conflict

**Environment:**
- Sandbox version: v3.4.0
- User/role: merchant_admin, merchant staff

**Request:**
```http
PATCH /api/shipments/{id}/status
```
```json
{"status":"InTransit"}
```

**Expected:** `409 Conflict`; shipment remains `Delivered`.

**README rule:** “Delivered, Returned, Cancelled are final (no further changes).” “A disallowed move returns **409**.”

**Actual:** 200 OK response is returned; shipment change to InTransit

**Severity:** Critical  
**Priority:** Critical

**Evidence:** 
![alt text](<BUG 003_Evidence_GET Request.png>)
![alt text](<BUG 003_Evidence_PATCH Request.png>)

**Impact:** If a completed delivery can be reopened, final delivery records and downstream settlements may be compromised.