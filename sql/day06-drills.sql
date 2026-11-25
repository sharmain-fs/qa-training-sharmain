--D6.01 results: 60 rows
SELECT id, status, service, weight_kg
FROM shipments
WHERE merchant_id = 3
ORDER BY created_at_utc DESC;

-- same in SQL Server

--D6.02 results: 7 rows
SELECT status, COUNT(*) AS shipment_count
FROM shipments
GROUP BY status
ORDER BY shipment_count ASC;

-- same in SQL Server

--Do you notice anything odd in the result?
/*
Yes, there is an inconsistency in the capitalization of the
shipment status. The query results show that 3 shipments have
the lowercase status 'delivered', which appears as a separate
group from the expected status 'Delivered'.

Evidence: SELECT status, COUNT(*) FROM shipments GROUP BY status;
returns 'delivered' with a count of 3 shipments.

Impact: Any query that uses the case-sensitive filter
status = 'Delivered' silently excludes these 3 shipments,
resulting in inaccurate shipment counts and potentially
incorrect delivery reports.
*/

--D6.03 results: 21 rows
SELECT *
FROM shipments
WHERE weight_kg > 25
AND service IN ('SameDay', 'Express');

-- same in SQL Server

--D6.04 results: 10 rows
-- Use LOWER() to include both 'Delivered' and 'delivered'
-- because SQLite uses case-sensitive comparisons by default.

SELECT *
FROM shipments
WHERE LOWER(status) = 'delivered'
AND delivered_at_utc IS NOT NULL
ORDER BY delivered_at_utc DESC
LIMIT 10;

/*
SQL Server:
SELECT TOP 10 *
FROM shipments
WHERE LOWER(status) = 'delivered'
    AND delivered_at_utc IS NOT NULL
ORDER BY delivered_at_utc DESC;
*/

-- D6.05 result: 110 / 150 / 60
SELECT m.name AS merchant_name,
       COUNT(s.merchant_id) AS shipment_count
FROM shipments AS s
INNER JOIN merchants AS m
    ON s.merchant_id = m.id
GROUP BY m.id, m.name
ORDER BY m.id;

-- same in SQL Server

--D6.06 results: 320 rows
SELECT s.id AS shipment_id,
       COUNT(t.id) AS event_count
FROM shipments s
INNER JOIN tracking_events t
    ON s.id = t.shipment_id
GROUP BY s.id;

-- same in SQL Server

-- D6.07 results: 320 rows
SELECT s.id AS shipment_id,
       COUNT(t.id) AS event_count
FROM shipments s
LEFT JOIN tracking_events t
    ON s.id = t.shipment_id
GROUP BY s.id;

-- same in SQL Server

-- Verification: Count shipments without tracking events.
-- Expected result: 0
SELECT COUNT(*) AS shipments_without_tracking_events
FROM shipments s
LEFT JOIN tracking_events t
    ON s.id = t.shipment_id
WHERE t.id IS NULL;

-- same in SQL Server

-- Do the counts differ? Why or why not?
/*
No. Both the INNER JOIN (D6.06) and LEFT JOIN (D6.07)
return 320 rows.

The verification query returns 0 shipments without
tracking events, confirming that every shipment has
at least one tracking event in the current dataset.

Therefore, both joins return the same number of rows.

If a shipment has no tracking events, the INNER JOIN
will exclude it, while the LEFT JOIN will retain it
with an event_count of 0.
*/

--D6.08 results: 4 rows
SELECT c.id AS courier_id,
       c.name AS courier_name,
       COUNT(t.id) AS event_count
FROM couriers c
LEFT JOIN tracking_events t
    ON c.id = t.courier_id
GROUP BY c.id, c.name;

-- same in SQL Server

-- Which side must be LEFT?
/* The couriers table must be on the LEFT side of the join 
because we want to include all couriers in the result, even if they have no tracking events.*/

--D6.09 results: 52 rows
SELECT s.id, s.status
FROM shipments s
LEFT JOIN notifications n
    ON s.id = n.shipment_id
WHERE n.id IS NULL
ORDER BY s.id;

-- same in SQL Server

--D6.10 results: 5 rows
-- Use LOWER() to prevent inconsistent status capitalization
-- from excluding shipments. SQLite uses case-sensitive
-- comparisons by default, while SQL Server commonly uses
-- a case-insensitive default collation.

SELECT s.id, s.status, s.service
FROM shipments s
LEFT JOIN notifications n
    ON s.id = n.shipment_id
WHERE n.id IS NULL
  AND LOWER(s.status) IN (
      'pickedup',
      'intransit',
      'delivered',
      'returned')
ORDER BY s.id;

-- same in SQL Server

-- How many shipments are missing notifications for the statuses listed above?
/*
There are 5 shipments missing notifications.
All 5 shipments have the status 'Delivered'.

Affected shipment IDs: [Insert the 5 shipment IDs here].

This finding is relevant to Day 7 data validation because
delivered shipments are missing their expected notifications.

Using LOWER() ensures that inconsistent status capitalization
does not silently exclude shipments from the validation results.
*/

--D6.11 results: 2 rows
SELECT m.id,
       m.name AS merchant_name,
       COUNT(s.id) AS shipment_count
FROM merchants m
JOIN shipments s
    ON m.id = s.merchant_id
GROUP BY m.id, m.name
HAVING COUNT(s.id) > 100;

-- same in SQL Server

--D6.12 results: 4 rows
SELECT shipment_id,
       status,
       event_at_utc,
       COUNT(*) AS duplicate_count
FROM tracking_events
GROUP BY shipment_id, status, event_at_utc
HAVING COUNT(*) > 1;

-- same in SQL Server

--D6.13 results: 3 rows
SELECT service,
       ROUND(AVG(weight_kg), 2) AS average_weight_kg
FROM shipments
GROUP BY service
ORDER BY service;

-- same in SQL Server

--D6.14 results: 16 rows
SELECT id, merchant_id, status, delivered_at_utc
FROM shipments
WHERE merchant_id = 2
  AND delivered_at_utc >= '2026-11-07 00:00:00'
  AND delivered_at_utc <  '2026-11-08 00:00:00'
ORDER BY delivered_at_utc;

-- same in SQL Server

--D6.15 results: 17 rows
SELECT id, merchant_id, status, delivered_at_utc,
       datetime(delivered_at_utc, '+8 hours') AS delivered_at_manila
FROM shipments
WHERE merchant_id = 2
  AND datetime(delivered_at_utc, '+8 hours')
      >= '2026-11-07 00:00:00'
  AND datetime(delivered_at_utc, '+8 hours')
      < '2026-11-08 00:00:00'
ORDER BY delivered_at_utc;

/*
SELECT id, merchant_id, status, delivered_at_utc,
       DATEADD(HOUR, 8, CAST(delivered_at_utc AS datetime2))
           AS delivered_at_manila
FROM shipments
WHERE merchant_id = 2
  AND DATEADD(HOUR, 8, CAST(delivered_at_utc AS datetime2))
      >= '2026-11-07 00:00:00'
  AND DATEADD(HOUR, 8, CAST(delivered_at_utc AS datetime2))
      < '2026-11-08 00:00:00'
ORDER BY delivered_at_utc;
*/

-- Will the counts and shipments be the same?
/*
No. The UTC query returns 16 shipments, while the Manila
local time query returns 17 shipments.

Using EXCEPT to compare the two result sets shows that
7 shipments differ between the two time windows:

- 13 shipments appear in both result sets.
- 3 shipments are included in UTC but excluded in Manila.
  Shipment IDs: [Insert 3 shipment IDs].
- 4 shipments are included in Manila but excluded in UTC.
  Shipment IDs: [Insert 4 shipment IDs].

The difference occurs because the Manila day boundary
is offset by eight hours from UTC. Therefore, the same
"delivered on November 7" question produces different
shipment lists depending on the time zone used.

For a Manila merchant, I would use the Manila local
day boundary (UTC+8) because delivery reports should
reflect the merchant's local calendar date.

Neither query explicitly filters by shipment status
or excludes soft-deleted records using is_deleted.
Both queries only filter by merchant_id and the
delivered_at_utc time range.

Therefore, these results demonstrate the impact of
time zone boundaries but do not necessarily represent
the final business-valid delivered shipment count.
*/