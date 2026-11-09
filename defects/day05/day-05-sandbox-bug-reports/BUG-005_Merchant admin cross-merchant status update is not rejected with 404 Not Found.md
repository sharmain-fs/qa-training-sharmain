## BUG-005 — Merchant admin cross-merchant status update is not rejected with 404 Not Found

**Environment:**
- Sandbox version: v3.4.0
- User/role: merchant_admin

**Request:**
```http
PATCH /api/shipments/{id}/status
```
```json
{"status":"Delivered"}
```

**Expected:** `404 Not Found`; Merchant B's shipment remains unchanged.

**README rule:** “Merchant users see only their own merchant's shipments.” “A shipment you are not allowed to see behaves as if it does not exist (404).” “Merchant users may only change their own merchant's shipments.”

**Actual:** 200 OK response is returned; able to change another merchant shipment status

**Severity:** Critical  
**Priority:** Critical

**Evidence:** 
![alt text](<BUG 005_Evidence_Merchant Admin 1 token.png>)
![alt text](<BUG 005_Evidence_GET shipments.png>)
![alt text](<BUG 005_Evidence_PATCH Request.png>)

**Impact:** If the update succeeds, this is a cross-merchant authorization bypass that could alter another merchant's delivery record.