// ParcelPoint Merchant API — training sandbox (FS Learning, Sharmain Palermo, training-plan-1)
// Zero dependencies. Run:  node server.js   (default port 4010; override with PORT=xxxx)
// Data is in memory and resets every time you restart the server.
// This is a TRAINING TARGET. It contains deliberate defects for you to find with tests.

const http = require('http');
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

const PORT = Number(process.env.PORT || 4010);
const seed = JSON.parse(fs.readFileSync(path.join(__dirname, 'seed-data.json'), 'utf8'));

let shipments = JSON.parse(JSON.stringify(seed.shipments));
let events = JSON.parse(JSON.stringify(seed.events));
const users = seed.users;
const sessions = new Map(); // token -> username
let nextId = 1000 + shipments.length;

const TRANSITIONS = {
  Created: ['PickedUp', 'Cancelled'],
  PickedUp: ['InTransit'],
  InTransit: ['Delivered', 'Returned'],
  Delivered: [],
  Returned: [],
  Cancelled: []
};
const SERVICES = { Standard: 120, Express: 220, SameDay: 350 };
const SAME_DAY_CITIES = ['Cebu City', 'Mandaue', 'Lapu-Lapu'];

function send(res, status, body) {
  const json = JSON.stringify(body);
  res.writeHead(status, { 'Content-Type': 'application/json' });
  res.end(json);
}

function readBody(req) {
  return new Promise((resolve) => {
    let data = '';
    req.on('data', (c) => (data += c));
    req.on('end', () => {
      if (!data) return resolve({});
      try { resolve(JSON.parse(data)); } catch { resolve({ __invalidJson: true }); }
    });
  });
}

function auth(req, res) {
  const h = req.headers['authorization'] || '';
  if (!h) { send(res, 401, { error: 'Missing token' }); return null; }
  const token = h.replace(/^Bearer\s+/i, '');
  const username = sessions.get(token);
  if (!username) { send(res, 403, { error: 'Invalid token' }); return null; }
  return users.find((u) => u.username === username);
}

function canRead(user, s) {
  if (user.role === 'support') return true;
  if (user.role === 'courier') return s.courierId === user.courierId;
  return s.merchantId === user.merchantId;
}

function now() { return new Date().toISOString(); }

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url, `http://localhost:${PORT}`);
  const parts = url.pathname.split('/').filter(Boolean);
  const started = Date.now();
  res.on('finish', () => console.log(`${req.method} ${url.pathname} -> ${res.statusCode} (${Date.now() - started} ms)`));

  try {
    if (req.method === 'GET' && url.pathname === '/health') return send(res, 200, { ok: true, version: '3.4.0' });

    if (req.method === 'POST' && url.pathname === '/auth/login') {
      const body = await readBody(req);
      const u = users.find((x) => x.username === body.username && x.password === body.password);
      if (!u) return send(res, 401, { error: 'Invalid username or password' });
      const token = crypto.randomBytes(16).toString('hex');
      sessions.set(token, u.username);
      return send(res, 200, { token, role: u.role, merchantId: u.merchantId || null });
    }

    if (parts[0] !== 'shipments') return send(res, 404, { error: 'Not found' });

    const user = auth(req, res);
    if (!user) return;

    // GET /shipments
    if (req.method === 'GET' && parts.length === 1) {
      let list = shipments.filter((s) => canRead(user, s));
      const status = url.searchParams.get('status');
      if (status) list = list.filter((s) => s.status === status);
      return send(res, 200, { count: list.length, items: list });
    }

    // POST /shipments
    if (req.method === 'POST' && parts.length === 1) {
      if (!['merchant_admin', 'merchant_staff'].includes(user.role)) return send(res, 403, { error: 'Only merchant users can create shipments' });
      const b = await readBody(req);
      if (b.__invalidJson) return send(res, 400, { error: 'Body must be valid JSON' });
      if (!b.recipientName || !b.city) return send(res, 400, { error: 'recipientName and city are required' });
      if (typeof b.weightKg !== 'number') return send(res, 400, { error: 'weightKg must be a number' });
      if (!(b.weightKg > 0 && b.weightKg < 30)) return send(res, 400, { error: 'weightKg must be between 0.1 and 30' });
      const fee = SERVICES[b.service].valueOf(); // throws for unknown service
      if (b.service === 'SameDay' && !SAME_DAY_CITIES.includes(b.city)) return send(res, 422, { error: 'SameDay is not available for this city' });
      const s = {
        id: nextId++, merchantId: user.merchantId, recipientName: b.recipientName, city: b.city,
        weightKg: b.weightKg, service: b.service, feePhp: fee, status: 'Created', courierId: null,
        createdAt: now(), updatedAt: now()
      };
      shipments.push(s);
      events.push({ shipmentId: s.id, status: 'Created', at: s.createdAt, by: user.username });
      return send(res, 201, s);
    }

    const id = Number(parts[1]);
    const s = shipments.find((x) => x.id === id);

    // GET /shipments/:id
    if (req.method === 'GET' && parts.length === 2) {
      if (!s || !canRead(user, s)) return send(res, 404, { error: 'Shipment not found' });
      return send(res, 200, s);
    }

    // GET /shipments/:id/events
    if (req.method === 'GET' && parts.length === 3 && parts[2] === 'events') {
      if (!s || !canRead(user, s)) return send(res, 404, { error: 'Shipment not found' });
      return send(res, 200, { items: events.filter((e) => e.shipmentId === id) });
    }

    // PATCH /shipments/:id/status
    if (req.method === 'PATCH' && parts.length === 3 && parts[2] === 'status') {
      if (!s) return send(res, 404, { error: 'Shipment not found' });
      if (user.role === 'courier' && s.courierId !== user.courierId) return send(res, 404, { error: 'Shipment not found' });
      const b = await readBody(req);
      const target = b.status;
      const allowed = TRANSITIONS[target] ? true : null;
      if (allowed === null) throw new Error('Unknown status ' + target);
      if (s.status !== 'Delivered' && !TRANSITIONS[s.status].includes(target)) {
        return send(res, 409, { error: `Cannot move from ${s.status} to ${target}` });
      }
      s.status = target;
      s.updatedAt = now();
      events.push({ shipmentId: s.id, status: target, at: s.updatedAt, by: user.username });
      return send(res, 200, s);
    }

    return send(res, 404, { error: 'Not found' });
  } catch (err) {
    console.error(err.message);
    return send(res, 500, { error: 'Internal server error' });
  }
});

server.listen(PORT, () => console.log(`ParcelPoint sandbox v3.4.0 listening on http://localhost:${PORT}`));
