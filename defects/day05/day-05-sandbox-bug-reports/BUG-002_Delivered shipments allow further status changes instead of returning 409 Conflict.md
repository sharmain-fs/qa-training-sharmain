## BUG-002 — Delivered shipments allow further status changes instead of returning 409 Conflict

**Environment:**
- Sandbox version: v3.4.0
- Testing tool: Postman
- Username: ana (proposed retest account)
- Role: merchant_admin
- Merchant ID: 1

**Preconditions:**
- Merchant admin is authenticated with a valid token.
- Shipment ID: 1004
- Shipment owner: Merchant 1
- Shipment status before each request: Delivered

**Steps to Reproduce:**
1. Restart the sandbox to restore the original test data.
2. Log in as ana, a merchant admin of Merchant 1.
3. Send `GET http://localhost:4010/shipments/1004`.
4. Verify that shipment 1004 is in Delivered status.
5. Send the PATCH request with PickedUp as the requested status.
6. Observe the response status and body.
7. Retrieve shipment 1004 again to verify its resulting status.
8. Restart the sandbox and log in again.
9. Verify that shipment 1004 is back in Delivered status.
10. Repeat the PATCH request with InTransit as the requested status.
11. Observe the response and verify the resulting shipment status.

**Request 1:**
```http
PATCH http://localhost:4010/shipments/1004/status
```

```json
{
    "status": "PickedUp"
}
```

**Request 2:**
```http
PATCH http://localhost:4010/shipments/1004/status
```

```json
{
    "status": "InTransit"
}
```

**Expected:** `409 Conflict` for all disallowed status transitions; the shipment status remains Delivered.

**README rule:** “Delivered, Returned, Cancelled are final (no further changes).” Also: “A disallowed move returns **409**.”

**Actual:** The API fails to reject status update requests for shipments in Delivered status as required by the README.

**Test Results:**

| Initial Status | Requested Status | Expected Response | Actual Response |
|---|---|---|---|
| Delivered | PickedUp | 409 Conflict | [Verified response code] |
| Delivered | InTransit | 409 Conflict | [Verified response code] |

**Severity:** High

**Priority:** High (proposed) — Should be addressed before release because allowing changes to finalized shipments could compromise delivery records, tracking accuracy, and downstream business processes.

**Evidence:**  
![alt text](<BUG 002_Evidence.png>)
![alt text](<BUG 003_Evidence_GET Request.png>)
![alt text](<BUG 003_Evidence_PATCH Request.png>)

**Impact:** Allowing further status changes to finalized shipments could result in inaccurate delivery records, inconsistent tracking information, and incorrect shipment lifecycle history. Completed shipments could be reopened or moved back to an earlier delivery stage.

**Consolidation Note:** BUG-003 has been merged into BUG-002 because both reports describe the same final-state validation defect.