// API tests against your local ParcelPoint sandbox (start it first: node sandbox/server.js).
// One worked example is provided. Write the TODO tests yourself.
const { test, expect } = require('@playwright/test');

const BASE = process.env.SANDBOX_URL || 'http://localhost:4010';

async function login(request, username, password) {
  const res = await request.post(`${BASE}/auth/login`, { data: { username, password } });
  expect(res.status()).toBe(200);
  return (await res.json()).token;
}

test('merchant admin can read own shipment', async ({ request }) => {
  const token = await login(request, 'ana', 'Ana#2026');
  const res = await request.get(`${BASE}/shipments/1001`, { headers: { Authorization: `Bearer ${token}` } });
  expect(res.status()).toBe(200);
  const body = await res.json();
  expect(body.id).toBe(1001);
  expect(body.merchantId).toBe(1);
});

// TODO 1: request /shipments with no token and assert 401.
// TODO 2: log in as cara (merchant 2) and assert she cannot READ shipment 1001 (expect 404).
// TODO 3: log in as cara and try to CHANGE the status of shipment 1001. Write the assertion for what the
//         spec says should happen. If the test fails, that is a finding: keep the test, and file the bug.
