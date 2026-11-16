# AUTOMATION-CANDIDATES

## 5 Regression Cases to Automate First

| Case ID | Regression Case | Reason |
|---|---|---|
| R4 | Weight boundaries 0.1 / 30 accepted, 0.09 / 30.01 rejected | Failed last sprint. Boundary validation is critical and can be reliably automated using data-driven tests. |
| R3 | Create Standard shipment, fee PHP 120 | Runs 30 times per month. Automating fee validation helps prevent incorrect customer charges. |
| R8 | Merchant cannot read or change another merchant's shipment | High security risk involving broken access control. API automation can verify unauthorized access is consistently blocked. |
| R10 | Tracking page shows correct local time for US merchants | Failed last sprint. Automated tests can verify time zone conversions and prevent incorrect delivery information. |
| R1 | Login with valid merchant credentials | Runs 40 times per month. Login is a critical workflow and a prerequisite for many other automated tests. |

## 2 Regression Cases Not to Automate

| Case ID | Regression Case | Reason |
|---|---|---|
| R12 | Delivery photo is sharp enough to read a house number | Image sharpness and readability require human visual judgment. Automated checks cannot reliably assess real-world photo quality. |
| R20 | Exploratory session on new features | Exploratory testing relies on human creativity, observation, and investigation of unexpected behavior. It cannot be fully replaced by scripted automation. |
