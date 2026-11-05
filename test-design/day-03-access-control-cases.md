# Negative and Security Test Cases

**Purpose:** Design-only security test cases for Day 5 execution.  
**Techniques:** Authorization matrix testing, negative testing, IDOR/BOLA, token validation, state transition testing.  
**Total:** 25 cases (9 Critical, 16 High).

## Assumptions and test data

These endpoints are illustrative; confirm actual API paths and response contracts before execution.

| Action | Assumed endpoint |
|---|---|
| Read shipment | `GET /api/shipments/{id}` |
| Create shipment | `POST /api/shipments` |
| Change status | `PATCH /api/shipments/{id}/status` |
| Cancel shipment | `POST /api/shipments/{id}/cancel` |

| Shipment | Setup |
|---|---|
| SHP-101 | Merchant A, InTransit, not assigned to Courier A |
| SHP-201 | Merchant B, InTransit |
| SHP-301 | Merchant A, assigned to Courier A, InTransit |
| SHP-302 | Merchant B, assigned to Courier B, InTransit |
| SHP-401 | Merchant A, Delivered |
| SHP-402 | Merchant A, Cancelled, assigned to Courier A |

Unless stated otherwise, requests include `Authorization: Bearer <role-specific-token>`. All requests use JSON where a body is shown. `401` for missing/invalid authentication and `403` for forbidden actions are assumed defaults. Courier read denials and invalid-state response codes need confirmation. A valid token from a different user is evaluated as *that token owner's identity*, not automatically rejected.

## A. Role-based access restrictions

### TC-001 — Merchant admin reads another merchant's shipment
- **Priority:** Critical
- **User:** merchant_admin, Merchant A
- **Request:** `GET /api/shipments/SHP-201`
- **Body:** None
- **Expected:** `404 Not Found`; no shipment details disclosed.
- **Why:** Prevents cross-merchant data exposure.
- **Critical justification:** Another merchant's shipment data could be exposed.

### TC-002 — Merchant staff reads another merchant's shipment
- **Priority:** Critical
- **User:** merchant_staff, Merchant A
- **Request:** `GET /api/shipments/SHP-201`
- **Body:** None
- **Expected:** `404 Not Found`; no shipment details disclosed.
- **Why:** Enforces tenant isolation for staff.
- **Critical justification:** Another merchant's shipment data could be exposed.

### TC-003 — Support creates shipment
- **Priority:** High
- **User:** support
- **Request:** `POST /api/shipments`
- **Body:** `{"merchantId":"A","weight":2,"service":"Standard"}`
- **Expected:** `403 Forbidden`; no shipment created.
- **Why:** Support has no shipment creation permission.

### TC-004 — Courier creates shipment
- **Priority:** High
- **User:** courier, Courier A
- **Request:** `POST /api/shipments`
- **Body:** `{"merchantId":"A","weight":2,"service":"Standard"}`
- **Expected:** `403 Forbidden`; no shipment created.
- **Why:** Couriers cannot perform merchant-only actions.

### TC-005 — Support changes Merchant A shipment status
- **Priority:** High
- **User:** support
- **Request:** `PATCH /api/shipments/SHP-101/status`
- **Body:** `{"status":"Delivered"}`
- **Expected:** `403 Forbidden`; status unchanged.
- **Why:** Read access does not grant write access.

### TC-006 — Support changes Merchant B shipment status
- **Priority:** High
- **User:** support
- **Request:** `PATCH /api/shipments/SHP-201/status`
- **Body:** `{"status":"Delivered"}`
- **Expected:** `403 Forbidden`; status unchanged.
- **Why:** Support cannot change status for any merchant.

### TC-007 — Support cancels shipment
- **Priority:** High
- **User:** support
- **Request:** `POST /api/shipments/SHP-101/cancel`
- **Body:** `{}`
- **Expected:** `403 Forbidden` (assumed); no cancellation.
- **Why:** Support has no cancellation permission.

### TC-008 — Courier cancels assigned shipment
- **Priority:** High
- **User:** courier, Courier A
- **Request:** `POST /api/shipments/SHP-301/cancel`
- **Body:** `{}`
- **Expected:** `403 Forbidden`; no cancellation.
- **Why:** Assignment does not grant cancellation rights.

## B. ID tampering / IDOR / BOLA

### TC-009 — Merchant admin tampers with read shipment ID
- **Priority:** Critical
- **User:** merchant_admin, Merchant A
- **Request:** `GET /api/shipments/SHP-201` (replace owned ID `SHP-101` with `SHP-201`)
- **Body:** None
- **Expected:** `404 Not Found`; no cross-merchant data.
- **Why:** Tests object-level authorization on reads.
- **Critical justification:** Cross-merchant shipment details could be exposed.

### TC-010 — Merchant staff tampers with read shipment ID
- **Priority:** Critical
- **User:** merchant_staff, Merchant A
- **Request:** `GET /api/shipments/SHP-201` (replace `SHP-101`)
- **Body:** None
- **Expected:** `404 Not Found`.
- **Why:** Staff must not bypass merchant boundaries by guessing IDs.
- **Critical justification:** Cross-merchant shipment details could be exposed.

### TC-011 — Merchant admin tampers with write shipment ID
- **Priority:** Critical
- **User:** merchant_admin, Merchant A
- **Request:** `PATCH /api/shipments/SHP-201/status` (replace `SHP-101`)
- **Body:** `{"status":"Delivered"}`
- **Expected:** `404 Not Found`; SHP-201 unchanged.
- **Why:** Write requests need independent ownership checks.
- **Critical justification:** Another merchant's delivery record could be irreversibly altered.

### TC-012 — Merchant staff tampers with write shipment ID
- **Priority:** Critical
- **User:** merchant_staff, Merchant A
- **Request:** `PATCH /api/shipments/SHP-201/status` (replace `SHP-101`)
- **Body:** `{"status":"Returned"}`
- **Expected:** `404 Not Found`; SHP-201 unchanged.
- **Why:** Prevents cross-merchant shipment manipulation.
- **Critical justification:** Unauthorized returns can affect money and delivery records.

**Why is it a problem if read returns 404 but write returns 200?** The read endpoint blocks cross-merchant access, but the write endpoint fails object-level authorization. A user can alter a shipment they cannot view. Each HTTP method and object must be authorized independently; verify there are no downstream side effects.

## C. Authentication and token security

### TC-013 — Missing token
- **Priority:** High
- **User:** unauthenticated
- **Request:** `GET /api/shipments/SHP-101` without Authorization header
- **Body:** None
- **Expected:** `401 Unauthorized`.
- **Why:** Protected resources require authentication.

### TC-014 — Malformed token
- **Priority:** High
- **User:** invalid-token caller
- **Request:** `GET /api/shipments/SHP-101` with `Authorization: Bearer invalid.token.value`
- **Body:** None
- **Expected:** `401 Unauthorized`.
- **Why:** Invalid token structure/signature must be rejected.

### TC-015 — Logged-out session token reuse
- **Priority:** High
- **User:** logged-out merchant_admin
- **Request:** `GET /api/shipments/SHP-101` with previously issued token
- **Body:** None
- **Expected:** `401 Unauthorized` **if** logout revokes the token; confirm logout/session policy (a stateless JWT may remain valid until expiry).
- **Why:** Tests whether session invalidation matches the security design.

### TC-016 — Another user's valid token, unauthorized object
- **Priority:** Critical
- **User:** Caller presents Merchant B user's valid token
- **Request:** `GET /api/shipments/SHP-101` with Merchant B token
- **Body:** None
- **Expected:** `404 Not Found`, because token owner Merchant B cannot read Merchant A shipment.
- **Why:** Permissions must derive from the authenticated token identity.
- **Critical justification:** Incorrect identity handling could expose data across merchants.

### TC-017 — Forged elevated role in token
- **Priority:** Critical
- **User:** merchant_staff, token payload altered to claim `merchant_admin` without a valid signature
- **Request:** `POST /api/shipments/SHP-101/cancel` with altered bearer token
- **Body:** `{}`
- **Expected:** `401 Unauthorized`; no cancellation.
- **Why:** Server must validate token integrity and not trust modified role claims.
- **Critical justification:** A forged privileged token could enable irreversible cancellation.

## D. Courier assignment and cancellation restrictions

### TC-018 — Courier reads unassigned shipment of same merchant
- **Priority:** High
- **User:** Courier A
- **Request:** `GET /api/shipments/SHP-101`
- **Body:** None
- **Expected:** `403 Forbidden` (assumed; confirm whether `404` is required).
- **Why:** Courier reads must be limited to assigned shipments.

### TC-019 — Courier reads another courier's shipment
- **Priority:** High
- **User:** Courier A
- **Request:** `GET /api/shipments/SHP-302`
- **Body:** None
- **Expected:** `403 Forbidden` (assumed; confirm whether `404` is required).
- **Why:** Assignment, not merchant ownership, determines courier access.

### TC-020 — Courier changes unassigned shipment status
- **Priority:** Critical
- **User:** Courier A
- **Request:** `PATCH /api/shipments/SHP-302/status`
- **Body:** `{"status":"Delivered"}`
- **Expected:** `403 Forbidden` (assumed); status unchanged.
- **Why:** Couriers must not modify shipments assigned to other couriers.
- **Critical justification:** False delivery confirmation can trigger financial and operational losses.

### TC-021 — Courier changes Cancelled shipment
- **Priority:** High
- **User:** Courier A (assigned to SHP-402)
- **Request:** `PATCH /api/shipments/SHP-402/status`
- **Body:** `{"status":"InTransit"}`
- **Expected:** `403 Forbidden` per explicit courier rule; status unchanged.
- **Why:** Courier cannot update a Cancelled shipment even when assigned.

### TC-022 — Courier cancels assigned shipment
- **Priority:** High
- **User:** Courier A
- **Request:** `POST /api/shipments/SHP-301/cancel`
- **Body:** `{}`
- **Expected:** `403 Forbidden`; no cancellation.
- **Why:** Assignment never grants cancellation rights. This overlaps TC-008 intentionally.

## E. Final-state and invalid transition protection

### TC-023 — Delivered back to InTransit
- **Priority:** Critical
- **User:** merchant_admin, Merchant A
- **Request:** `PATCH /api/shipments/SHP-401/status`
- **Body:** `{"status":"InTransit"}`
- **Expected:** `409 Conflict` (proposed; confirm API contract); remains Delivered.
- **Why:** Delivered is a final state.
- **Critical justification:** Reopening completed deliveries can corrupt final records and settlements.

### TC-024 — Delivered back to PickedUp
- **Priority:** High
- **User:** merchant_staff, Merchant A
- **Request:** `PATCH /api/shipments/SHP-401/status`
- **Body:** `{"status":"PickedUp"}`
- **Expected:** `409 Conflict` (proposed); remains Delivered.
- **Why:** Rejects backward lifecycle transitions.

### TC-025 — Cancelled back to InTransit
- **Priority:** High
- **User:** merchant_admin, Merchant A
- **Request:** `PATCH /api/shipments/SHP-402/status`
- **Body:** `{"status":"InTransit"}`
- **Expected:** `409 Conflict` (proposed); remains Cancelled.
- **Why:** Cancelled is a final state.

## Coverage summary

| Area | Cases |
|---|---:|
| Role-based restrictions | 8 |
| ID tampering | 4 |
| Authentication/token problems | 5 |
| Courier assignment restrictions | 5 |
| Final-state transitions | 3 |
| **Total** | **25** |

**Priority summary:** 9 Critical, 16 High, 0 Medium, 0 Low. Some scenarios deliberately overlap because they test different threat mechanisms.
