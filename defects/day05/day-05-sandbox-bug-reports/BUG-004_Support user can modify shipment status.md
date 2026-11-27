## BUG-004 — Read-only support user can change shipment status: PATCH returns 200 instead of 403

**Environment:**
- Sandbox version: v3.4.0
- Testing tool: Postman
- Username: sam
- Role: support

**Preconditions:**
- Support user is authenticated with a valid token.
- Shipment ID: 1003
- Shipment owner: Merchant 1
- Shipment status before request: InTransit
- Support user has read-only access to shipments.

**Steps to Reproduce:**
1. Restart the sandbox to restore the original test data.
2. Log in using the support account.
3. Send `GET http://localhost:4010/shipments/1003` using the support token.
4. Verify that shipment 1003 belongs to Merchant 1 and is in InTransit status.
5. Send the PATCH request below using the same support token.
6. Observe the response status and body.
7. Retrieve shipment 1003 again to verify its resulting status.

**Request:**
```http
PATCH http://localhost:4010/shipments/1003/status
```

```json
{
    "status": "Delivered"
}
```

**Expected:** `403 Forbidden`; shipment 1003 remains in InTransit status.

**README rule:** “Support can read all shipments but **must not change anything**.” Also: “Support may not change status (403).”

**Actual:** `200 OK` was returned in the original test. The support user successfully changed a shipment status to Delivered despite having read-only permissions.

**Severity:** High

**Severity Justification:** The defect violates role-based access control and compromises shipment data integrity by allowing a read-only user to modify shipment records.

**Priority:** Urgent (proposed) — Requires immediate remediation because read-only support accounts can modify shipment records without authorization.

**Evidence:**
![Support account authentication](BUG-004_Evidence_Support_Token.png)
![GET shipment 1003 showing InTransit status before the support update](BUG-004_Evidence_GET_Before.png)
![Support PATCH request returns 200 OK instead of 403 Forbidden](BUG-004_Evidence_PATCH_Request.png)

**Impact:** A read-only support user successfully modified a merchant's shipment status, violating role-based access control and shipment data integrity.