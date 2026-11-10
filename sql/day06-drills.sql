--D6.01 results: 60 rows
SELECT id, status, service, weight_kg
FROM shipments
WHERE merchant_id = 3
ORDER BY created_at_utc DESC

/*
SELECT id, status, service, weight_kg
FROM shipments
WHERE merchant_id = 3
ORDER BY created_at_utc DESC 
*/

--D6.02 results: 7 rows
SELECT status, COUNT(*) AS shipment_count
FROM shipments
GROUP BY status
ORDER BY shipment_count ASC

/*
SELECT status, COUNT(*) AS shipment_count
FROM shipments
GROUP BY status
ORDER BY shipment_count ASC
*/

--Do you notice anything odd in the result?
/*Yes, unexpected status names, capitalization differences, or shipments marked Delivered without a delivery timestamp. 
The schema lists six expected statuses but doesn't enforce them with a CHECK constraint.*/

--D6.04 results: 21 rows
SELECT *
FROM shipments
WHERE weight_kg > 25
AND service IN ('SameDay', 'Express');

/*
SELECT *
FROM shipments
WHERE weight_kg > 25
AND (service = 'SameDay' OR service = 'Express');
*/

--D6.04 results: 10 rows
SELECT *
FROM shipments
WHERE status = 'Delivered'
AND delivered_at_utc IS NOT NULL
ORDER BY delivered_at_utc DESC
LIMIT 10

/*
SELECT TOP 10 *
FROM shipments
WHERE status = 'Delivered'
    AND delivered_at_utc IS NOT NULL
ORDER BY delivered_at_utc DESC;
*/

--D6.05 results: 3 rows
SELECT o.name AS merchant_name,
	COUNT(c.merchant_id) AS shipment_count 
FROM shipments AS c
INNER JOIN merchants AS o
	ON c.merchant_id = o.id
GROUP BY name

/*
SELECT o.name AS merchant_name,
	COUNT(c.merchant_id) AS shipment_count 
FROM shipments AS c
INNER JOIN merchants AS o
	ON c.merchant_id = o.id
GROUP BY name
*/

--D6.06 results: 320 rows
SELECT s.id AS shipment_id,
       COUNT(t.id) AS event_count
FROM shipments s
INNER JOIN tracking_events t
    ON s.id = t.shipment_id
GROUP BY s.id

/*
SELECT s.id AS shipment_id,
       COUNT(t.id) AS event_count
FROM shipments s
INNER JOIN tracking_events t
    ON s.id = t.shipment_id
GROUP BY s.id
*/

--D6.07 results: 320 rows
SELECT s.id AS shipment_id,
       COUNT(t.id) AS event_count
FROM shipments s
LEFT JOIN tracking_events t
    ON s.id = t.shipment_id
GROUP BY s.id

/*
SELECT s.id AS shipment_id,
       COUNT(t.id) AS event_count
FROM shipments s
LEFT JOIN tracking_events t
    ON s.id = t.shipment_id
GROUP BY s.id
*/

-- Do the counts differ? Why or why not?
/* No, because every shipment has at least one tracking event, 
so the INNER JOIN and LEFT JOIN will produce the same result. */

--D6.08 results: 4 rows
SELECT c.id AS courier_id,
       c.name AS courier_name,
       COUNT(t.id) AS event_count
FROM couriers c
LEFT JOIN tracking_events t
    ON c.id = t.courier_id
GROUP BY c.id, c.name

/*
SELECT c.id AS courier_id,
       c.name AS courier_name,
       COUNT(t.id) AS event_count
FROM couriers c
LEFT JOIN tracking_events t
    ON c.id = t.courier_id
GROUP BY c.id, c.name
*/

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

/*
SELECT s.id, s.status
FROM shipments s
LEFT JOIN notifications n
    ON s.id = n.shipment_id
WHERE n.id IS NULL
ORDER BY s.id;
*/

--D6.10 results: 5 rows
SELECT s.id, s.status, s.service
FROM shipments s
LEFT JOIN notifications n
    ON s.id = n.shipment_id
WHERE n.id IS NULL
  AND s.status IN (
      'PickedUp',
      'InTransit',
      'Delivered',
      'Returned')
ORDER BY s.id;

/*
SELECT s.id, s.status, s.service
FROM shipments s
LEFT JOIN notifications n
    ON s.id = n.shipment_id
WHERE n.id IS NULL
  AND s.status IN (
      'PickedUp',
      'InTransit',
      'Delivered',
      'Returned')
ORDER BY s.id;
*/

-- How many shipments are missing notifications for the statuses listed above?
/* There are 5 shipments missing notifications*/

--D6.11 results: 2 rows
SELECT m.id,
       m.name AS merchant_name,
       COUNT(s.id) AS shipment_count
FROM merchants m
JOIN shipments s
    ON m.id = s.merchant_id
GROUP BY m.id, m.name
HAVING COUNT(s.id) > 100

/*
SELECT m.id,
       m.name AS merchant_name,
       COUNT(s.id) AS shipment_count
FROM merchants m
JOIN shipments s
    ON m.id = s.merchant_id
GROUP BY m.id, m.name
HAVING COUNT(s.id) > 100
*/

--D6.12 results: 4 rows
SELECT shipment_id,
       status,
       event_at_utc,
       COUNT(*) AS duplicate_count
FROM tracking_events
GROUP BY shipment_id, status, event_at_utc
HAVING COUNT(*) > 1;

/*
SELECT shipment_id,
       status,
       event_at_utc,
       COUNT(*) AS duplicate_count
FROM tracking_events
GROUP BY shipment_id, status, event_at_utc
HAVING COUNT(*) > 1;
*/

--D6.13 results: 3 rows
SELECT service,
       ROUND(AVG(weight_kg), 2) AS average_weight_kg
FROM shipments
GROUP BY service
ORDER BY service;

/*
SELECT service,
       ROUND(AVG(weight_kg), 2) AS average_weight_kg
FROM shipments
GROUP BY service
ORDER BY service;
*/

--D6.14 results: 16 rows
SELECT id, merchant_id, status, delivered_at_utc
FROM shipments
WHERE merchant_id = 2
  AND delivered_at_utc >= '2026-11-07 00:00:00'
  AND delivered_at_utc <  '2026-11-08 00:00:00'
ORDER BY delivered_at_utc;

/*
SELECT id, merchant_id, status, delivered_at_utc
FROM shipments
WHERE merchant_id = 2
  AND delivered_at_utc >= '2026-11-07 00:00:00'
  AND delivered_at_utc <  '2026-11-08 00:00:00'
ORDER BY delivered_at_utc;
*/

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
SQL Server:
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
/*Not necessarily. Even if the counts happen to match, the shipment IDs may differ because the two time windows are offset by eight hours.*/

