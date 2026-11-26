## BUG-008 — Creating a shipment with an invalid service returns 500 Internal Server Error instead of 400 Bad Request

**Environment:**
- Sandbox version: v3.4.0
- User/role: merchant_admin

**Request:**
```http
POST /api/shipments
```
```json
{
    "recipientName": "Test Recipient",
    "city": "Cebu City",
    "weightKg": 5,
    "service": "Overnight"
}
```

**Expected:** `400 Bad Request`; the unsupported service value is rejected, and no shipment is created.

**README rule:** Only Standard, Express, and SameDay are supported service values. Any unsupported service value must return `400 Bad Request`.

**Actual:** `500 Internal Server Error` response is returned when attempting to create a shipment with an unsupported service value (`Overnight`) instead of the expected `400 Bad Request`.

**Severity:** Medium  
**Priority:** High

**Evidence:**  
![alt text](<BUG 008_Evidence.png>)

**Impact:** The API fails to handle unsupported service values gracefully, resulting in an internal server error instead of an appropriate client validation error. This prevents API consumers from receiving accurate feedback about invalid service values and indicates inadequate input validation or error handling in the shipment creation endpoint.