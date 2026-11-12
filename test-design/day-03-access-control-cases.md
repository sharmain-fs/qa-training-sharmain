# Negative and Security Test Cases

**Purpose:** Design-only security test cases for Day 5 execution.  
**Techniques:** Authorization matrix testing, negative testing, IDOR/BOLA, token validation, state transition testing.  
**Total:** 21 cases (9 Critical, 12 High).

## Test data

## Users

| User | Password | Role | Merchant |
|---|---|---|---|
| ana | Ana#2026 | merchant_admin | 1 (Northwind Crafts) |
| ben | Ben#2026 | merchant_staff | 1 (Northwind Crafts) |
| cara | Cara#2026 | merchant_admin | 2 (Bayside Bakery) |
| sam | Sam#2026 | support | read-only by policy |
| dex | Dex#2026 | courier (id 7) | sees only shipments assigned to courier 7 |

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


## B. ID tampering / IDOR / BOLA

### TC-007 — Merchant admin tampers with read shipment ID
- **Priority:** Critical
- **User:** merchant_admin, Merchant A
- **Request:** `GET /api/shipments/SHP-201` (replace owned ID `SHP-101` with `SHP-201`)
- **Body:** None
- **Expected:** `404 Not Found`; no cross-merchant data.
- **Why:** Tests object-level authorization on reads.
- **Critical justification:** Cross-merchant shipment details could be exposed.


### TC-008 — Merchant staff tampers with read shipment ID
- **Priority:** Critical
- **User:** merchant_staff, Merchant A
- **Request:** `GET /api/shipments/SHP-201` (replace `SHP-101`)
- **Body:** None
- **Expected:** `404 Not Found`.
- **Why:** Staff must not bypass merchant boundaries by guessing IDs.
- **Critical justification:** Cross-merchant shipment details could be exposed.


### TC-009 — Merchant Admin Cannot Enumerate Shipment IDs
- **Priority:** Critical
- **User:** merchant_admin, Merchant A
- **Precondition:** SHP-201 belongs to Merchant B; SHP-999 does not exist.
- **Request 1:** `GET /api/shipments/SHP-201`
- **Request 2:** `GET /api/shipments/SHP-999`
- **Body:** None
- **Expected:** Both requests return `404 Not Found` with identical response bodies and no shipment details disclosed.
- **Why:** Verify that the API does not reveal whether a shipment belongs to another merchant or does not exist.
- **Critical justification:** Different responses could allow attackers to enumerate valid shipment IDs and identify other merchants' shipments.


### TC-010 — Merchant Staff Cannot Enumerate Shipment IDs
- **Priority:** Critical
- **User:** merchant_staff, Merchant A
- **Precondition:** SHP-201 belongs to Merchant B; SHP-999 does not exist.
- **Request 1:** `GET /api/shipments/SHP-201`
- **Request 2:** `GET /api/shipments/SHP-999`
- **Body:** None
- **Expected:** Both requests return `404 Not Found` with identical response bodies and no shipment details disclosed.
- **Why:** Verify that merchant staff cannot determine which shipment IDs exist outside their authorized access.
- **Critical justification:** Exposing valid shipment IDs could help attackers identify and target shipments belonging to other merchants.


**Why is it a problem if read returns 404 but write returns 200?** The read endpoint blocks cross-merchant access, but the write endpoint fails object-level authorization. A user can alter a shipment they cannot view. Each HTTP method and object must be authorized independently; verify there are no downstream side effects.

## C. Authentication and token security

### TC-011 — Missing token
- **Priority:** High
- **User:** unauthenticated
- **Request:** `GET /api/shipments/SHP-101` without Authorization header
- **Body:** None
- **Expected:** `401 Unauthorized`.
- **Why:** Protected resources require authentication.


### TC-012 — Malformed token
- **Priority:** High
- **User:** invalid-token caller
- **Request:** `GET /api/shipments/SHP-101` with `Authorization: Bearer invalid.token.value`
- **Body:** None
- **Expected:** `401 Unauthorized`.
- **Why:** Invalid token structure/signature must be rejected.


### TC-013 — Another user's valid token, unauthorized object
- **Priority:** Critical
- **User:** Caller presents Merchant B user's valid token
- **Request:** `GET /api/shipments/SHP-101` with Merchant B token
- **Body:** None
- **Expected:** `404 Not Found`, because token owner Merchant B cannot read Merchant A shipment.
- **Why:** Permissions must derive from the authenticated token identity.
- **Critical justification:** Incorrect identity handling could expose data across merchants.


## D. Courier assignment and cancellation restrictions

### TC-014 — Courier reads unassigned shipment of same merchant
- **Priority:** High
- **User:** Courier A
- **Request:** `GET /api/shipments/SHP-101`
- **Body:** None
- **Expected:** `404 Not Found`
- **Why:** Courier reads must be limited to assigned shipments.


### TC-015 — Courier reads another courier's shipment
- **Priority:** High
- **User:** Courier A
- **Request:** `GET /api/shipments/SHP-302`
- **Body:** None
- **Expected:** `404 Not Found`
- **Why:** Assignment, not merchant ownership, determines courier access.


### TC-016 — Courier changes unassigned shipment status
- **Priority:** Critical
- **User:** Courier A
- **Request:** `PATCH /api/shipments/SHP-302/status`
- **Body:** `{"status":"Delivered"}`
- **Expected:** `404 Not Found`
- **Why:** Couriers must not modify shipments assigned to other couriers.
- **Critical justification:** False delivery confirmation can trigger financial and operational losses.


### TC-017 — Courier changes Cancelled shipment
- **Priority:** High
- **User:** Courier A (assigned to SHP-402)
- **Precondition:** SHP-402 is already in Cancelled status.
- **Request:** `PATCH /api/shipments/SHP-402/status`
- **Body:** `{"status":"InTransit"}`
- **Expected:** `403 Forbidden` per explicit courier rule; status remains Cancelled.
- **Why:** Courier cannot update a Cancelled shipment even when assigned.


### TC-018 — Courier Attempts to Cancel an Assigned Shipment
- **Priority:** High
- **User:** Courier A (assigned to SHP-402)
- **Precondition:** SHP-402 is in an active state, such as InTransit.
- **Request:** `PATCH /api/shipments/SHP-402/status`
- **Body:** `{"status":"Cancelled"}`
- **Expected:** `403 Forbidden` per explicit courier rule; status remains InTransit.
- **Why:** Courier cannot cancel a shipment even when assigned.


## E. Final-state and invalid transition protection

### TC-019 — Delivered back to InTransit
- **Priority:** Critical
- **User:** merchant_admin, Merchant A
- **Request:** `PATCH /api/shipments/SHP-401/status`
- **Body:** `{"status":"InTransit"}`
- **Expected:** `409 Conflict` (proposed; confirm API contract); remains Delivered.
- **Why:** Delivered is a final state.
- **Critical justification:** Reopening completed deliveries can corrupt final records and settlements.


### TC-020 — Delivered back to PickedUp
- **Priority:** High
- **User:** merchant_staff, Merchant A
- **Request:** `PATCH /api/shipments/SHP-401/status`
- **Body:** `{"status":"PickedUp"}`
- **Expected:** `409 Conflict` (proposed); remains Delivered.
- **Why:** Rejects backward lifecycle transitions.


### TC-021 — Cancelled back to InTransit
- **Priority:** High
- **User:** merchant_admin, Merchant A
- **Request:** `PATCH /api/shipments/SHP-402/status`
- **Body:** `{"status":"InTransit"}`
- **Expected:** `409 Conflict` (proposed); remains Cancelled.
- **Why:** Cancelled is a final state.


## Coverage summary

| Area | Cases |
|---|---:|
| Role-based restrictions | 6 |
| ID tampering | 4 |
| Authentication/token problems | 3 |
| Courier assignment restrictions | 5 |
| Final-state transitions | 3 |
| **Total** | **21** |

**Priority summary:** 9 Critical, 12 High, 0 Medium, 0 Low. Some scenarios deliberately overlap because they test different threat mechanisms.
