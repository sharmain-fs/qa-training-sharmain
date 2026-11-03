# Day 7 — Data validation and time zones (self-administered, no EM send)

Same database as Day 6 (`sql/parcelpoint.db`). Save queries in `sql/day07-validation.sql` and your write-up in `sql/day07-findings.md`.

---

## Part 1 — Sign-off checks that can actually fail (about 90 minutes)

The release team wants SQL checks for the "delivery-day SMS" rule:

> Every shipment that has been picked up (PickedUp, InTransit, Delivered, Returned) gets **exactly one** SMS notification, scheduled **exactly 2 hours before** `window_start_utc`.

A teammate proposed this check:

```sql
SELECT s.id, s.window_start_utc, n.scheduled_at_utc
FROM shipments s
JOIN notifications n ON n.shipment_id = s.id
WHERE n.scheduled_at_utc = datetime(s.window_start_utc, '-2 hours');
-- "Rows returned -> PASS"
```

1. Run it. How many rows? Explain in your own words why this query **cannot fail**, whatever the data looks like.
2. Write **three** replacement checks. Each must **pass when it returns 0 rows** and fail otherwise:
   - a. shipments that should have an SMS but have none;
   - b. SMS rows scheduled at the wrong time;
   - c. shipments with more than one SMS.
3. Run them and record the shipment IDs each one returns.
4. Look at the shipments returned by check (b). What do they have in common? Write a one-paragraph hypothesis for the defect (hint: look at `recipient_tz` and the size of the error in hours).
5. Write a fourth check of your own for the `tracking_events` table and say what it protects against.

## Part 2 — "Your dashboard is wrong" (about 75 minutes)

Bayside Bakery (merchant 2, Manila) emails support:

> "Your dashboard tile 'Delivered on Sat 7 Nov' shows **12**. Our own order system says **17** of our parcels were delivered that day. Which is right?"

The dashboard tile runs this query:

```sql
SELECT COUNT(*) FROM shipments
WHERE merchant_id = 2 AND status = 'Delivered' AND is_deleted = 0
  AND date(delivered_at_utc) = '2026-11-07';
```

1. List at least **four hypotheses** that could explain a difference (time zone, status values, deleted rows, duplicates, and so on).
2. Test each hypothesis with a query. Keep the queries.
3. Decide the correct number, and explain both the dashboard's number and the merchant's number.
4. Check whether the dashboard and the correct query count the **same shipments**, not just the same total. What did you find?
5. Write the reply to the merchant (under 120 words, plain English, no SQL) and a separate bug report for the dashboard query (title, severity, priority, steps, expected, actual, evidence).
