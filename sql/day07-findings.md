# Day 7 — Data validation and time zones: Verified findings

## PART 1 - Sign-off checks that can actually fail (about 90 minutes)

### 1. Proposed sign-off query

**Observed: 263 rows.** This query is not a reliable validation check because it only returns notifications scheduled exactly 2 hours before the delivery window. It does not identify shipments with missing SMS notifications, incorrectly scheduled SMS notifications, or duplicate SMS notifications.Therefore, even if the query returns matching rows or zero rows, it cannot reliably determine whether the business rule has passed or failed.

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

**Hypothesis:** All five wrongly scheduled SMS notifications target recipients in `America/Chicago` and are **14 hours later** than the required UTC time (`window_start_utc` minus two hours). This strongly suggests that the scheduling path for this recipient timezone is mishandling local-to-UTC conversion or mixing time-zone offsets when saving `scheduled_at_utc`. The consistent 14-hour error indicates a systematic calculation problem rather than random delay. However, Chicago's UTC offset alone is not 14 hours, so the evidence does **not** prove that a single Chicago offset was mistakenly applied; the code and intermediate timestamps need inspection to establish the precise cause.

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

**Both 12 and 17 are reproducible, but they describe different populations.** The dashboard's original SQL returns **12** active, exactly-capitalized `Delivered` rows in the **UTC** calendar day. Correcting *only the timezone* to Manila also returns **12** active, exactly-capitalized `Delivered` rows, although not the same 12 shipments. Counting **all 17 rows with delivery timestamps during the Manila calendar day**, regardless of status capitalization or soft-deletion, reproduces the merchant's **17**. A case-insensitive count **excluding deleted shipments** is **15**.

**Decision:** The database verifies **17 timestamped local-day delivery records**, but cannot by itself establish whether the dashboard should count soft-deleted rows. Under the dashboard's currently expressed business filters (`status = 'Delivered'`, `is_deleted = 0`), the corrected Manila-day count is **12**. If the metric is intended to include all delivered parcels, including soft-deleted historical records and lowercase `delivered`, the count is **17**. The Product Owner should confirm the deletion policy and status-normalization rule before approving a definitive dashboard metric.

### 4. Same shipments or just the same total?

**Not the same shipments.** The old and timezone-corrected queries each return **12**, but share only **9 IDs**.

- **Dashboard-only:** 174, 179, 250 (UTC Nov 7, but Manila Nov 8).
- **Corrected-only:** 201, 203, 256 (UTC Nov 6, but Manila Nov 7).
- **Shared IDs:** 157, 169, 177, 190, 192, 198, 199, 208, 214.

This proves a genuine date-boundary bug even though the two totals happen to be equal.

### 5a. Reply to Bayside Bakery (under 120 words, plain English)

> Hello Bayside Bakery team,
>
> Thank you for reporting the difference. We checked the shipment records and confirmed 17 deliveries recorded on 7 November in Manila time. The dashboard shows 12 because its date filter uses a different time zone, and its rules also exclude three records with differently capitalized statuses and two deleted records. We also found that the date issue can show the wrong shipments even when the total remains 12. We're confirming whether deleted shipments should be included in this tile before updating the figure. We'll correct the date handling and review the counting rules.
>
> Thank you for bringing this to our attention.

### 5b. Bug report — Delivered-on-date dashboard

**Title:** Bayside Bakery delivered-day tile uses UTC date and misrepresents merchant-local shipment membership

**Severity:** Medium — inaccurate customer-facing delivery metrics and shipment membership.

**Priority:** High — customer-reported and reproducible; fix before reporting sign-off.

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
