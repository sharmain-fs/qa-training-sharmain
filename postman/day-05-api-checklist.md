# API Test Checklist — Track 1 OWASP + Track 2 Postman

**System:** Parcel Shipment Management API  
**Sandbox:** v3.4.0  
**Scope:** OWASP Top 10 - A01 Broken Access Control and A07 Identification and Authentication Failures; practical API execution in Postman.  

## 1. Setup and test-data controls

- [ ] Read the v3.4.0 README and confirm endpoint paths and role permissions.
- [ ] Verify sandbox version v3.4.0 and API reachability.
- [ ] Configure Postman environment variables `baseUrl`, `merchantAdminToken`, `merchantStaffToken`, `supportToken`, `courierToken`, and shipment IDs. Never paste live tokens into screenshots or bug tickets.
- [ ] Identify Merchant A and Merchant B shipments, courier-assigned and unassigned shipments, and their current owners/statuses.
- [ ] Confirm each tester can retrieve response status, body, and request details in Postman.

## 2. Track 1 — A07 Identification and Authentication Failures

**README rule:** No token -> `401`; invalid or expired token -> `401`.

| Done | ID | Postman action | Expected | Evidence |
|---|---|---|---|---|
| [ ] | AUTH-01 | GET a protected shipment without an Authorization header | `401` | Status and sanitized body |
| [ ] | AUTH-02 | Repeat GET with `Authorization: Bearer invalid-token` | `401` | Status and sanitized body |
| [ ] | AUTH-03 | Repeat GET with a confirmed expired token | `401` | Status and sanitized body |
| [ ] | AUTH-04 | Repeat protected PATCH with no token; use a valid status value | `401`; no change | Before/after status |
| [ ] | AUTH-05 | Repeat protected PATCH with invalid token | `401`; no change | Before/after status |
| [ ] | AUTH-06 | Repeat protected PATCH with expired token | `401`; no change | Before/after status |

**Execution note:** Confirm the token is truly expired rather than simply malformed. A valid token does not imply authorization for a particular resource; those checks belong in A01.

## 3. Track 1 — A01 Broken Access Control: read permissions

**README rule:** Merchant users see only their own merchant's shipments; support reads all; courier reads only assigned shipments; a shipment not visible to a role returns `404`.

| Done | ID | Role | Request | Expected |
|---|---|---|---|---|
| [ ] | BAC-R01 | Merchant A admin | `GET /api/shipments/SHP-101` | Accessible |
| [ ] | BAC-R02 | Merchant A staff | `GET /api/shipments/SHP-101` | Accessible |
| [ ] | BAC-R03 | Merchant A admin | `GET /api/shipments/SHP-201` | `404` |
| [ ] | BAC-R04 | Merchant A staff | `GET /api/shipments/SHP-201` | `404` |
| [ ] | BAC-R05 | Support | GET SHP-101 and SHP-201 | Both accessible |
| [ ] | BAC-R06 | Courier A | GET confirmed assigned shipment | Accessible |
| [ ] | BAC-R07 | Courier A | GET confirmed unassigned shipment | `404` |
| [ ] | BAC-R08 | Merchant A user | List shipments, if endpoint supported | No Merchant B records |
| [ ] | BAC-R09 | Courier A | List shipments, if endpoint supported | Only assigned records |

For accessible GET requests, verify success and the correct resource, not merely a `2xx` status. Use the documented route and response schema; skip list tests if no list endpoint exists.

## 4. Track 1 — A01 Broken Access Control: write permissions and IDOR

**README rules:** Support cannot change status (`403`). Couriers cannot set `Cancelled` (`403`). Merchant users may update only their merchant's shipments; inaccessible shipment IDs behave as nonexistent (`404`).

| Done | ID / prior TC | Role | PATCH request body | Expected |
|---|---|---|---|---|
| [ ] | BAC-W01 / TC-005 | Support | `/api/shipments/SHP-101/status` `{"status":"Delivered"}` | `403`; unchanged |
| [ ] | BAC-W02 / TC-006 | Support | `/api/shipments/SHP-201/status` `{"status":"Delivered"}` | `403`; unchanged |
| [ ] | BAC-W03 / TC-011 | Merchant A admin | `/api/shipments/SHP-201/status` `{"status":"Delivered"}` | `404`; unchanged |
| [ ] | BAC-W04 / TC-012 | Merchant A staff | `/api/shipments/SHP-201/status` `{"status":"Returned"}` | `404`; unchanged |
| [ ] | BAC-W05 / TC-021 | Courier A assigned to SHP-402 | `/api/shipments/SHP-402/status` `{"status":"Cancelled"}` | `403`; unchanged |
| [ ] | BAC-W06 | Courier A | PATCH confirmed unassigned shipment to a known status | `404`; unchanged |
| [ ] | BAC-W07 | Support | `POST /api/shipments` with otherwise-valid data | `403`; no shipment created |
| [ ] | BAC-W08 | Courier A | `POST /api/shipments` with otherwise-valid data | `403`; no shipment created |
| [ ] | BAC-W09 | Merchant A admin | Create shipment with valid data | `201`; `status: "Created"` |

**IDOR procedure:** (1) Authenticate as Merchant A; (2) confirm access to SHP-101; (3) change only the path ID to SHP-201; (4) send PATCH; (5) verify `404`; (6) use an authorized account to GET SHP-201 and compare with baseline. This tests authorization independently of whether the requested status transition would otherwise be valid.

## 5. Track 2 — Postman execution and assertions

- [ ] Use separate environment variables for each role token; select the intended token explicitly per request.
- [ ] Confirm request method, URL, headers, and JSON body in Postman before sending.
- [ ] For a denied request, check exact HTTP status and response body; do not mark a test passed merely because an error was returned.
- [ ] After denied PATCH/POST, perform an authorized read/list to confirm no unauthorized change or creation occurred.
- [ ] Verify returned shipment ID and ownership on successful reads; check list results for cross-merchant leakage.
- [ ] Run tests independently or reset data between tests to prevent status-lifecycle interference.
- [ ] Run the collection with Postman Collection Runner and save a sanitized result export or screenshots.

**Example Postman post-response script for a `403` scenario:**

```javascript
pm.test('Unauthorized write is forbidden', function () {
  pm.response.to.have.status(403);
});
```

**Example for cross-merchant `404`:**

```javascript
pm.test('Cross-merchant resource is hidden', function () {
  pm.response.to.have.status(404);
});
```

These scripts only validate response codes. A separate authorized GET is needed to establish that the data remained unchanged.

## 6. Supporting integrity checks — status lifecycle (not the primary OWASP focus)

**README rule:** `Created -> PickedUp | Cancelled`; `PickedUp -> InTransit`; `InTransit -> Delivered | Returned`; Delivered, Returned, and Cancelled are final. Disallowed transitions -> `409`; unknown status -> `400`.

| Done | ID / prior TC | Request | Expected |
|---|---|---|---|
| [ ] | LIFE-01 / TC-023 | Merchant A admin: SHP-401 Delivered -> InTransit | `409`; stays Delivered |
| [ ] | LIFE-02 / TC-024 | Merchant A staff: SHP-401 Delivered -> PickedUp | `409`; stays Delivered |
| [ ] | LIFE-03 / TC-025 | Merchant A admin: SHP-402 Cancelled -> InTransit | `409`; stays Cancelled |
| [ ] | LIFE-04 | Authorized user requests unknown status | `400`; unchanged |

Confirm baseline states first. A status-code mismatch is not proof that an unauthorized state mutation occurred.

## 7. Evidence, reporting, and exit criteria

- [ ] For every test, record ID, role, sandbox version, method, sanitized URL/body, expected result, actual HTTP code/body, timestamp, and pass/fail.
- [ ] For failed writes, capture before-and-after shipment state using an authorized account.
- [ ] Mask bearer tokens, credentials, and personal information in evidence.
- [ ] For each confirmed defect, record: **Title, Environment (v3.4.0 + user/role), Request, Expected (quote or cite README rule), Actual, Severity, Priority, Evidence**.

**Pass criteria:** The observed status, resource visibility, and persisted data match the README. **Blocked:** Required token, fixture, or reset capability is unavailable. 
**Fail:** A reproducible observed result contradicts the README; attach evidence.
