-- Day 7 - Data validation and time zones

-- PART 1 - Sign-off checks that can actually fail (about 90 minutes)

-- PART 1.2a: shipments that should have an SMS but have none
SELECT s.id AS shipment_id, s.status, s.recipient_tz
FROM shipments s
WHERE s.status IN ('PickedUp', 'InTransit', 'Delivered', 'Returned')
  AND NOT EXISTS (
    SELECT 1 FROM notifications n
    WHERE n.shipment_id = s.id AND n.channel = 'SMS')
ORDER BY s.id;

-- PART 1.2b: SMS rows scheduled at the wrong time
SELECT s.id AS shipment_id, s.recipient_tz, s.window_start_utc,
       n.id AS notification_id, n.scheduled_at_utc,
       ROUND((julianday(n.scheduled_at_utc) -
              julianday(s.window_start_utc, '-2 hours')) * 24, 2)
         AS error_hours
FROM shipments s
JOIN notifications n ON n.shipment_id = s.id AND n.channel = 'SMS'
WHERE s.status IN ('PickedUp', 'InTransit', 'Delivered', 'Returned')
  AND (julianday(n.scheduled_at_utc) IS NULL
       OR julianday(s.window_start_utc) IS NULL
       OR ABS(julianday(n.scheduled_at_utc) -
              julianday(s.window_start_utc, '-2 hours')) > 0.00000001)
ORDER BY s.id, n.id;

-- PART 1.2c: shipments with more than one SMS.
SELECT s.id AS shipment_id, COUNT(n.id) AS sms_count
FROM shipments s
JOIN notifications n ON n.shipment_id = s.id AND n.channel = 'SMS'
WHERE s.status IN ('PickedUp', 'InTransit', 'Delivered', 'Returned')
GROUP BY s.id
HAVING COUNT(n.id) > 1
ORDER BY s.id;

-- PART 1.5: Extra check: tracking events referencing missing shipments.
-- Protects tracking history integrity, even if SQLite foreign keys were disabled.
SELECT t.id AS tracking_event_id, t.shipment_id
FROM tracking_events t
LEFT JOIN shipments s ON s.id = t.shipment_id
WHERE s.id IS NULL
ORDER BY t.id;

-- PART 2: "Your dashboard is wrong" (about 75 minutes)
-- The dashboard tile runs this query:
SELECT COUNT(*) FROM shipments
WHERE merchant_id = 2 AND status = 'Delivered' AND is_deleted = 0
  AND date(delivered_at_utc) = '2026-11-07';

--HYPOTHESES: 
-- H1: Time zone boundary: Manila local Nov 7 vs UTC Nov 7.
-- The merchant is based in Manila; its local day is UTC+8, no DST.
SELECT id, status, is_deleted, delivered_at_utc,
       datetime(delivered_at_utc, '+8 hours') AS delivered_manila,
       date(delivered_at_utc) AS utc_date,
       date(delivered_at_utc, '+8 hours') AS manila_date
FROM shipments
WHERE merchant_id = 2 AND delivered_at_utc >= '2026-11-06 00:00:00'
  AND delivered_at_utc < '2026-11-09 00:00:00'
ORDER BY delivered_at_utc, id;

-- H2: Status values differ from delivery timestamps.
SELECT status, COUNT(*) AS shipment_count
FROM shipments
WHERE merchant_id = 2
  AND delivered_at_utc >= '2026-11-06 16:00:00'
  AND delivered_at_utc < '2026-11-07 16:00:00'
GROUP BY status ORDER BY status;

-- H3: Soft-deleted delivered shipments excluded by dashboard.
SELECT id, status, delivered_at_utc, is_deleted
FROM shipments
WHERE merchant_id = 2 AND is_deleted = 1
  AND delivered_at_utc >= '2026-11-06 16:00:00'
  AND delivered_at_utc < '2026-11-07 16:00:00'
ORDER BY id;

-- H4: Duplicated shipment references might inflate an external order count.
SELECT recipient_ref, COUNT(*) AS shipment_count,
       GROUP_CONCAT(id) AS shipment_ids
FROM shipments
WHERE merchant_id = 2 AND status = 'Delivered' AND is_deleted = 0
  AND delivered_at_utc >= '2026-11-06 16:00:00'
  AND delivered_at_utc < '2026-11-07 16:00:00'
GROUP BY recipient_ref HAVING COUNT(*) > 1
ORDER BY recipient_ref;
-- recipient_ref uniqueness is NOT guaranteed by schema; duplicates are
-- investigative evidence, not automatically duplicate shipments.

-- H5: Delivered status but NULL timestamp (excluded by both date filters).
SELECT id, recipient_ref, status, delivered_at_utc
FROM shipments
WHERE merchant_id = 2 AND status = 'Delivered'
  AND delivered_at_utc IS NULL ORDER BY id;

-- Corrected dashboard count if business definition is active, Delivered,
-- and delivered on Manila calendar day Nov 7, based on delivered_at_utc.
SELECT COUNT(*) AS manila_delivered_count
FROM shipments
WHERE merchant_id = 2 AND status = 'Delivered' AND is_deleted = 0
  AND delivered_at_utc >= '2026-11-06 16:00:00'
  AND delivered_at_utc < '2026-11-07 16:00:00';

-- PART 2.4: Shipment-level membership differences between old and corrected queries.
-- Rows returned indicate a different shipment set, even if totals match.
WITH old_ids AS (
  SELECT id FROM shipments
  WHERE merchant_id = 2 AND status = 'Delivered' AND is_deleted = 0
    AND date(delivered_at_utc) = '2026-11-07'
), corrected_ids AS (
  SELECT id FROM shipments
  WHERE merchant_id = 2 AND status = 'Delivered' AND is_deleted = 0
    AND delivered_at_utc >= '2026-11-06 16:00:00'
    AND delivered_at_utc < '2026-11-07 16:00:00'
)
SELECT 'dashboard_only' AS membership, id AS shipment_id
FROM old_ids WHERE id NOT IN (SELECT id FROM corrected_ids)
UNION ALL
SELECT 'corrected_only' AS membership, id AS shipment_id
FROM corrected_ids WHERE id NOT IN (SELECT id FROM old_ids)
ORDER BY membership, shipment_id;

-- Extra: summarize count and overlap for dashboard vs corrected membership.
WITH old_ids AS (
  SELECT id FROM shipments WHERE merchant_id = 2 AND status = 'Delivered'
    AND is_deleted = 0 AND date(delivered_at_utc) = '2026-11-07'
), corrected_ids AS (
  SELECT id FROM shipments WHERE merchant_id = 2 AND status = 'Delivered'
    AND is_deleted = 0 AND delivered_at_utc >= '2026-11-06 16:00:00'
    AND delivered_at_utc < '2026-11-07 16:00:00'
)
SELECT (SELECT COUNT(*) FROM old_ids) AS dashboard_count,
       (SELECT COUNT(*) FROM corrected_ids) AS corrected_count,
       (SELECT COUNT(*) FROM old_ids WHERE id IN (SELECT id FROM corrected_ids)) AS shared_ids;
