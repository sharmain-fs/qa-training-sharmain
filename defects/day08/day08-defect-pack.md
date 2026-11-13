# Day 08 — Defects, troubleshooting, and a release call

## Part 1 — Severity vs. Priority

| # | Severity | Priority | Reasoning |
|---|---|---|---|
| 1 | Low | Critical | Outdated branding does not break functionality, but tomorrow's merchant-wide rebrand makes correction urgent. |
| 2 | Critical | Critical | Intermittent double charges cause direct financial harm and require urgent containment, refund/reconciliation, and a fix. |
| 3 | High | Low | A crash prevents completing the photo flow for oversized files, but typical camera photos (3–8 MB) are below the 25 MB trigger; verify other sources. |
| 4 | Low | Medium | Backend authorization correctly prevents refunds, but showing an unauthorized action misleads staff and may create support tickets. |
| 5 | Critical | Critical | ID manipulation exposes other merchants' labels (potential personal/address data): a cross-tenant authorization and privacy failure. |
| 6 | Low | Low | A misspelling affects localization quality but not delivery status or workflow; raise if wording changes meaning. |
| 7 | High | High | Incorrect currency for an hour may mislead reconciliation and financial decisions; prioritize before the next settlement window. |
| 8 | Medium | Medium | A stale shipment list affects 3% of devices and can cause mistaken decisions; a workaround may exist, but needs verification. |

**Priority confirmation:** The Product Owner normally confirms business priority, with input from the PM, engineering lead, security/privacy owner (especially #5), finance/operations (#2 and #7), and brand/marketing (#1). QA proposes severity and priority; engineering and incident leads can escalate urgent production incidents immediately.

### Two defects to raise with the Product Owner today

**#5 (cross-merchant label download)** and **#2 (duplicate batch charge)** present the highest direct customer, security, and financial risks. Escalate #1 separately to the brand/release owner today because its launch deadline is tomorrow.

> Hi [PO], I recommend immediate escalation of two critical ParcelPoint defects: **#5**, changing a label ID lets one merchant download another merchant's shipping labels (cross-merchant data exposure), and **#2**, an interrupted 50-parcel booking sometimes results in a duplicate charge (~1 in 200 occurrences under the stated conditions). Can we confirm **Critical** priority for both today? I propose restricting vulnerable label access while engineering investigates authorization, and containing duplicate billing with reconciliation/refunds and idempotency checks. Please confirm owners and the release decision today. I will provide reproduction steps and evidence as soon as verified.

## Part 2 — Rewritten bug reports

The original reports do not establish the exact screens, test data, build, expected business rules, or reproducibility. The following are **investigation-ready draft reports**, not claims of observed reproduction. Fill the bracketed fields and execute the listed checks before filing as verified defects.

### BUG A — Tracking page fails to display shipment status when opened

**Environment:** 
  - **App/web build:**ParcelPoint v3.4.0 
  - **Platform:** Web Application 
  - **OS:** Windows 11 
  - **Device/model:** Dell Laptop 
  - **Browser and version:** Google Chrome version 157.0.8103.79
  - **Test account/role:** merchant_admin 
  - **Merchant time zone:** UTC

**Preconditions:** Use merchant_admin that has access to a valid shipment with a known tracking ID and status. The browser has an active internet connection.

**Steps:** 
1. Open ParcelPoint web application in Google Chrome.
2. Log in as merchant_admin. 
3. Navigate to Tracking Page.
4. Enter shipment ID SHP-101. 
5. Wait for 3 seconds and record UI and network response. 
6. Refresh the page and repeat using another valid tracking ID to isolate the trigger.

**Expected:** The Tracking page successfully loads and displays the correct shipment status associated with the tracking ID.

**Actual:** The Tracking page fails to load and display the shipment information.

**Evidence:** Screen recording/screenshot with sensitive details redacted; Chrome Console and Network/HAR (sanitize tokens/cookies); request/response IDs, timestamps, logs, and expected shipment status from a trusted source.

**Scope:** The reported defect affects the Tracking page of the ParcelPoint v3.4.0 web application, preventing merchants from viewing shipment status when opening shipment details. The reported test environment is Google Chrome on Windows 11, pending verification. Other browsers, operating systems, and mobile web environments have not been tested, so the scope is limited to the reported workflow and environment.

**Severity: High** The defect prevents merchants from viewing shipment status, affecting a core tracking functionality. Users cannot reliably monitor shipment progress, potentially causing operational delays and increased customer support inquiries.

**Priority: High** Shipment tracking is an essential merchant-facing feature. The defect should be prioritized for resolution before the next release because it directly affects shipment visibility and user experience. The Product Owner (PO) should confirm the final priority based on business impact, affected users, and release timelines.

### BUG B — Android app intermittently closes after rotating device on Create Shipment screen

**Environment:**
  - **App/web build:** ParcelPoint v3.4.0 
  - **Platform:** Android  
  - **OS:** Android v16
  - **Device/model:** Samsung S23 FE
  - **Test account/role:** merchant_admin 
  - **Merchant time zone:** UTC

**Preconditions:** App installed with clean launch; user authenticated and permitted to create shipments; test data available; record battery optimization, available memory, and network state.

**Steps:** 
1. Launch ParcelPoint app in portrait. 
2. Open Create Shipment. 
3. Fill required fields on screen. 
4. Rotate portrait to landscape.
5. Repeat at least 5 times, logging each outcome; test a fresh launch and a partially completed form separately.

**Expected:** App remains open, preserves entered form data where required, and adapts or handles orientation safely without a crash.

**Actual:** App closes sometimes.

**Evidence:** Video showing orientation and termination, Android logcat filtered by app package and crash/fatal exception, crash report/stack trace, build identifier, timestamp, and reproducibility count.

**Scope:** The defect affects ParcelPoint v3.4.0 on Android 16, Samsung Galaxy S23 FE, specifically the Create Shipment screen when rotating the device from portrait to landscape. The app intermittently closes during shipment creation. Other Android versions and devices have not been tested, so the confirmed scope is limited to the reported environment.

**Severity: High** The unexpected app closure interrupts the shipment creation process and may cause merchants to lose entered information, requiring them to restart the process. This affects a core business function, even though data loss has not yet been confirmed.

**Priority: High** The defect affects a frequently used merchant workflow and should be fixed before the next release if reproducible. The intermittent crash creates a risk of disrupted shipment bookings and a poor user experience. The Product Owner (PO) should confirm the final priority based on business impact, affected users, and release timelines.

### BUG C — Standard shipment displays incorrect delivery date (Sunday instead of Monday) for US merchant

**Environment:**
  - **App/web build:** ParcelPoint v3.4.0
  - **Platform:** Web Application 
  - **OS:** Windows 11 
  - **Device/model:** Dell Laptop 
  - **Browser and version:** Google Chrome version 157.0.8103.79
  - **Test account/role:** merchant_admin (US merchant)
  - **Merchant time zone:** UTC
  - **Browser/device time zone:** UTC
  - **Locale:** en-US

**Preconditions:** The merchant_admin is logged into the ParcelPoint web application using a US merchant account configured with UTC as its time zone. Standard shipping is enabled, and valid shipment details are available. For this test scenario, the applicable shipping rules are assumed to specify Monday, November 16, 2026, as the estimated delivery date for a shipment booked on Friday, November 13, 2026, at 15:30 UTC. This expected date must be verified against the shipping SLA, cutoff time, and holiday calendar.

**Steps:**
1. Open the ParcelPoint web application in Google Chrome.
2. Log in using the US merchant_admin account.
3. Verify that the merchant account and browser time zones are configured to UTC.
4. Navigate to the Create Shipment page.
5. Enter valid shipment details, including recipient information, destination, and parcel weight.
6. Select **Standard** as the shipping service.
7. Set the test booking date and time to **November 13, 2026, at 15:30 UTC (Friday)**.
8. Submit the shipment booking.
9. Observe the estimated delivery date displayed on the confirmation page.
10. Compare the displayed date against the expected delivery date of **Monday, November 16, 2026**.

**Expected:** The system displays **Monday, November 16, 2026**, as the estimated delivery date for the Standard shipment, based on the assumed shipping SLA, business-day rules, and UTC merchant time zone.

**Actual:** The system displays **Sunday, November 15, 2026** instead of **Monday, November 16, 2026**. 

**Evidence:** Screenshot showing the incorrect Sunday delivery date, shipment booking details, Chrome DevTools Network response containing the estimated delivery date, browser time-zone settings, and the applicable shipping schedule confirming Monday as the expected delivery date.

**Scope:** The reported defect affects **ParcelPoint v3.4.0 web application for US merchant accounts**, specifically the estimated delivery date displayed after booking a Standard shipment. The reported scenario uses a US merchant_admin account configured with UTC and Google Chrome on Windows 11. Other browsers, operating systems, merchant time zones, and Philippine merchant accounts have not been tested. The confirmed affected scope remains limited to the original US merchant report until the specified scenario is reproduced.

**Severity: Medium** The defect displays an incorrect estimated delivery date, potentially misleading merchants and recipients about when their shipments will arrive. Although shipment creation remains functional, inaccurate delivery information can cause customer confusion, scheduling problems, and additional support inquiries.

**Priority: High** The defect affects customer-visible delivery information for US merchants and should be prioritized for correction before the next release. Incorrect delivery estimates may negatively affect customer trust and create avoidable delivery expectations. The Product Owner (PO) should confirm the final priority based on affected merchants, business impact, and release timelines.

## Part 3 — Evidence capture without special tools

## 3.1 Observation – HAR File and Local Storage
While testing the Playwright TodoMVC application, I noticed that adding new todo items did not generate any additional HTTP requests in the Network tab. This is because the application handles todo operations locally in the browser and saves the items in Local Storage instead of sending them to a backend server. Since a HAR file only captures HTTP network activity, the added todo items were not recorded in the exported HAR file. I verified this by checking the Application tab in Chrome DevTools under Local Storage, where the saved todo items were visible.

## 3.2 Performance Measurement Results

| Run | Slow 4G Load (ms) | No throttling Load (ms) |
|---|---:|---:|
| 1 | 599 ms | 90 ms |
| 2 | 598 ms | 92 ms |
| 3 | 636 ms | 98 ms |
| **Average** | **611 ms** | **93.33 ms** |

## Average Load Time Calculation

**Slow 4G:**

(599 + 598 + 636) / 3 = 611 ms

**No throttling:**

(90 + 92 + 98) / 3 = 93.33 ms

## Performance Analysis

- **Slow 4G Average Load Time:** 611 ms
- **No Throttling Average Load Time:** 93.33 ms
- **Difference:** 517.67 ms
- **Performance Ratio:** Approximately 6.55 times longer under Slow 4G.

## Conclusion

The performance test results indicate that TodoMVC loads approximately **6.55 times slower under Slow 4G** compared with No throttling.

The results demonstrate the impact of simulated network conditions on page loading performance. However, Chrome DevTools device emulation does not fully represent the CPU, memory, or rendering capabilities of older physical Android devices.

Further testing on real devices is recommended to investigate potential performance issues related to JavaScript execution, rendering, memory usage, and network requests.

## 3.3 5-Line Performance Note

1. **Measured:** Chrome DevTools Network "Load" event time for TodoMVC across three page reloads per network condition.

2. **Conditions:** Google Chrome **157.0.8103.79**, device emulation **Custom Android 360 (360 × 800 px, DPR 3 — confirm actual profile)**, cache **disabled (confirm actual setting)**, Slow 4G versus No throttling; test time **[actual timestamp, UTC+08:00]**.

3. **Slow 4G:** **599 ms, 598 ms, 636 ms**; mean **611 ms**.

4. **No throttling:** **90 ms, 92 ms, 98 ms**; mean **93.33 ms**.

5. **Developer message:** "A user reports slowness on older phones. Our measurements show that Slow 4G has an average Load time of 611 ms, compared with 93.33 ms without throttling, approximately 6.55 times longer. Please investigate real-device CPU/memory, JavaScript execution, rendering, and the network waterfall. These emulated load times alone do not establish older-phone performance."

## 3.4 I don't have an Android phone to test it with.