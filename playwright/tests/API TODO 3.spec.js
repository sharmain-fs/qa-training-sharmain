const { test, expect } = require('@playwright/test');

const BASE = process.env.SANDBOX_URL || 'http://localhost:4010';

async function login(request, username, password) {
  const res = await request.post(`${BASE}/auth/login`, { data: { username, password } });
  expect(res.status()).toBe(200);
  return (await res.json()).token;
}

// TODO 1: Request /shipments with no token and assert 401.
test('unauthenticated user cannot access shipments', async ({ request }) => {
  const res = await request.get(`${BASE}/shipments`);

  expect(res.status()).toBe(401);
});

// TODO 2: Merchant 2 cannot READ merchant 1 shipment.
test('merchant cannot read another merchant shipment', async ({ request }) => {
  const token = await login(request, 'cara', 'Cara#2026');

  const res = await request.get(`${BASE}/shipments/1001`, {
    headers: { Authorization: `Bearer ${token}` }
  });

  expect(res.status()).toBe(404);
});

// TODO 3: Merchant 2 cannot CHANGE merchant 1 shipment status.
test('merchant cannot change another merchant shipment status', async ({ request }) => {
  const token = await login(request, 'cara', 'Cara#2026');

  const res = await request.patch(`${BASE}/shipments/1001/status`, {
    headers: { Authorization: `Bearer ${token}` },
    data: { status: 'Delivered' }
  });

  expect(res.status()).toBe(409);
});