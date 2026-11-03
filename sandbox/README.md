# ParcelPoint Merchant API — training sandbox

A small API you test against on Days 1, 4, 5, and 9. It is a training target: **it has deliberate defects.** Finding them with your tests is the point.

Test it as a black box, the way you would test a client's API: use only this README as the spec. Don't read `server.js` to find the defects.

## Run it

1. Install **Node.js LTS** (https://nodejs.org) if `node --version` does not print a version. You need Node for Playwright on Day 9 anyway.
2. In a terminal, go to the `sandbox/` folder of your training repo and run:

   ```
   node server.js
   ```

3. Leave that terminal open. The API listens on **http://localhost:4010**. Every request is logged in that terminal with its status code and response time.
4. Check it in Postman: `GET http://localhost:4010/health` should return `{"ok":true,"version":"3.4.0"}`.

Data lives in memory. **Restart the server to reset all data** (Ctrl+C, then `node server.js` again). Restart before each recorded assessment.

No install step and no internet needed. If port 4010 is taken, run `PORT=4020 node server.js` (macOS/Linux) or `set PORT=4020 && node server.js` (Windows Command Prompt).

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
| GET | /health | No token needed |
| POST | /auth/login | Body `{"username","password"}` → `{"token","role","merchantId"}` |
| GET | /shipments | Shipments you are allowed to see. Optional `?status=Delivered` |
| POST | /shipments | Create. Body `{"recipientName","city","weightKg","service"}` |
| GET | /shipments/{id} | One shipment |
| GET | /shipments/{id}/events | Tracking history |
| PATCH | /shipments/{id}/status | Body `{"status": "PickedUp"}` |

Send the token as the header `Authorization: Bearer <token>`.

## Business rules (the spec your tests check against)

- **Authentication:** no token → 401. Invalid or expired token → 401.
- **Who can see what:** merchant users see only their own merchant's shipments. Support can read all shipments but **must not change anything**. A courier sees and updates only shipments assigned to them. A shipment you are not allowed to see behaves as if it does not exist (404).
- **Create (POST /shipments):** merchant users only (others 403). `recipientName` and `city` required (400). `weightKg` from **0.1 to 30 kg inclusive** (400 otherwise). `service` is `Standard` (PHP 120), `Express` (PHP 220) or `SameDay` (PHP 350), anything else 400. SameDay only for Cebu City, Mandaue, Lapu-Lapu (422 otherwise). Success is 201 with `status: "Created"`.
- **Status lifecycle (PATCH /shipments/{id}/status):**

  ```
  Created  -> PickedUp | Cancelled
  PickedUp -> InTransit
  InTransit -> Delivered | Returned
  Delivered, Returned, Cancelled are final (no further changes)
  ```

  A disallowed move returns **409**. An unknown status value returns **400**. Couriers may set PickedUp, InTransit, Delivered, Returned, but **not** Cancelled (403). Merchant users may only change their own merchant's shipments. Support may not change status (403).
