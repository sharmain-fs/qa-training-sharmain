# Day 3 — A story with no acceptance criteria (self-administered, no EM send)

**PP-520 Batch pickup scheduling**

> "Merchants should be able to schedule a courier pickup for a batch of parcels. Just make it work like the single pickup." — Product Owner (client side), in the ticket. No acceptance criteria.

What you know from the existing single pickup feature:
- A merchant picks a date and a 2-hour pickup slot.
- Slots run 08:00–18:00 merchant local time, Monday to Saturday.
- A pickup can be cancelled up to 1 hour before the slot.

---

## Part 1 — Proposed acceptance criteria (written, not a call)

Write **6 to 10** acceptance criteria in Given / When / Then form that you would propose to the Product Owner. Cover at least: maximum batch size, mixed services in one batch, what happens if one parcel in the batch is invalid, cancel rules for a batch, time zone of the slot, and what the merchant sees after booking.

## Part 2 — Assumptions and questions log

Create a table you would share with the client (not a private note):

| # | Question or assumption | Why it matters (risk if wrong) | Proposed default | Owner | Status |
|---|---|---|---|---|---|

Write at least 6 rows.

## Part 3 — Traceability

List your test cases (titles only are fine) and map each to the acceptance criterion it covers. Mark any acceptance criterion with no test, and any test with no acceptance criterion.

## Part 4 — The message

Write the message you would send to the Product Owner (Slack/Teams/email style, under 150 words) that proposes your acceptance criteria and asks for confirmation by a date. Assume the PO is in the US and you will not get a call.
