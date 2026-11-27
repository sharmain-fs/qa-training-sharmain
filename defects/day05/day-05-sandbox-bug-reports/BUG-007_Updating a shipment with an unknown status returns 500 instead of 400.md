## BUG-007 — Updating a shipment with an unknown status returns 500 instead of 400

**Environment:**
- Sandbox version: v3.4.0
- Testing tool: Postman
- Username: ana (proposed retest account)
- Role: merchant_admin
- Merchant ID: 1

**Preconditions:**
- Merchant admin is authenticated with a valid token.
- Shipment ID: 1001
- Shipment owner: Merchant 1
- Shipment status before request: Created

**Steps to Reproduce:**
1. Restart the sandbox to restore the original test data.
2. Log in as ana, a merchant admin of Merchant 1.
3. Send `GET http://localhost:4010/shipments/1001`.
4. Verify that shipment 1001 is in Created status.
5. Send the PATCH request below with an unsupported status value.
6. Observe the response status and body.
7. Retrieve shipment 1001 again to verify whether its status remains unchanged.

**Request:**
```http
PATCH http://localhost:4010/shipments/1001/status
```

```json
{
    "status": "Lost"
}
```

**Expected:** `400 Bad Request`; the unsupported status value is rejected, and shipment 1001 remains in Created status.

**README rule:** An unknown shipment status must return `400 Bad Request`.

**Actual:** `500 Internal Server Error` was returned in the original test instead of the expected `400 Bad Request` when attempting to update a shipment with the unsupported status value Lost.

**Severity:** Medium

**Severity Justification:** The defect affects input validation and API error handling, but no unauthorized access or persisted data corruption has been demonstrated.

**Priority:** High (proposed) — Should be addressed before release because unsupported status values trigger server errors instead of appropriate client validation responses.

**Evidence:**  
![PATCH shipment with unknown Lost status returns 500 Internal Server Error instead of 400 Bad Request](<BUG 007_Evidence.png>)

**Impact:** An unsupported shipment status triggered an internal server error instead of the documented client validation error, preventing API consumers from receiving accurate validation feedback.