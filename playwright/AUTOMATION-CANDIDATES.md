# AUTOMATION-CANDIDATES

## 5 Regression Cases to Automate First

| Case ID | Regression Case | Reason |
|---|---|---|
| R4 | Weight boundaries 0.1 / 30 accepted, 0.09 / 30.01 rejected | **Frequency:** Runs 20 times per month. **Stability:** Can be reliably automated using data-driven tests with fixed boundary values and expected results. **Risk:** Prevents invalid shipment weights from being accepted and valid boundary values from being rejected. **Last failure:** Failed last sprint, making it a high-priority regression candidate. |
| R3 | Create Standard shipment, fee PHP 120 | **Frequency:** Runs 30 times per month. **Stability:** Can be automated using fixed shipment data and a consistent expected fee of PHP 120. **Risk:** Ensures accurate shipment fees and prevents incorrect customer charges. **Last failure:** Failed 2 months ago, indicating a need for regression coverage. |
| R8 | Merchant cannot read or change another merchant's shipment | **Frequency:** Runs 10 times per month. **Stability:** Can be reliably automated using API tests with fixed merchant accounts, shipment ownership, and expected authorization responses. **Risk:** High security risk involving unauthorized access or modification of another merchant's shipment data. **Last failure:** Never run via API, making automated access-control coverage especially important. |
| R10 | Tracking page shows correct local time for US merchants | **Frequency:** Runs 8 times per month. **Stability:** Use Playwright's timezoneId with a mocked clock and fixed merchant time-zone data to ensure consistent results across test runs. **Risk:** Prevents incorrect delivery information caused by time-zone conversion errors. **Last failure:** Failed last sprint, making it a high-priority regression candidate. |
| R2 | Login with wrong password shows error, account not locked after 1 try | **Frequency:** Runs 40 times per month. **Stability:** Can be automated using fixed invalid credentials and a dedicated test account with a known initial state. **Risk:** Ensures incorrect passwords are rejected with the proper error message without locking the account after one attempt. **Last failure:** Failed 4 months ago, indicating a regression risk that warrants automated coverage. |

## 2 Regression Cases Not to Automate

| Case ID | Regression Case | Reason |
|---|---|---|
| R12 | Delivery photo is sharp enough to read a house number | Image sharpness and readability require human visual judgment. Automated checks cannot reliably assess real-world photo quality. |
| R19 | New-merchant onboarding wizard (changes every sprint) | The onboarding wizard UI changes every sprint, making automated scripts fragile and requiring frequent updates. |
