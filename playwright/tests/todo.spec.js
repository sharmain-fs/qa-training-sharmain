// UI tests against the official Playwright demo app: https://demo.playwright.dev/todomvc
// One worked example is provided. Write the three TODO tests yourself.
const { test, expect } = require('@playwright/test');

const APP = 'https://demo.playwright.dev/todomvc';

async function addTodo(page, text) {
  const input = page.getByPlaceholder('What needs to be done?');
  await input.fill(text);
  await input.press('Enter');
}

test.beforeEach(async ({ page }) => {
  await page.goto(APP);
});

test('adds one todo and shows it in the list', async ({ page }) => {
  
  await addTodo(page, 'Pack parcel R-0001');

  await expect(page.getByTestId('todo-title')).toHaveText(['Pack parcel R-0001']);
  await expect(page.getByTestId('todo-count')).toContainText('1 item left');
});

// TODO 1: Mark a todo as completed and verify 0 items left.
test('marks a todo as completed', async ({ page }) => {
  
  await addTodo(page, 'Pack parcel R-0001');

  await page.getByRole('checkbox', { name: 'Toggle Todo' }).check();

  await expect(page.getByTestId('todo-count')).toContainText('0 items left');
  await expect(page.getByTestId('todo-item')).toHaveClass(/completed/);
});

// TODO 2: Add three todos, complete one, and filter Active.
test('shows only active todos after filtering', async ({ page }) => {

  const todos = [
    'Pack parcel R-0001',
    'Ship parcel R-0002',
    'Deliver parcel R-0003'
  ];

  for (const todo of todos) {
     await addTodo(page, todo);
  }

  await page.getByTestId('todo-item').first()
    .getByRole('checkbox').check();

  await page.getByRole('link', { name: 'Active' }).click();

  await expect(page.getByTestId('todo-item')).toHaveCount(2);
  await expect(page.getByTestId('todo-title')).toHaveText([
    'Ship parcel R-0002',
    'Deliver parcel R-0003'
  ]);
});

// TODO 3: Negative test - whitespace-only todo is not added.
test('does not add a whitespace-only todo', async ({ page }) => {
  
  await addTodo(page, '   ');

  await expect(page.getByTestId('todo-item')).toHaveCount(0);
});