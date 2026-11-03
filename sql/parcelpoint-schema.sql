-- ParcelPoint training database (SQLite). All *_utc columns are stored in UTC.
CREATE TABLE merchants (id INTEGER PRIMARY KEY, name TEXT NOT NULL, timezone TEXT NOT NULL);
CREATE TABLE couriers  (id INTEGER PRIMARY KEY, name TEXT NOT NULL);
CREATE TABLE shipments (
  id INTEGER PRIMARY KEY,
  merchant_id INTEGER NOT NULL REFERENCES merchants(id),
  recipient_ref TEXT NOT NULL,
  recipient_city TEXT NOT NULL,
  recipient_tz TEXT NOT NULL,              -- IANA time zone of the recipient
  service TEXT NOT NULL,                   -- Standard | Express | SameDay
  weight_kg REAL NOT NULL,
  status TEXT NOT NULL,                    -- Created | PickedUp | InTransit | Delivered | Returned | Cancelled
  created_at_utc TEXT NOT NULL,
  window_start_utc TEXT NOT NULL,          -- start of the promised delivery window
  delivered_at_utc TEXT,                   -- NULL unless delivered
  is_deleted INTEGER NOT NULL DEFAULT 0    -- 1 = soft-deleted
);
CREATE TABLE tracking_events (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  shipment_id INTEGER NOT NULL REFERENCES shipments(id),
  status TEXT NOT NULL,
  event_at_utc TEXT NOT NULL,
  courier_id INTEGER REFERENCES couriers(id)
);
-- Business rule: every shipment that has been picked up gets one SMS reminder
-- scheduled exactly 2 hours before window_start_utc.
CREATE TABLE notifications (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  shipment_id INTEGER NOT NULL REFERENCES shipments(id),
  channel TEXT NOT NULL,
  scheduled_at_utc TEXT NOT NULL,
  sent_at_utc TEXT
);
