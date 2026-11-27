## BUG-005 — Merchant admin can modify another merchant's shipment: PATCH returns 200 instead of 404

**Environment:**
- Sandbox version: v3.4.0
- Testing tool: Postman
- Username: ana (proposed retest account)
- Role: merchant_admin
- Authenticated merchant ID: 1
- Target merchant ID: 2

**Preconditions:**
- Merchant 1 admin is authenticated with a valid token.
- Shipment ID: 1009
- Shipment owner: Merchant 2
- Shipment status before request: InTransit
- Merchant 1 must not have permission to modify Merchant 2 shipments.

**Steps to Reproduce:**
1. Restart the sandbox to restore the original test data.
2. Log in as cara, a merchant admin of Merchant 2.
3. Send `GET http://localhost:4010/shipments/1009`.
4. Verify that shipment 1009 belongs to Merchant 2 and is in InTransit status.
5. Log in as ana, a merchant admin of Merchant 1.
6. Send the PATCH request below using ana's token.
7. Observe the response status and body.
8. Using cara's token, retrieve shipment 1009 again.
9. Verify whether the shipment status was modified.

**Request:**
```http
PATCH http://localhost:4010/shipments/1009/status
```

```json
{
    "status": "Delivered"
}
```

**Expected:** `404 Not Found`; Merchant 1 must not be able to modify shipment 1009, and its status remains InTransit.

**README rule:** “Merchant users see only their own merchant's shipments.” Also: “A shipment you are not allowed to see behaves as if it does not exist (404).”

**Actual:** `200 OK` was returned in the original test. The merchant admin successfully modified a shipment belonging to another merchant.

**Severity:** Critical

**Severity Justification:** The defect violates tenant isolation and allows unauthorized modification of another merchant's shipment records.

**Priority:** Urgent (proposed) — Requires immediate remediation because one merchant can modify another merchant's shipment records, compromising tenant isolation, data integrity, and customer trust.

**Evidence:**
![GET shipment 1009 using Merchant 2 token showing shipment ownership and starting status](BUG-005_Evidence_GET_Before.png)
![Merchant 1 PATCH request targeting Merchant 2 shipment returns 200 OK instead of 404 Not Found](BUG-005_Evidence_PATCH_Request.png)
![GET shipment 1009 using Merchant 2 token after the unauthorized update](BUG-005_Evidence_GET_After.png)

**Impact:** A merchant admin successfully modified another merchant's shipment status, violating tenant isolation and compromising cross-merchant data integrity.