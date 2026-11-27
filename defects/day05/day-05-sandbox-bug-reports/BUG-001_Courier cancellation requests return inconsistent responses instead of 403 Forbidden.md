## BUG-001 — Courier cancellation request returns 200 instead of 403 for a Delivered shipment

**Environment:**
- Sandbox version: v3.4.0
- Testing tool: Postman
- Username: dex
- Role: courier
- Courier ID: 7

**Preconditions:**
- Courier is authenticated with a valid token.
- Shipment ID: 1004
- Merchant ID: 1
- Assigned courier ID: 7
- Shipment status before request: Delivered

**Steps to Reproduce:**
1. Restart the sandbox to restore the original test data.
2. Log in as the courier with courier ID 7.
3. Send `GET http://localhost:4010/shipments/1004`.
4. Verify that the shipment is assigned to courier ID 7 and its status is Delivered.
5. Send the PATCH request below using the courier token.
6. Observe the response status and body.
7. Retrieve shipment 1004 again to verify its resulting status.

**Request:**
```http
PATCH http://localhost:4010/shipments/1004/status
```

```json
{
    "status": "Cancelled"
}
```

**Expected:** `403 Forbidden`; shipment 1004 remains in Delivered status.

**README rule:** “Couriers may set PickedUp, InTransit, Delivered, Returned, but **not** Cancelled (403).” Also: “Delivered, Returned, Cancelled are final (no further changes).”

**Actual:** `200 OK` was observed in the original Delivered-to-Cancelled test instead of the expected `403 Forbidden`.

**Additional Test Results:**

| Shipment ID for Retest | Starting Status | Requested Status | Expected | Previously Observed |
|---|---|---|---|---|
| 1004 | Delivered | Cancelled | 403 Forbidden | 200 OK |
| 1003 | InTransit | Cancelled | 403 Forbidden | 409 Conflict |

**Severity:** High

**Severity Justification:** The defect violates courier cancellation restrictions and potentially compromises shipment lifecycle integrity.

**Priority:** High (proposed) — Should be addressed before release because unauthorized courier cancellations could disrupt shipment operations.

**Evidence:**
![Courier cancellation request returns 200 OK instead of 403 Forbidden](BUG-001_Evidence_PATCH_Delivered.png)
![Courier cancellation request for an InTransit shipment returns 409 Conflict](BUG-001_Evidence_PATCH_InTransit.png)

**Impact:** The API returned a successful response for a cancellation request that the courier role is explicitly prohibited from performing.