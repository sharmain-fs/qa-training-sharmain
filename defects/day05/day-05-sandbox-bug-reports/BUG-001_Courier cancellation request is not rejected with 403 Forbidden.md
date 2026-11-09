## BUG-001 — Courier cancellation request is not rejected with 403 Forbidden

**Environment:**
- Sandbox version: v3.4.0
- User/role: Courier 

**Request:**
```http
PATCH /api/shipments/{id}/status
```
```json
{"status":"Cancelled"}
```

**Expected:** `403 Forbidden`; shipment remains unchanged.

**README rule:** “Couriers may set PickedUp, InTransit, Delivered, Returned, but **not** Cancelled (403).” Also: “Delivered, Returned, Cancelled are final (no further changes).”

**Actual:** 200 OK response is returned

**Severity:** High  
**Priority:** High

**Evidence:** ![alt text](<BUG 001_Evidence.png>)
