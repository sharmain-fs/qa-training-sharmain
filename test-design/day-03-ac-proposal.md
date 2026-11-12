# PP-520 — Batch Pickup Scheduling

## User Story

> Merchants should be able to schedule a courier pickup for a batch of parcels. Just make it work like the single pickup.

### Existing Single-Pickup Rules
- Merchant selects a date and a 2-hour pickup slot.
- Pickup slots run 08:00–18:00 merchant local time, Monday through Saturday.
- A pickup can be cancelled up to 1 hour before the slot.

## 1. Proposed Acceptance Criteria

### AC-01 — Successfully Schedule a Batch Pickup
**Given** the merchant has selected multiple valid parcels eligible for courier pickup  
**When** the merchant selects an available pickup date and 2-hour slot and confirms the booking  
**Then** system creates one batch pickup booking for all selected parcels and show a confirmation message with the assigned unique pickup reference number.

### AC-02 — Maximum Number of Parcels per Batch
**Given** the merchant is creating a batch pickup  
**When** the merchant selects more than the confirmed maximum number of parcels (default: 50)  
**Then** the system prevents the booking and displays: "A maximum of 50 parcels is allowed per batch pickup."

### AC-03 — Available Pickup Time Slots
**Given** the merchant is selecting a pickup schedule  
**When** the merchant opens the date and time slot selection  
**Then** the system displays only available 2-hour pickup slots from Monday through Saturday: 08:00–10:00, 10:00–12:00, 12:00–14:00, 14:00–16:00, and 16:00–18:00.

### AC-04 — Prevent Sunday Pickup Bookings
**Given** the merchant is selecting a pickup schedule  
**When** the merchant attempts to select a Sunday pickup date  
**Then** the system prevents the booking and displays an appropriate validation message.

### AC-05 — Merchant Local Time Zone
**Given** the merchant is located in Manila, Philippines, with a configured time zone of UTC+8  
**When** the merchant selects a pickup schedule for November 15, 2026, at 10:00 AM  
**Then** the system displays the pickup schedule as November 15, 2026, at 10:00 AM (Manila time) and stores the equivalent UTC time (November 15, 2026, at 2:00 AM) in the booking.

### AC-06 — Successfully Cancel a Batch Pickup
**Given** the merchant has a confirmed batch pickup and its slot starts 60 minutes or more from now
**When** the merchant cancels the batch pickup  
**Then** the system cancels the entire batch, updates its status to "Cancelled", and displays confirmation.

### AC-07 — Validate 1-Hour Pickup Cancellation Cutoff
**Given** the merchant has a confirmed batch pickup and its slot starts fewer than 60 minutes from now
**When** the merchant attempts to cancel the batch pickup  
**Then** the system rejects the cancellation, keeps the batch status unchanged, and displays an appropriate error message.

### AC-08 — Booking Confirmation and Details
**Given** the merchant has successfully scheduled a batch pickup  
**When** the booking is completed  
**Then** the merchant sees a confirmation page with batch reference, parcel count, tracking numbers, pickup date, 2-hour slot, local time zone, and booking status.

### AC-09 — Prevent Duplicate Batch Pickup Bookings
**Given** the merchant has already scheduled a pickup for selected parcels  
**When** the merchant submits the same booking request again  
**Then** the system prevents duplicate active bookings for those parcels and displays an explanatory message.

### AC-10 — Reject Entire Batch When One or More Parcels Are Invalid
**Given** the merchant has a batch containing one or more invalid parcels  
**When** the merchant submits the batch for booking  
**Then** the system rejects the entire batch without booking any parcels and displays the invalid parcels with their specific reasons.

### AC-11 — Validate Mixed Courier Services in Batch Booking
**Given** the merchant has a batch containing parcels with different courier services (Standard and Express)  
**When** the merchant submits the batch for booking  
**Then** the system allows the booking only if the pickup requirements are compatible; otherwise, it rejects the batch and displays the reason.

## 2. Assumptions and Questions Log

| # | Question or Assumption | Why It Matters (Risk if Wrong) | Proposed Default | Owner | Status |
|---|---|---|---|---|---|
| 1 | What is the maximum number of parcels allowed in one batch? | Large batches may cause performance issues or exceed courier capacity. | Maximum of 50 parcels per batch. | Product Owner | Pending Confirmation |
| 2 | Can Standard, Express, and SameDay services be included in the same batch pickup? | Mixing services with different pickup requirements may cause scheduling conflicts, missed pickups, or delivery delays. | Allow Standard and Express together in one batch. SameDay must be booked in a separate batch and cannot be mixed with Standard or Express. | Product Owner | Pending Confirmation |
| 3 | What happens if one parcel in the batch is invalid? | Partial bookings may cause confusion, missing parcels, or inconsistent records. | Reject the entire batch and display invalid parcels with reasons. | Product Owner | Pending Confirmation |
| 4 | Should batch pickups follow the same available days and time slots as single pickups? | Incorrect scheduling may result in unavailable couriers or missed pickups. | Monday–Saturday, 08:00–18:00, in 2-hour slots. | Product Owner | Based on Existing Feature — Verify |
| 5 | Which time zone should be used for pickup scheduling? | Incorrect time zones may cause missed pickups and customer complaints. | Use the merchant's configured local time zone. | Product Owner | Pending Confirmation |
| 6 | Does cancelling a batch pickup cancel all parcels in the batch? | Partial cancellation may cause unexpected pickups or incorrect booking statuses. | Cancellation applies to the entire batch. | Product Owner | Pending Confirmation |
| 7 | Is cancellation allowed exactly 1 hour before the pickup slot starts? | An unclear cutoff may lead to inconsistent cancellation behavior. | Allow cancellation at or before the 1-hour cutoff; reject later requests. | Product Owner | Pending Confirmation |
| 8 | What information should the merchant see after a successful booking? | Missing booking details may cause confusion and increase support requests. | Display batch reference, parcel list, pickup date, time slot, time zone, and booking status. | Product Owner | Pending Confirmation |
| 9 | Can parcels already assigned to an active pickup be included in another batch? | Duplicate bookings may result in unnecessary courier dispatches and operational costs. | Prevent duplicate active pickup bookings. | Product Owner | Pending Confirmation |
| 10 | Can a merchant submit a batch pickup with no parcels selected? | Empty bookings may create invalid records and unnecessary processing. | Require at least one valid parcel before booking. | Product Owner | Pending Confirmation |
| 11 | What happens if courier capacity becomes unavailable during booking? | Overbooking may result in failed or missed pickups. | Reject the booking and ask the merchant to select another available slot. | Product Owner | Pending Confirmation |
| 12 | What happens if a network interruption occurs during booking? | The merchant may retry and accidentally create duplicate bookings. | Verify the booking outcome and prevent duplicate creation on retry. | Product Owner / Engineering | Pending Confirmation |
| 13 | Can a merchant submit a batch pickup with zero parcels? | Allowing empty batches may create invalid bookings and waste system resources. | Reject batches with zero parcels and display a validation message. | Product Owner | Pending Confirmation |
| 14 | What should happen if courier capacity becomes unavailable during batch booking? | The system may confirm pickups without available couriers, resulting in scheduling conflicts and failed pickups. | Reject the entire batch, display a capacity-unavailable message, and allow the merchant to select another available slot. | Product Owner / Operations | Pending Confirmation |
| 15 | What should happen if a network interruption occurs during batch booking? | The merchant may not know whether the booking succeeded, potentially causing duplicate bookings or inconsistent records. | Ensure booking requests are idempotent, prevent duplicate bookings, and allow the merchant to safely retry or check the booking status. | Product Owner / Engineering | Pending Confirmation |

## 3. Traceability

| Test Case ID | Test Case Title | Mapped AC | Traceability Status |
|---|---|---|---|
| TC-001 | Verify successful batch pickup booking with multiple valid parcels | AC-01 | Mapped |
| TC-002 | Verify a unique batch pickup reference number is generated | AC-01 | Mapped |
| TC-003 | Verify booking with exactly 50 parcels is successful | AC-02 | Mapped |
| TC-004 | Verify booking with more than 50 parcels is rejected | AC-02 | Mapped |
| TC-005 | Verify mixed Standard and Express parcels can be booked when compatible | AC-10 | Mapped |
| TC-006 | Verify available 2-hour pickup slots between 08:00 and 18:00 | AC-03 | Mapped |
| TC-007 | Verify batch pickup scheduling is unavailable on Sundays | AC-03 | Mapped |
| TC-008 | Verify unavailable or past pickup slots cannot be selected | AC-03 | Mapped (past-slot rule needs clarification) |
| TC-009 | Verify pickup slots are displayed in the merchant's local time zone | AC-04 | Mapped |
| TC-010 | Verify the selected pickup time is preserved correctly after booking | AC-04 | Mapped |
| TC-011 | Verify successful cancellation more than 1 hour before pickup | AC-05 | Mapped |
| TC-012 | Verify cancellation updates the entire batch status to Cancelled | AC-05 | Mapped |
| TC-013 | Verify cancellation is allowed exactly 1 hour before pickup | AC-05 | Mapped (boundary assumption) |
| TC-014 | Verify cancellation is rejected less than 1 hour before pickup | AC-06 | Mapped |
| TC-015 | Verify booking confirmation displays batch reference and parcel details | AC-07 | Mapped |
| TC-016 | Verify booking confirmation displays pickup date, slot, time zone, and status | AC-07 | Mapped |
| TC-017 | Verify duplicate booking requests do not create additional pickups | AC-08 | Mapped |
| TC-018 | Verify parcels with active pickup bookings cannot be booked again | AC-08 | Mapped |


## 4. Message to the Product Owner

**Subject:** PP-520 — Proposed Acceptance Criteria for Confirmation

Hi [PO's Name],

I've drafted 10 acceptance criteria below for PP-520 Batch Pickup Scheduling based on the existing single-pickup functionality.

The criteria cover batch size, mixed services, invalid parcels, pickup schedules, time zones, cancellation rules, booking confirmation, and duplicate prevention.

Before finalizing, could you please confirm these three decisions?

1. Invalid parcels: Reject the entire batch if any parcel is invalid, displaying the affected parcels and reasons?
2. Mixed services: Allow Standard and Express in the same batch only when pickup requirements are compatible?
3. Cancellation cutoff: Allow cancellation at exactly 60 minutes before pickup, but reject requests made with less than 60 minutes remaining?

Proposed default if no reply: We will proceed with the above assumptions for test design, mark them as pending PO confirmation, and avoid treating them as approved requirements.

Please confirm or suggest changes in the ticket by **November 13, 2026, at 5:00 PM ET**.

Thank you!

Best regards,  
Sharmain  
Software Test Engineer
