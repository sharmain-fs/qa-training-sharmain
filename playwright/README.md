# Day 9 — Playwright starter

Copy this folder into `playwright/` in your training repo (it is already there if your repo was seeded on Day 1).

```
cd playwright
npm install
npx playwright install chromium
npx playwright test tests/todo.spec.js      # UI tests, needs internet
node ../sandbox/server.js                   # in a second terminal, for the API tests
npx playwright test tests/api-shipments.spec.js
npx playwright show-report                  # opens the HTML report
```

Docs: https://playwright.dev/docs/intro (install, first test) and https://playwright.dev/docs/api-testing (API tests).
Commit your tests on a branch and open a PR. Do **not** commit `node_modules/`, `playwright-report/`, or `test-results/` (the repo's `.gitignore` already excludes them).
