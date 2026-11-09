## BUG-004 — Support status update on Merchant shipment is not rejected with 403 Forbidden

**Environment:**
- Sandbox version: v3.4.0
- User/role: support

**Request:**
```http
PATCH /api/shipments/{id}/status
```
```json
{"status":"Delivered"}
```

**Expected:** `403 Forbidden`; shipment status unchanged.

**README rule:** “Support can read all shipments but **must not change anything**.” “Support may not change status (403).”

**Actual:** 200 OK response is returned; support able to change shipment status

**Severity:** High  
**Priority:** High

**Evidence:** 
![alt text](<BUG 004_Evidence_Support Token.png>)
![alt text](<BUG 004_Evidence_GET shipments.png>)
![alt text](<BUG 004_Evidence_PATCH Request.png>)