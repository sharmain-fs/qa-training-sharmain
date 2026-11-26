## BUG-007 — Unknown shipment status returns 500 Internal Server Error instead of 400 Bad Request

**Environment:**
- Sandbox version: v3.4.0
- User/role: merchant_admin

**Request:**
```http
PATCH /api/shipments/{id}/status
```
```json
{"status":"Lost"}
```

**Expected:** `400 Bad Request`; the unsupported status value is rejected, and the shipment's original status remains unchanged.

**README rule:** An unknown shipment status value must return `400 Bad Request`.

**Actual:** `500 Internal Server Error` response is returned when attempting to update a shipment with an unsupported status value (`Lost`) instead of the expected `400 Bad Request`.

**Severity:** Medium  
**Priority:** High

**Evidence:**  
![alt text](<BUG 007_Evidence.png>)

**Impact:** The API fails to handle unsupported shipment status values gracefully, resulting in an internal server error instead of an appropriate client validation error. This prevents API consumers from receiving accurate feedback about invalid input and indicates inadequate input validation or error handling.