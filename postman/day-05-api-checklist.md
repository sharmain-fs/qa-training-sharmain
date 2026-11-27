# API Test Checklist — Track 1 OWASP + Track 2 Postman

**System:** Parcel Shipment Management API | **Sandbox:** v3.4.0  
**Tool:** Postman | **Base URL:** http://localhost:4010

**Test Data Setup:** Restart the sandbox before execution. Use
GET /shipments as ana (Merchant 1), cara (Merchant 2), or
support to identify numeric shipment IDs, ownership, current
status, and courier assignment before testing.

## 1. Authentication — Equivalence Partitioning (OWASP A07)
- [ ] Valid token on an authorized GET → `200`.
- [ ] Missing, invalid, and genuinely expired tokens → `401` each.
- [ ] Repeat authentication checks on POST/PATCH; verify no unauthorized writes.
- [ ] Use separate token variables for each role; confirm authenticated identity.

## 2. Authorization / IDOR — Decision Table (OWASP A01)
- [ ] Merchant admin/staff can read and validly update own shipments; GET /shipments excludes other merchants' records.
- [ ] Find a Merchant 2 shipment in Created status using GET /shipments as cara (e.g., 1007); access or update it as ana → 404.
- [ ] Support can read shipments from both merchants using GET /shipments; POST/PATCH → 403.
- [ ] Find assigned and unassigned shipments using GET /shipments as support; courier can access assigned shipments only, while unassigned GET/PATCH → 404.
- [ ] Courier POST and cancellation of an assigned shipment → 403; verify no creation or status change.

## 3. Input Validation and Boundaries — BVA, EP, Decision Table
- [ ] Standard weight: 0.09/30.01 kg → `400`; 0.1/0.11/29.99/30 kg → `201`.
- [ ] Omit `recipientName` and `city` separately → `400` each.
- [ ] Unsupported service (Overnight) → `400`.
- [ ] SameDay: Cebu City/Mandaue/Lapu-Lapu → `201`; Davao City → `422`.
- [ ] Valid Standard/Express/SameDay → `201`, Created, correct fee per README.

## 4. State Transitions — State Transition Testing
- [ ] Created → PickedUp or Cancelled → `200`.
- [ ] PickedUp → InTransit → `200`.
- [ ] InTransit → Delivered or Returned → `200`.
- [ ] All disallowed transitions, including from Delivered/Returned/Cancelled → `409`; unchanged.
- [ ] Unknown status (Lost) → `400`; unchanged.

## 5. Response / Data Checks — Postman
- [ ] Assert exact expected HTTP status, response body, and agreed response-time threshold.
- [ ] Verify required fields, data types, requested ID, ownership, and list visibility.
- [ ] Assert `items` is a non-empty array before iteration when fixtures guarantee results.
- [ ] Verify successful writes persist through GET; check `updatedAt` for updates.
- [ ] Do not mark a pass merely because an error was returned; verify unchanged state/no creation with an authorized GET/list.

## 6. Evidence and Reporting
- [ ] Confirm README, routes (`/shipments`, `/shipments/{id}/status`), and fixtures; reset data and verify starting states before writes.
- [ ] Record test ID, username/role, exact URL, payload, expected/actual status and body, and PASS/FAIL/BLOCKED.
- [ ] Capture before/after evidence; mask tokens, credentials, and personal information.
- [ ] File reproducible defects with README rule, observed impact, severity, and proposed priority.
- [ ] Export sanitized runner results; explain failed assertions as product or test defects (or blocked pending investigation).
