// API tests against your local ParcelPoint sandbox (start it first: node sandbox/server.js).
// One worked example is provided. Write the TODO tests yourself.
const { test, expect } = require('@playwright/test');

const BASE = process.env.SANDBOX_URL || 'http://localhost:4010';

const USERS = {
  ana: {
    username: process.env.ANA_USERNAME ?? 'ana',
    password: process.env.ANA_PASSWORD ?? 'Ana#2026'
  },
  cara: {
    username: process.env.CARA_USERNAME ?? 'cara',
    password: process.env.CARA_PASSWORD ?? 'Cara#2026'
  }
};

async function login(request, username, password) {
  const res = await request.post(`${BASE}/auth/login`, { data: { username, password } });
  expect(res.status()).toBe(200);
  return (await res.json()).token;
}

test('merchant admin can read own shipment', async ({ request }) => {
  const anaToken = await login(
  request,
  USERS.ana.username,
  USERS.ana.password
);
  const res = await request.get(`${BASE}/shipments/1001`, { headers: { Authorization: `Bearer ${anaToken}` } });
  expect(res.status()).toBe(200);
  const body = await res.json();
  expect(body.id).toBe(1001);
  expect(body.merchantId).toBe(1);
});

// TODO 1: Request /shipments with no token and assert 401.
test('unauthenticated user cannot access shipments', async ({ request }) => {
  const res = await request.get(`${BASE}/shipments`);

  expect(res.status()).toBe(401);
});

// TODO 2: Merchant 2 cannot READ merchant 1 shipment.
test('merchant cannot read another merchant shipment', async ({ request }) => {

  const token = await login(
    request,
    USERS.cara.username,
    USERS.cara.password
  );

  const res = await request.get(`${BASE}/shipments/1001`, {
    headers: { Authorization: `Bearer ${token}` }
  });

  expect(res.status()).toBe(404);
});

// TODO 3: Merchant 2 cannot CHANGE Merchant 1 shipment status.
// FAILS: Sandbox has no ownership check on PATCH, see BUG-003.
test('merchant cannot change another merchant shipment status', async ({ request }) => {

  // Step 1: Login as Ana (Merchant 1)
  const anaToken = await login(
  request,
  USERS.ana.username,
  USERS.ana.password
);

  // Step 2: Create a new shipment owned by Merchant 1
  const createRes = await request.post(`${BASE}/shipments`, {
    headers: { Authorization: `Bearer ${anaToken}` },
    data: {
      recipientName: 'Test Recipient',
      city: 'Cebu City',
      weightKg: 2,
      service: 'Standard'
    }
  });

  expect(createRes.status()).toBe(201);

  const shipment = await createRes.json();
  const shipmentId = shipment.id;

  expect(shipment.status).toBe('Created');

  // Step 3: Login as Cara (Merchant 2)
  const caraToken = await login(
  request,
  USERS.cara.username,
  USERS.cara.password
);

  // Step 4: Attempt to change Merchant 1 shipment status
  // Created -> PickedUp is a valid transition
  const res = await request.patch(`${BASE}/shipments/${shipmentId}/status`, {
    headers: { Authorization: `Bearer ${caraToken}` },
    data: { status: 'PickedUp' }
  });

  // Step 5: Verify cross-merchant update is denied
  // Expected according to README: 404 Not Found
  expect(res.status()).toBe(404);

  // Step 6: GET shipment as Ana and verify status is unchanged
  const getRes = await request.get(`${BASE}/shipments/${shipmentId}`, {
    headers: { Authorization: `Bearer ${anaToken}` }
  });

  expect(getRes.status()).toBe(200);

  const updatedShipment = await getRes.json();

  expect(updatedShipment.status).toBe('Created');
});