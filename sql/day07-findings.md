# Day 7 — Data validation and time zones: Verified findings

## PART 1 - Sign-off checks that can actually fail (about 90 minutes)

### 1. Proposed sign-off query

**Observed: 263 rows.** This query is not a reliable validation check because it only returns SMS notifications that already satisfy the business rule.

There are two reasons why the query cannot reliably detect failures:

1. **WHERE clause:** The condition only includes SMS notifications scheduled exactly 2 hours before the delivery window. Incorrectly scheduled notifications are excluded instead of being identified as failures.
2. **INNER JOIN:** The query only includes shipments with matching SMS notifications. Shipments with missing SMS notifications are excluded entirely, so missing notifications are never detected.

As a result, **"Rows returned = PASS" is true for any dataset containing at least one correctly scheduled SMS**, even if other shipments have missing, incorrectly scheduled, or duplicate notifications.

Therefore, the observed 263 rows only confirm that 263 matching records satisfy the scheduling condition. They do not prove that all eligible shipments have exactly one correctly scheduled SMS notification. Therefore, the query cannot reliably determine whether the business rule has passed or failed.

### 2–3. Replacement checks (zero returned rows = PASS)

| Check | Observed rows | Shipment IDs | Verdict |
|---|---:|---|---|
| (a) Eligible shipments with no SMS | 5 | 8, 21, 36, 49, 68 | FAIL |
| (b) Eligible shipments with SMS at wrong UTC time | 5 | 261, 262, 264, 265, 266 | FAIL |
| (c) Eligible shipments with more than one SMS | 0 | None | PASS |

### 4. Wrong-time evidence and defect hypothesis

| Shipment ID | Recipient timezone | Notification ID | Signed error (hours) |
|---:|---|---:|---:|
| 261 | America/Chicago | 217 | +14 |
| 262 | America/Chicago | 218 | +14 |
| 264 | America/Chicago | 220 | +14 |
| 265 | America/Chicago | 221 | +14 |
| 266 | America/Chicago | 222 | +14 |

**Hypothesis:** The SMS scheduler may be incorrectly applying the Manila time-zone offset (UTC+8) instead of the recipient's `America/Chicago` time zone (UTC-6 in November), resulting in notifications being scheduled 14 hours later than expected.

**Time-Zone Calculation:**
- Manila: UTC+8
- Chicago (November): UTC-6
- Offset difference: +8 - (-6) = **14 hours**

The consistent +14-hour scheduling error across all five affected shipments suggests a systematic time-zone conversion issue rather than a random delay. However, the scheduler code must be inspected to confirm the cause and direction of the incorrect offset.

**Additional Verification:**
- **America/Chicago:** 5 of 52 eligible shipments have incorrectly scheduled SMS notifications; 47 are correct.
- **Asia/Manila:** 0 of 218 eligible shipments have scheduling errors; all 218 are correct.
- Compare the five affected Chicago shipments to identify shared characteristics, such as service type, shipment status, and delivery window time.
- Inspect the scheduler code and intermediate timestamps to confirm whether the Manila offset is incorrectly applied instead of `recipient_tz`.

### 5. Additional tracking-events check

**Check:** `tracking_events` rows whose `shipment_id` has no matching `shipments.id` (LEFT JOIN / IS NULL). **Observed: 0 rows — PASS.** This protects tracking-history referential integrity, including cases where SQLite foreign-key enforcement was disabled during imports. No orphan tracking-event IDs were found.

## Part 2 — Bayside Bakery dashboard discrepancy

### 1–2. Tested hypotheses

Manila's **Saturday, 2026-11-07** runs from **2026-11-06 16:00:00 UTC (inclusive)** to **2026-11-07 16:00:00 UTC (exclusive)**. The supplied dashboard instead uses the UTC date 2026-11-07.

| Hypothesis | SQL test in validation file | Observed finding |
|---|---|---|
| H1. UTC day used instead of Manila day | Original count, corrected UTC-range count, and membership comparison | Both counts **12**, but only **9** IDs overlap; **3 IDs unique to each** |
| H2. Status capitalization differs | Group local-day deliveries by `status` | **14 `Delivered`**, **3 `delivered`** |
| H3. Soft-deleted deliveries are excluded | Local-day query with `is_deleted = 1` | **2** rows: IDs **150, 151** |
| H4. Duplicate shipment references inflate the count | Group active Delivered local-day rows by `recipient_ref` | **0** repeated refs in this group; the extended 17-row check also returns **0** |
| H5. Delivered shipments have NULL delivery timestamps | `Delivered` plus NULL timestamp for merchant 2 | **0** rows |
| H6. Differences can be decomposed by status and deletion flag | Group all local-day timestamped rows by status and `is_deleted` | **12 active `Delivered` + 3 active `delivered` + 2 deleted `Delivered` = 17** |

### 3. Which number is correct?

The correct dashboard count is 15 delivered shipments, using the Manila calendar day, case-insensitive status matching, and excluding soft-deleted records. The count of 12 results from UTC and exact-case filtering, while 17 incorrectly includes two soft-deleted shipments.

**PO Follow-up:** Confirm whether legacy lowercase `delivered` status values should be normalized to `Delivered` in the database to maintain data consistency and prevent future reporting discrepancies.

### 4. Same shipments or just the same total?

**Not the same shipments.** The old and timezone-corrected queries each return **12**, but share only **9 IDs**.

- **Dashboard-only:** 174, 179, 250 (UTC Nov 7, but Manila Nov 8).
- **Corrected-only:** 201, 203, 256 (UTC Nov 6, but Manila Nov 7).
- **Shared IDs:** 157, 169, 177, 190, 192, 198, 199, 208, 214.

This proves a genuine date-boundary bug even though the two totals happen to be equal.

### 5a. Reply to Bayside Bakery (under 120 words, plain English)

> Hello Bayside Bakery team,
>
> Thank you for reporting the discrepancy. After reviewing the shipment records, we confirmed that the correct delivery count for November 7 (Manila time) is 15 shipments.

The dashboard displayed 12 because it used an incorrect date boundary, including three shipments from the wrong day while excluding three from the correct day. It also missed three valid deliveries. Your reported count of 17 includes two records that have since been removed.

We are targeting Monday, November 23, 2026, to correct the dashboard's date handling and delivery count. We will confirm this timeline with our development team and notify you once the fix has been deployed and verified.
>
> Thank you for bringing this to our attention.

### 5b. Bug report — Delivered-on-date dashboard

**Title:** Bayside Bakery delivered-day tile uses UTC date and misrepresents merchant-local shipment membership

**Severity:** Medium — inaccurate customer-facing delivery metrics and shipment membership.

**Proposed Priority:** High (merchant-visible data); to confirm with PO.

**Preconditions:** Merchant 2 (`Bayside Bakery`) timezone is `Asia/Manila`; test date 2026-11-07; populated `parcelpoint(1).db`.

**Steps to reproduce:**
1. Run the supplied dashboard query for merchant 2 on 2026-11-07.
2. Run the corrected Manila-day UTC-range query, retaining `status = 'Delivered'` and `is_deleted = 0`.
3. Compare shipment IDs using the two-way membership query.
4. Run the status/deletion breakdown query to investigate the merchant's 17.

**Expected:** The delivered-day tile selects shipments delivered during the **merchant-local day**. Its treatment of lowercase statuses and soft-deleted rows must match the approved reporting definition.

**Actual:** Original UTC-day query returns **12**; corrected Manila-day query also returns **12**, but the sets differ by **3 IDs on each side**. Merchant-local timestamped deliveries total **17**: 12 active `Delivered`, 3 active `delivered`, 2 deleted `Delivered`. If deletion exclusion is intended, a case-insensitive active count is **15**.

**Evidence:** Dashboard-only IDs **174, 179, 250**; Manila-only IDs **201, 203, 256**; 9 common IDs. Lowercase-status IDs **119, 123, 124**. Soft-deleted IDs **150, 151**. Merchant 2 timezone `Asia/Manila` verified in `merchants`.

**Status:** Reproduced. UTC date-boundary defect confirmed; whether lowercase statuses and deleted rows must be included remains a reporting-policy decision.
