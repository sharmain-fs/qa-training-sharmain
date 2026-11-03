// UI tests against the official Playwright demo app: https://demo.playwright.dev/todomvc
// One worked example is provided. Write the three TODO tests yourself.
const { test, expect } = require('@playwright/test');

const APP = 'https://demo.playwright.dev/todomvc';

test.beforeEach(async ({ page }) => {
  await page.goto(APP);
});

test('adds one todo and shows it in the list', async ({ page }) => {
  const input = page.getByPlaceholder('What needs to be done?');
  await input.fill('Pack parcel R-0001');
  await input.press('Enter');

  await expect(page.getByTestId('todo-title')).toHaveText(['Pack parcel R-0001']);
  await expect(page.getByTestId('todo-count')).toContainText('1 item left');
});

// TODO 1: mark a todo as completed and check that "0 items left" is shown.
// TODO 2: add three todos, complete one, click the "Active" filter, and check only two remain visible.
// TODO 3: a negative case of your choice (for example: an empty or whitespace-only todo is not added).
