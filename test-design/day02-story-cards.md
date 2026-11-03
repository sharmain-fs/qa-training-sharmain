# Day 2 — Story cards for test design practice (self-administered, no EM send)

Design the tests for each story **before** looking at the sandbox. Label every case with the technique that produced it. Save your work as `test-design/day02-<story-id>.md` in your training repo.

---

## PP-501 Parcel weight and service (Decision table + Boundary values + Equivalence partitioning)

- Weight must be from 0.1 kg to 30 kg inclusive.
- Services: Standard, Express, SameDay.
- SameDay only for Cebu City, Mandaue, Lapu-Lapu.
- Express is not offered for parcels over 20 kg.
- Fees: Standard PHP 120, Express PHP 220, SameDay PHP 350. Parcels over 10 kg add PHP 15 per started kg above 10 (10.2 kg adds PHP 15; 11.0 kg adds PHP 15; 11.1 kg adds PHP 30).

Tasks:
1. List the equivalence classes for weight, city, and service.
2. List the boundary values you would test for weight and for the surcharge, with the expected result for each.
3. Build a decision table for city × service × weight band with the expected outcome in each column. Collapse columns that cannot happen or give the same result, and say why.

## PP-502 Shipment status lifecycle (State transition)

```
Created  -> PickedUp | Cancelled
PickedUp -> InTransit
InTransit -> Delivered | Returned
Delivered, Returned, Cancelled are final
```

Tasks:
1. Draw the state diagram (a photo of paper is fine, or text).
2. Write a state-transition table that includes **every invalid** transition, not only the valid ones. How many invalid transitions are there?
3. Pick the 0-switch (every valid transition once) test set, then add the invalid transitions you would test first and explain why.

## PP-503 Delivery notification preferences (Pairwise / combinations)

A recipient can choose:
- Channel: SMS, Email, Push
- Language: English, Cebuano, Filipino
- Quiet hours: Off, 21:00–07:00, 22:00–06:00
- Device: Android, iOS, Web

Tasks:
1. How many combinations are there in total?
2. Produce a pairwise (all-pairs) set by hand or with a free pairwise tool. Show the table and the count.
3. Name two combinations you would add on top of the pairwise set because of **risk**, not coverage, and say why.

---

## Then: 30-minute priority

For **PP-501 only**, if you had 30 minutes before a release, which **5** cases would you run first? For each, one line on why it is risky (money, customer-visible, hard to undo, used often). Read the Ministry of Testing definition of risk-based testing first (link in your day card).
