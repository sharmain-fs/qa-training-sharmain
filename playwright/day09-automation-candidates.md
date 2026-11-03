# Day 9 — Which regression cases to automate first (self-administered, no EM send)

The ParcelPoint team has the 20 manual regression cases below and time to automate **5** this sprint. Pick the 5, then name **2** you would never automate. One or two lines of reasoning each. Save as `playwright/AUTOMATION-CANDIDATES.md`.

| # | Manual regression case | Runs per month | Last failed |
|---|---|---|---|
| R1 | Login with valid merchant credentials | 40 | Never |
| R2 | Login with wrong password shows error, account not locked after 1 try | 40 | 4 months ago |
| R3 | Create Standard shipment, fee PHP 120 | 30 | 2 months ago |
| R4 | Weight boundaries 0.1 / 30 accepted, 0.09 / 30.01 rejected | 20 | Last sprint |
| R5 | SameDay hidden for cities outside Cebu metro | 20 | Never |
| R6 | Status lifecycle: every valid transition | 10 | 3 months ago |
| R7 | Status lifecycle: final states cannot change | 10 | Not run in 6 months |
| R8 | Merchant cannot read or change another merchant's shipment | 10 | Never run via API |
| R9 | Label PDF looks right when printed on a thermal printer | 4 | 1 month ago |
| R10 | Tracking page shows correct local time for US merchants | 8 | Last sprint |
| R11 | Pull-to-refresh on iOS shipment list | 15 | 1 month ago |
| R12 | Delivery photo is sharp enough to read a house number | 6 | Unknown |
| R13 | Bulk print 50 labels | 6 | 2 sprints ago |
| R14 | Cebuano and Filipino translations on tracking page | 4 | 3 sprints ago |
| R15 | Support role cannot change shipment status | 10 | Never run |
| R16 | Settlement report totals match the sum of fees | 4 | Last month |
| R17 | Accessibility: tracking page usable with screen reader | 2 | Never run |
| R18 | Logout clears the session token | 10 | Never |
| R19 | New-merchant onboarding wizard (changes every sprint) | 8 | Every sprint |
| R20 | Exploratory session on new features | 4 | n/a |
