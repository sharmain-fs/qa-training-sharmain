# Negative and Security Test Cases

**Purpose:** Design-only security test cases for Day 5 execution.  
**Techniques:** Authorization matrix testing, negative testing, IDOR/BOLA, token validation, state transition testing.  
**Total:** 25 cases (11 Critical, 14 High).

## Test data

| Shipment | Setup |
|---|---|
| SHP-101 | Merchant A, InTransit, not assigned to Courier A |
| SHP-201 | Merchant B, InTransit |
| SHP-301 | Merchant A, assigned to Courier A, InTransit |
| SHP-302 | Merchant B, assigned to Courier B, InTransit |
| SHP-401 | Merchant A, Delivered |
| SHP-402 | Merchant A, Cancelled, assigned to Courier A |

## Users

| User | Password | Role | Merchant |
|---|---|---|---|
| ana | see the sandbox README | merchant_admin | 1 (Northwind Crafts) |
| ben | see the sandbox README | merchant_staff | 1 (Northwind Crafts) |
| cara | see the sandbox README | merchant_admin | 2 (Bayside Bakery) |
| sam | see the sandbox README | support | read-only by policy |
| dex | see the sandbox README | courier (id 7) | sees only shipments assigned to courier 7 |

## Endpoints

| Method | Path | Notes |
|---|---|---|
| GET | `/health` | No token needed |
| POST | `/auth/login` | Body `{"username","password"}` → `{"token","role","merchantId"}` |
| GET | `/shipments` | Shipments you are allowed to see. Optional `?status=Delivered` |
| POST | `/shipments` | Create. Body `{"recipientName","city","weightKg","service"}` |
| GET | `/shipments/{id}` | One shipment |
| GET | `/shipments/{id}/events` | Tracking history |
| PATCH | `/shipments/{id}/status` | Body `{"status": "PickedUp"}` |

Unless stated otherwise, requests include `Authorization: Bearer <role-specific-token>`. All requests use JSON where a body is shown. `401` for missing/invalid authentication and `403` for forbidden actions are assumed defaults. Courier read denials and invalid-state response codes need confirmation. A valid token from a different user is evaluated as *that token owner's identity*, not automatically rejected.

## A. Role-based access restrictions

### TC-001 — Merchant admin reads another merchant's shipment
- **Priority:** Critical
- **User:** merchant_admin, Merchant A
- **Request:** `GET {{baseurl}}/shipments/SHP-201`
- **Body:** None
- **Expected:** `404 Not Found`; no shipment details disclosed.
- **Why:** Prevents cross-merchant data exposure.
- **Critical justification:** Another merchant's shipment data could be exposed.


### TC-002 — Merchant staff reads another merchant's shipment
- **Priority:** Critical
- **User:** merchant_staff, Merchant A
- **Request:** `GET {{baseurl}}/shipments/SHP-201`
- **Body:** None
- **Expected:** `404 Not Found`; no shipment details disclosed.
- **Why:** Enforces tenant isolation for staff.
- **Critical justification:** Another merchant's shipment data could be exposed.


### TC-003 — Support creates shipment
- **Priority:** High
- **User:** support
- **Request:** `POST {{baseurl}}/shipments`
- **Body:** `{"merchantId":"A","weight":2,"service":"Standard"}`
- **Expected:** `403 Forbidden`; no shipment created.
- **Why:** Support has no shipment creation permission.


### TC-004 — Courier creates shipment
- **Priority:** High
- **User:** courier, Courier A
- **Request:** `POST {{baseurl}}/shipments`
- **Body:** `{"merchantId":"A","weight":2,"service":"Standard"}`
- **Expected:** `403 Forbidden`; no shipment created.
- **Why:** Couriers cannot perform merchant-only actions.


### TC-005 — Support changes Merchant A shipment status
- **Priority:** High
- **User:** support
- **Request:** `PATCH {{baseurl}}/shipments/SHP-101/status`
- **Body:** `{"status":"Delivered"}`
- **Expected:** `403 Forbidden`; status unchanged.
- **Why:** Read access does not grant write access.


### TC-006 — Support changes Merchant B shipment status
- **Priority:** High
- **User:** support
- **Request:** `PATCH {{baseurl}}/shipments/SHP-201/status`
- **Body:** `{"status":"Delivered"}`
- **Expected:** `403 Forbidden`; status unchanged.
- **Why:** Support cannot change status for any merchant.


## B. ID tampering / IDOR / BOLA

### TC-007 — Merchant admin tampers with read shipment ID
- **Priority:** Critical
- **User:** merchant_admin, Merchant A
- **Request:** `GET {{baseurl}}/shipments/SHP-201` (replace owned ID `SHP-101` with `SHP-201`)
- **Body:** None
- **Expected:** `404 Not Found`; no cross-merchant data.
- **Why:** Tests object-level authorization on reads.
- **Critical justification:** Cross-merchant shipment details could be exposed.


### TC-008 — Merchant staff tampers with read shipment ID
- **Priority:** Critical
- **User:** merchant_staff, Merchant A
- **Request:** `GET {{baseurl}}/shipments/SHP-201` (replace `SHP-101`)
- **Body:** None
- **Expected:** `404 Not Found`.
- **Why:** Staff must not bypass merchant boundaries by guessing IDs.
- **Critical justification:** Cross-merchant shipment details could be exposed.


### TC-009 — Merchant admin tampers with write shipment ID
- **Priority:** Critical
- **User:** merchant_admin, Merchant A
- **Request:** `PATCH {{baseurl}}/shipments/SHP-201/status` (replace `SHP-101`)
- **Body:** `{"status":"Delivered"}`
- **Expected:** `404 Not Found`; SHP-201 unchanged.
- **Why:** Write requests need independent ownership checks.
- **Critical justification:** Another merchant's delivery record could be irreversibly altered.

### TC-010 — Merchant staff tampers with write shipment ID
- **Priority:** Critical
- **User:** merchant_staff, Merchant A
- **Request:** `PATCH {{baseurl}}/shipments/SHP-201/status` (replace `SHP-101`)
- **Body:** `{"status":"Returned"}`
- **Expected:** `404 Not Found`; SHP-201 unchanged.
- **Why:** Prevents cross-merchant shipment manipulation.
- **Critical justification:** Unauthorized returns can affect money and delivery records.


### TC-011 — Merchant Admin Cannot Enumerate Shipment IDs
- **Priority:** Critical
- **User:** merchant_admin, Merchant A
- **Precondition:** SHP-201 belongs to Merchant B; SHP-999 does not exist.
- **Request 1:** `GET {{baseurl}}/shipments/SHP-201`
- **Request 2:** `GET {{baseurl}}/shipments/SHP-999`
- **Body:** None
- **Expected:** Both requests return `404 Not Found` with identical response bodies and no shipment details disclosed.
- **Why:** Verify that the API does not reveal whether a shipment belongs to another merchant or does not exist.
- **Critical justification:** Different responses could allow attackers to enumerate valid shipment IDs and identify other merchants' shipments.


### TC-012 — Merchant Staff Cannot Enumerate Shipment IDs
- **Priority:** Critical
- **User:** merchant_staff, Merchant A
- **Precondition:** SHP-201 belongs to Merchant B; SHP-999 does not exist.
- **Request 1:** `GET {{baseurl}}/shipments/SHP-201`
- **Request 2:** `GET {{baseurl}}/shipments/SHP-999`
- **Body:** None
- **Expected:** Both requests return `404 Not Found` with identical response bodies and no shipment details disclosed.
- **Why:** Verify that merchant staff cannot determine which shipment IDs exist outside their authorized access.
- **Critical justification:** Exposing valid shipment IDs could help attackers identify and target shipments belonging to other merchants.


**Why is it a problem if read returns 404 but write returns 200?** The read endpoint blocks cross-merchant access, but the write endpoint fails object-level authorization. A user can alter a shipment they cannot view. Each HTTP method and object must be authorized independently; verify there are no downstream side effects.

## C. Authentication and token security

### TC-013 — Missing token
- **Priority:** High
- **User:** unauthenticated
- **Request:** `GET {{baseurl}}/shipments/SHP-101` without Authorization header
- **Body:** None
- **Expected:** `401 Unauthorized`.
- **Why:** Protected resources require authentication.


### TC-014 — Malformed token
- **Priority:** High
- **User:** invalid-token caller
- **Request:** `GET {{baseurl}}/shipments/SHP-101` with `Authorization: Bearer invalid.token.value`
- **Body:** None
- **Expected:** `401 Unauthorized`.
- **Why:** Invalid token structure/signature must be rejected.


### TC-015 — Another user's valid token, unauthorized object
- **Priority:** Critical
- **User:** Caller presents Merchant B user's valid token
- **Request:** `GET {{baseurl}}/shipments/SHP-101` with Merchant B token
- **Body:** None
- **Expected:** `404 Not Found`, because token owner Merchant B cannot read Merchant A shipment.
- **Why:** Permissions must derive from the authenticated token identity.
- **Critical justification:** Incorrect identity handling could expose data across merchants.


### TC-016 — Logout session
- **Priority:** High
- **User:** Authenticated user (merchant_admin)
- **Request:** `POST {{baseurl}}/auth/logout` with `Authorization: Bearer <valid_token>`
- **Body:** None
- **Expected:** `200 OK or 204 No Content`, depending on the API specification. The user is successfully logged out, and the session token is invalidated if the API supports server-side token revocation. Subsequent requests using the revoked token should return 401 Unauthorized.
- **Why:** Logging out should securely terminate the authenticated session and prevent unauthorized access using an invalidated token.
- **High justification:** Failure to invalidate a session token after logout could allow unauthorized access to protected resources.

### TC-017 — Access protected resource using token after logout
- **Priority:** High
- **User:** Logged-out user (previously authenticated merchant_admin)
- **Precondition:** User has successfully logged in, obtained a valid authentication token, and logged out using POST {{baseurl}}/auth/logout. The original token must be saved before logout for reuse in this test.
- **Request:** `GET {{baseurl}}/shipments/SHP-101` with `Authorization: Bearer <logged_out_token>`
- **Body:** None
- **Expected:** `401 Unauthorized`, the system rejects the previously valid token because the session has been terminated. No shipment information is returned.
- **Why:** Verifies that authentication tokens are invalidated after logout and cannot be reused to access protected resources.
- **High justification:** If a logged-out token remains valid, an attacker who obtains the token could continue accessing sensitive shipment information even after the legitimate user has logged out.


## D. Courier assignment and cancellation restrictions

### TC-018 — Courier reads unassigned shipment of same merchant
- **Priority:** High
- **User:** Courier A
- **Request:** `GET {{baseurl}}/shipments/SHP-101`
- **Body:** None
- **Expected:** `404 Not Found`
- **Why:** Courier reads must be limited to assigned shipments.


### TC-019 — Courier reads another courier's shipment
- **Priority:** High
- **User:** Courier A
- **Request:** `GET {{baseurl}}/shipments/SHP-302`
- **Body:** None
- **Expected:** `404 Not Found`
- **Why:** Assignment, not merchant ownership, determines courier access.


### TC-020 — Courier changes unassigned shipment status
- **Priority:** Critical
- **User:** Courier A
- **Request:** `PATCH {{baseurl}}/shipments/SHP-302/status`
- **Body:** `{"status":"Delivered"}`
- **Expected:** `404 Not Found`
- **Why:** Couriers must not modify shipments assigned to other couriers.
- **Critical justification:** False delivery confirmation can trigger financial and operational losses.


### TC-021 — Courier changes Cancelled shipment
- **Priority:** High
- **User:** Courier A (assigned to SHP-402)
- **Precondition:** SHP-402 is already in Cancelled status.
- **Request:** `PATCH {{baseurl}}/shipments/SHP-402/status`
- **Body:** `{"status":"InTransit"}`
- **Expected:** `403 Forbidden` per explicit courier rule; status remains Cancelled.
- **Why:** Courier cannot update a Cancelled shipment even when assigned.


### TC-022 — Courier Attempts to Cancel an Assigned Shipment
- **Priority:** High
- **User:** Courier A (assigned to SHP-402)
- **Precondition:** SHP-402 is in an active state, such as InTransit.
- **Request:** `PATCH {{baseurl}}/shipments/SHP-402/status`
- **Body:** `{"status":"Cancelled"}`
- **Expected:** `403 Forbidden` per explicit courier rule; status remains InTransit.
- **Why:** Courier cannot cancel a shipment even when assigned.


## E. Final-state and invalid transition protection

### TC-023 — Delivered back to InTransit
- **Priority:** Critical
- **User:** merchant_admin, Merchant A
- **Request:** `PATCH {{baseurl}}/shipments/SHP-401/status`
- **Body:** `{"status":"InTransit"}`
- **Expected:** `409 Conflict` (proposed; confirm API contract); remains Delivered.
- **Why:** Delivered is a final state.
- **Critical justification:** Reopening completed deliveries can corrupt final records and settlements.


### TC-024 — Delivered back to PickedUp
- **Priority:** High
- **User:** merchant_staff, Merchant A
- **Request:** `PATCH {{baseurl}}/shipments/SHP-401/status`
- **Body:** `{"status":"PickedUp"}`
- **Expected:** `409 Conflict` (proposed); remains Delivered.
- **Why:** Rejects backward lifecycle transitions.


### TC-025 — Cancelled back to InTransit
- **Priority:** High
- **User:** merchant_admin, Merchant A
- **Request:** `PATCH {{baseurl}}/shipments/SHP-402/status`
- **Body:** `{"status":"InTransit"}`
- **Expected:** `409 Conflict` (proposed); remains Cancelled.
- **Why:** Cancelled is a final state.


## Coverage summary

| Area | Cases |
|---|---:|
| Role-based restrictions | 6 |
| ID tampering | 4 |
| Authentication/token problems | 7 |
| Courier assignment restrictions | 5 |
| Final-state transitions | 3 |
| **Total** | **25** |

**Priority summary:** 11 Critical, 14 High, 0 Medium, 0 Low. Some scenarios deliberately overlap because they test different threat mechanisms.
