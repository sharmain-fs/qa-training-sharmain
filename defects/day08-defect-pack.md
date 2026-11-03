# Day 8 — Defects, troubleshooting, and a release call (self-administered, no EM send)

Save everything in `defects/day08/` in your training repo.

---

## Part 1 — Severity vs priority (about 45 minutes)

Set **severity** (impact on the system or user) and **priority** (urgency of the fix, a business call) separately for each defect. Use Critical / High / Medium / Low for both. One line of reasoning for each, and say who would normally confirm the priority.

| # | Defect |
|---|---|
| 1 | The ParcelPoint logo on the login page is the old 2023 logo. A rebrand launches to all merchants tomorrow morning. |
| 2 | If a merchant books 50 parcels in one batch and the network drops mid-request, about 1 in 200 times the batch is charged twice. |
| 3 | The courier app crashes when a delivery photo is larger than 25 MB. Phone cameras in use produce 3–8 MB photos. |
| 4 | Merchant staff can see the "Issue refund" button. Clicking it shows "Not allowed." No refund happens. |
| 5 | A merchant user can download another merchant's shipping labels by changing the label ID in the URL. |
| 6 | The Cebuano translation of "Delivered" on the tracking page is misspelled. |
| 7 | The daily settlement report shows totals in USD for Philippine merchants for one hour after midnight UTC, then corrects itself. |
| 8 | On iOS 16 only, the shipment list does not refresh after pull-to-refresh. iOS 16 is 3% of merchant devices. |

Then answer: which two would you raise with the Product Owner **today**, and how would you phrase the message?

## Part 2 — Rewrite three bug reports (about 60 minutes)

Rewrite each report so a developer can act on it without asking you anything. Use: Title (what, where, when), Environment (app/build, platform, OS version, device, test account, merchant time zone), Preconditions, Steps, Expected, Actual, Evidence (what you would attach), Scope (platforms/versions checked and result), Severity, Priority. Where you would need information you do not have, write what you would collect and how.

```
BUG A   Title: tracking broken
Steps: open tracking. Actual: doesn't work. Expected: works.

BUG B   Title: Android issue
Steps: create shipment, rotate phone.
Actual: app closes sometimes.   Expected: no crash.
Platform: Android   Build: (blank)

BUG C   Title: wrong delivery date
Steps: book Standard.
Actual: says Sunday.   Expected: Monday.
Note: only happens for the US merchant
```

## Part 3 — Evidence capture without special tools (about 45 minutes)

Use the Playwright demo app at https://demo.playwright.dev/todomvc in Chrome.

1. Open Chrome DevTools (F12). In **Network**, add three todos and save the requests as a **HAR** file. In **Console**, screenshot any messages.
2. In DevTools, turn on device emulation (a mid-range Android phone) and **Network throttling: Slow 4G**. Reload the page 3 times and record the load time each time (Network tab, bottom bar "Load"). Do the same with throttling off.
3. Write a 5-line performance note: what you measured, conditions (device emulation, network, browser version), the numbers, and what you would tell a developer if a user said "the app feels slow on older phones."
4. **Optional if you have an Android phone with Developer options:** follow the Android logcat guide in your day card and capture a filtered log while you open and close an app. Attach a 20-line excerpt and say what you filtered on.

## Part 4 — The release call (about 60 minutes)

```
RELEASE PACKAGE — ParcelPoint Courier App v3.5 (Android + iOS)
Feature: Proof-of-delivery photo is required before marking Delivered.
Fix:     PP-455 (iOS only) Signature pad freezes on iPad. Status: Fixed

TEST RUN — "v3.5 Sign-off"
TC-31 Mark Delivered without photo is blocked     Android  Passed
TC-32 Mark Delivered with photo succeeds          Android  Passed
TC-33 Photo upload on slow network (3G)           Android  Blocked  "No throttling tool"
TC-34 Retest PP-455 signature pad                 iPhone 14 Passed
TC-35 Mark Delivered without photo is blocked     iOS      Not Run
TC-36 Courier smoke: login, route, scan           Both     Passed

OPEN DEFECTS
PP-461 High/Medium: photo upload retries forever with no message when offline (Android).
PP-463 Low/Low: photo thumbnail is slightly stretched.

PM: "We need this out today for the Monday pilot with 40 couriers. Go or no-go in an hour?"
```

Write a **go/no-go memo** (one page maximum) to the PM with:
1. What was tested and what was **not** (be exact).
2. The risks you see, in order, with the user impact of each.
3. Your recommendation (go / no-go / go with named risks) and the **conditions** attached to it.
4. The options you are giving the PM, and who owns the final decision.
5. What you will do in the next hour to reduce the risk.
