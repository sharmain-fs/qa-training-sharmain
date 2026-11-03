# Day 6 — SQL drills on the ParcelPoint database (self-administered, no EM send)

**Database:** `parcelpoint.db` (SQLite) in the `sql/` folder of your training repo. Open it with **DB Browser for SQLite** (free: https://sqlitebrowser.org/dl/) → *Open Database* → *Execute SQL* tab. Read `parcelpoint-schema.sql` first so you know the tables.

**Save:** every query in `sql/day06-drills.sql`, each preceded by a comment with the drill number and the **row count or value** you got, for example:

```sql
-- D6.03  result: 21 rows
SELECT ...
```

**SQL Server note:** the Pluralsight course uses SQL Server (T-SQL). The ideas are the same; a few spellings differ:

| What | SQL Server (course) | SQLite (this database) |
|---|---|---|
| First N rows | `SELECT TOP 10 ...` | `... LIMIT 10` |
| Add hours to a time | `DATEADD(hour, 8, col)` | `datetime(col, '+8 hours')` |
| Date part only | `CAST(col AS date)` | `date(col)` |
| Current time | `GETDATE()` | `datetime('now')` |
| Case-insensitive compare | default collation is usually case-insensitive | `lower(col) = 'delivered'` |

Write each query below in **both** forms when the syntax differs (SQLite to run, SQL Server as a comment). Client projects at Full Scale often use SQL Server.

---

## Basics

1. All shipments for merchant 3, newest first by `created_at_utc`. Show id, status, service, weight.
2. How many shipments are there per status? (GROUP BY.) Do you notice anything odd in the result?
3. Shipments heavier than 25 kg that are SameDay or Express.
4. The 10 most recently delivered shipments (exclude NULL `delivered_at_utc`).
5. Count of shipments per merchant **name** (join `merchants`).

## Joins

6. Every shipment with its number of tracking events (INNER JOIN + GROUP BY).
7. Same as 6, but using LEFT JOIN. Do the counts differ? Why or why not?
8. Every **courier** and how many tracking events they recorded, including couriers with zero (which side of the join must be LEFT?).
9. Shipments with **no** notification row at all (LEFT JOIN … IS NULL). Do not filter by status yet.
10. Now restrict 9 to shipments that **should** have a notification (anything picked up or later). How many?

## Aggregates and HAVING

11. Merchants with more than 100 shipments.
12. Tracking events that appear more than once for the same shipment, status, and time (HAVING COUNT(*) > 1).
13. Average weight per service, rounded to 2 decimals.

## Dates and time zones

14. Shipments delivered on **2026-11-07 UTC** for merchant 2.
15. Shipments delivered on **2026-11-07 Manila time** (UTC+8) for merchant 2. Compare with 14: same count? Same shipments?

---

Stretch (optional): write one query that you think a release sign-off could rely on, and explain in one sentence what result would mean **fail**.
