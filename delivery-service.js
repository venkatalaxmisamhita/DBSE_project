import express from 'express';
import cors from 'cors';
import mysql from 'mysql2/promise';
import sqlite3 from 'sqlite3';
import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';
import jwt from 'jsonwebtoken';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const envPath = path.join(__dirname, '.env');
if (fs.existsSync(envPath)) {
  const envConfig = fs.readFileSync(envPath, 'utf8');
  envConfig.split('\n').forEach((line) => {
    const match = line.match(/^\s*([\w.-]+)\s*=\s*(.*)?\s*$/);
    if (match) {
      const key = match[1];
      let value = match[2] || '';
      if (value.length > 0 && value.charAt(0) === '"' && value.charAt(value.length - 1) === '"') {
        value = value.replace(/\\n/gm, '\n');
      }
      process.env[key] = value.replace(/(^['"]|['"]$)/g, '').trim();
    }
  });
}

const JWT_SECRET = process.env.JWT_SECRET || 'food_delivery_jwt_secret_key_2026_super_secure';
const PORT = process.env.DELIVERY_PORT || 5001;

const app = express();
app.use(cors());
app.use(express.json());

// Database Configuration
const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD !== undefined ? process.env.DB_PASSWORD : '',
  database: process.env.DB_NAME || 'food_delivery',
  port: parseInt(process.env.DB_PORT || '3306', 10),
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
};

let pool = null;
let useSQLite = false;
let sqliteDb = null;

const sqlitePath = path.join(__dirname, 'food_delivery.db');

async function initDB() {
  try {
    const testPool = mysql.createPool(dbConfig);
    const conn = await testPool.getConnection();
    await conn.query('SELECT 1');
    conn.release();
    pool = testPool;
    console.log(`✅ [Delivery Microservice] Connected to MySQL database '${dbConfig.database}' on port ${dbConfig.port}`);
  } catch (err) {
    console.warn(`⚠️ [Delivery Microservice] MySQL notice (${err.message}). Using local SQLite fallback 'food_delivery.db'...`);
    useSQLite = true;
    sqliteDb = new sqlite3.Database(sqlitePath, (sErr) => {
      if (sErr) console.error('[Delivery Microservice] SQLite error:', sErr.message);
      else console.log('✅ [Delivery Microservice] Connected to local SQLite database:', sqlitePath);
    });
  }
}

function query(sql, params = []) {
  if (!useSQLite && pool) {
    return pool.query(sql, params).then(([rows]) => rows);
  } else if (useSQLite && sqliteDb) {
    return new Promise((resolve, reject) => {
      sqliteDb.all(sql, params, (err, rows) => {
        if (err) reject(err);
        else resolve(rows || []);
      });
    });
  } else {
    return Promise.reject(new Error('No active database connection in Delivery Microservice.'));
  }
}

function execute(sql, params = []) {
  if (!useSQLite && pool) {
    return pool.query(sql, params).then(([result]) => result);
  } else if (useSQLite && sqliteDb) {
    return new Promise((resolve, reject) => {
      sqliteDb.run(sql, params, function (err) {
        if (err) reject(err);
        else resolve({ affectedRows: this.changes });
      });
    });
  } else {
    return Promise.reject(new Error('No active database connection in Delivery Microservice.'));
  }
}

function generateToken(userPayload, expiresIn = '7d') {
  return jwt.sign(userPayload, JWT_SECRET, { expiresIn });
}

function calcKm(lat1, lon1, lat2, lon2) {
  const R = 6371;
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLon = ((lon2 - lon1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos((lat1 * Math.PI) / 180) * Math.cos((lat2 * Math.PI) / 180) * Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return Math.round(R * c * 10) / 10;
}

initDB();

// Delivery Partners Master List
const DELIVERY_PARTNERS = [
  {
    id: 'driver-101',
    name: 'Ramesh Kumar',
    email: 'ramesh@foodfusion.com',
    phone: '+91 98765 11223',
    vehicleType: 'Motorcycle (Hero Splendor Pro)',
    vehicleNumber: 'TS 09 EQ 4821',
    rating: 4.9,
    status: 'Available',
    currentLocation: 'Jubilee Hills, Road No. 36',
    latitude: 17.4420,
    longitude: 78.3910
  },
  {
    id: 'driver-102',
    name: 'Suresh Verma',
    email: 'suresh@foodfusion.com',
    phone: '+91 98765 22334',
    vehicleType: 'Scooter (Honda Activa 6G)',
    vehicleNumber: 'TS 07 EV 8912',
    rating: 4.8,
    status: 'Available',
    currentLocation: 'Madhapur, Hitech City',
    latitude: 17.4480,
    longitude: 78.3850
  },
  {
    id: 'driver-103',
    name: 'Arjun Reddy',
    email: 'arjun@foodfusion.com',
    phone: '+91 98765 33445',
    vehicleType: 'Scooter (TVS Jupiter 125)',
    vehicleNumber: 'TS 08 EA 5678',
    rating: 4.9,
    status: 'Available',
    currentLocation: 'Gachibowli Financial District',
    latitude: 17.4400,
    longitude: 78.3480
  },
  {
    id: 'driver-104',
    name: 'Ravi Teja',
    email: 'ravi@foodfusion.com',
    phone: '+91 98765 44556',
    vehicleType: 'Motorcycle (Bajaj Pulsar 150)',
    vehicleNumber: 'TS 09 EX 1234',
    rating: 4.7,
    status: 'Available',
    currentLocation: 'Banjara Hills, Road No. 12',
    latitude: 17.4150,
    longitude: 78.4340
  },
  {
    id: 'driver-105',
    name: 'Mahesh Babu',
    email: 'mahesh@foodfusion.com',
    phone: '+91 98765 55667',
    vehicleType: 'Motorcycle (Royal Enfield Classic 350)',
    vehicleNumber: 'TS 10 EZ 9999',
    rating: 4.9,
    status: 'Available',
    currentLocation: 'Kondapur Main Road',
    latitude: 17.4620,
    longitude: 78.3660
  }
];

// Health Check Endpoint
app.get('/api/health', async (req, res) => {
  res.json({
    status: 'OK',
    service: 'Live GPS & Delivery Tracking Microservice',
    port: PORT,
    dbMode: useSQLite ? 'SQLite' : 'MySQL',
    timestamp: new Date().toISOString()
  });
});

// 0. Fetch Available Delivery Partners List
app.get('/api/delivery/partners', async (req, res) => {
  res.json(DELIVERY_PARTNERS);
});

// 1. Delivery Partner Login (Issues Signed JWT Token)
app.post('/api/delivery/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required.' });
    }

    const emailLower = email.toLowerCase().trim();
    let partnerProfile = DELIVERY_PARTNERS.find((p) => p.email.toLowerCase() === emailLower || p.name.toLowerCase().includes(emailLower));

    if (!partnerProfile) {
      partnerProfile = DELIVERY_PARTNERS[0];
    }

    const token = generateToken({
      id: partnerProfile.id,
      name: partnerProfile.name,
      email: partnerProfile.email,
      role: 'DeliveryPartner'
    });

    res.json({
      success: true,
      token,
      partner: partnerProfile
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 2. Restaurant Assigns Delivery Partner to Order
app.post('/api/restaurant/assign-partner', async (req, res) => {
  try {
    const { orderId, partnerId } = req.body;
    const orderIdVal = orderId || 'FD10245';
    const targetPartner = DELIVERY_PARTNERS.find((p) => p.id === partnerId) || DELIVERY_PARTNERS[0];

    const statusStr = `${targetPartner.name} Assigned`;

    await execute(
      "UPDATE orders SET delivery_partner_id = ?, delivery_partner_name = ?, delivery_partner_phone = ?, delivery_status = 'ASSIGNED', checkpoint_status = 'ASSIGNED', status = ?, location_updated_at = CURRENT_TIMESTAMP WHERE id = ?",
      [targetPartner.id, targetPartner.name, targetPartner.phone, statusStr, orderIdVal]
    );

    await execute(
      'UPDATE order_restaurants SET status = ? WHERE order_id = ?',
      [statusStr, orderIdVal]
    );

    res.json({
      success: true,
      message: `Delivery assigned to ${targetPartner.name} via Delivery Microservice`,
      orderId: orderIdVal,
      partner: targetPartner,
      status: statusStr
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 3. Fetch Assigned Deliveries
app.get('/api/delivery/assigned', async (req, res) => {
  try {
    const partnerId = req.query.partnerId || 'driver-101';
    let orders = await query(
      "SELECT * FROM orders WHERE (delivery_partner_id = ? OR delivery_partner_id IS NULL) AND delivery_status IN ('ASSIGNED', 'ACCEPTED', 'REACHED_RESTAURANT', 'PICKED_UP', 'ON_THE_WAY', 'NEAR_CUSTOMER') ORDER BY created_at DESC",
      [partnerId]
    );

    if (!orders || orders.length === 0) {
      orders = await query("SELECT * FROM orders WHERE delivery_status IN ('ASSIGNED', 'ACCEPTED', 'REACHED_RESTAURANT', 'PICKED_UP', 'ON_THE_WAY', 'NEAR_CUSTOMER') ORDER BY created_at DESC");
    }

    for (const o of orders) {
      const addrRows = await query('SELECT id, title, tag, address_line AS addressLine, city, pincode, latitude, longitude FROM user_addresses WHERE id = ?', [o.address_id]);
      o.address = addrRows[0] || { title: 'Home Address', addressLine: 'Plot 42, Road No. 36, Jubilee Hills', city: 'Hyderabad', pincode: '500033', latitude: 17.4486, longitude: 78.3808 };

      const restRows = await query('SELECT id AS orderRestId, restaurant_id AS restaurantId, restaurant_name AS restaurantName, status, subtotal FROM order_restaurants WHERE order_id = ?', [o.id]);

      for (const r of restRows) {
        const itemRows = await query('SELECT food_name AS name, price, quantity, is_veg AS isVeg FROM order_items WHERE order_restaurant_id = ?', [r.orderRestId]);
        r.items = itemRows;
      }
      o.restaurants = restRows;
    }

    res.json(orders);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 4. Accept Assigned Delivery
app.post('/api/delivery/accept', async (req, res) => {
  try {
    const { orderId, partnerId } = req.body;
    const orderIdVal = orderId || 'FD10245';

    await execute(
      "UPDATE orders SET delivery_status = 'ACCEPTED', checkpoint_status = 'ACCEPTED', status = 'Delivery Accepted', location_updated_at = CURRENT_TIMESTAMP WHERE id = ?",
      [orderIdVal]
    );

    await execute(
      "UPDATE order_restaurants SET status = 'Delivery Accepted' WHERE order_id = ?",
      [orderIdVal]
    );

    res.json({
      success: true,
      message: 'Delivery accepted via Delivery Microservice.',
      orderId: orderIdVal,
      deliveryStatus: 'ACCEPTED',
      checkpointStatus: 'ACCEPTED'
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 5. Update Status (7 Checkpoints Flow)
app.post('/api/delivery/status', async (req, res) => {
  try {
    const { orderId, deliveryStatus, etaMinutes } = req.body;
    const orderIdVal = orderId || 'FD10245';

    let orderStatusStr = 'Out for Delivery';
    let defaultEta = etaMinutes || 15;

    if (deliveryStatus === 'ASSIGNED') { orderStatusStr = 'Delivery Assigned'; defaultEta = 25; }
    if (deliveryStatus === 'ACCEPTED') { orderStatusStr = 'Delivery Accepted'; defaultEta = 20; }
    if (deliveryStatus === 'REACHED_RESTAURANT') { orderStatusStr = 'Driver Reached Restaurant'; defaultEta = 18; }
    if (deliveryStatus === 'PICKED_UP') { orderStatusStr = 'Food Picked Up'; defaultEta = 15; }
    if (deliveryStatus === 'ON_THE_WAY' || deliveryStatus === 'OUT_FOR_DELIVERY') { orderStatusStr = 'On the Way'; defaultEta = 10; }
    if (deliveryStatus === 'NEAR_CUSTOMER') { orderStatusStr = 'Near Customer (5 Mins Away)'; defaultEta = 5; }
    if (deliveryStatus === 'DELIVERED') { orderStatusStr = 'Delivered'; defaultEta = 0; }

    await execute(
      'UPDATE orders SET delivery_status = ?, checkpoint_status = ?, status = ?, eta_minutes = ?, location_updated_at = CURRENT_TIMESTAMP WHERE id = ?',
      [deliveryStatus, deliveryStatus, orderStatusStr, defaultEta, orderIdVal]
    );

    await execute(
      'UPDATE order_restaurants SET status = ? WHERE order_id = ?',
      [orderStatusStr, orderIdVal]
    );

    res.json({
      success: true,
      microservice: 'Delivery & GPS Service (Port 5001)',
      orderId: orderIdVal,
      deliveryStatus,
      checkpointStatus: deliveryStatus,
      status: orderStatusStr,
      etaMinutes: defaultEta
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 6. Delivery History
app.get('/api/delivery/history', async (req, res) => {
  try {
    const orders = await query("SELECT * FROM orders WHERE delivery_status = 'DELIVERED' OR status = 'Delivered' ORDER BY created_at DESC");

    for (const o of orders) {
      const restRows = await query('SELECT restaurant_name AS restaurantName FROM order_restaurants WHERE order_id = ?', [o.id]);
      o.restaurantName = restRows.map(r => r.restaurantName).join(', ') || 'Paradise Biryani';
    }

    res.json(orders);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 7. Start Delivery Location Transmit
app.post('/api/delivery/start', async (req, res) => {
  try {
    const { orderId, latitude, longitude } = req.body;
    const orderIdVal = orderId || 'FD10245';
    const lat = latitude || 17.4420;
    const lng = longitude || 78.3910;

    await execute(
      "UPDATE orders SET delivery_status = 'ON_THE_WAY', checkpoint_status = 'ON_THE_WAY', status = 'On the Way', partner_latitude = ?, partner_longitude = ?, eta_minutes = 10, location_updated_at = CURRENT_TIMESTAMP WHERE id = ?",
      [lat, lng, orderIdVal]
    );

    res.json({
      success: true,
      message: 'Delivery started via Delivery Microservice.',
      orderId: orderIdVal,
      deliveryStatus: 'ON_THE_WAY',
      partnerLatitude: lat,
      partnerLongitude: lng
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 8. Update Delivery Partner Live GPS Location
app.post('/api/delivery/location', async (req, res) => {
  try {
    const { orderId, latitude, longitude } = req.body;
    const orderIdVal = orderId || 'FD10245';

    if (!latitude || !longitude) {
      return res.status(400).json({ error: 'Latitude and Longitude are required.' });
    }

    await execute(
      'UPDATE orders SET partner_latitude = ?, partner_longitude = ?, location_updated_at = CURRENT_TIMESTAMP WHERE id = ?',
      [latitude, longitude, orderIdVal]
    );

    res.json({
      success: true,
      service: 'Delivery Microservice (Port 5001)',
      orderId: orderIdVal,
      latitude,
      longitude,
      updatedAt: new Date().toISOString()
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 9. Fetch Live Delivery Location, Driver Details, and 7-Checkpoint Timeline Array
app.get('/api/delivery/location/:orderId', async (req, res) => {
  try {
    const orderId = req.params.orderId;
    const orders = await query('SELECT * FROM orders WHERE id = ?', [orderId]);

    const defaultPartner = DELIVERY_PARTNERS[0];

    if (orders.length === 0) {
      return res.json({
        service: 'Delivery Microservice (Port 5001)',
        orderId,
        status: 'On the Way',
        deliveryStatus: 'ON_THE_WAY',
        checkpointStatus: 'ON_THE_WAY',
        partnerName: defaultPartner.name,
        partnerPhone: defaultPartner.phone,
        partnerLatitude: 17.4420,
        partnerLongitude: 78.3910,
        locationUpdatedAt: new Date().toISOString(),
        customerCoords: { lat: 17.4486, lng: 78.3808 },
        restaurantCoords: { lat: 17.4399, lng: 78.3989 },
        distanceKm: 1.8,
        etaMinutes: 10,
        timeline: [
          { key: 'CONFIRMED', label: 'Order Confirmed', isDone: true },
          { key: 'PREPARING', label: 'Restaurant Preparing', isDone: true },
          { key: 'ASSIGNED', label: `${defaultPartner.name} Assigned`, isDone: true },
          { key: 'PICKED_UP', label: 'Food Picked Up', isDone: true },
          { key: 'ON_THE_WAY', label: 'On the Way', isDone: true, isCurrent: true },
          { key: 'NEAR_CUSTOMER', label: '5 Minutes Away', isDone: false },
          { key: 'DELIVERED', label: 'Delivered', isDone: false }
        ]
      });
    }

    const o = orders[0];
    const hasPartner = Boolean(o.delivery_partner_name && o.delivery_partner_name.trim());
    const partnerName = hasPartner ? o.delivery_partner_name : null;
    const partnerPhone = hasPartner ? o.delivery_partner_phone : null;
    const deliveryStatus = o.delivery_status || (hasPartner ? 'ASSIGNED' : 'PENDING_ASSIGNMENT');
    const checkpointStatus = o.checkpoint_status || deliveryStatus;

    const partnerLat = Number(o.partner_latitude || 17.4420);
    const partnerLng = Number(o.partner_longitude || 78.3910);
    const custLat = 17.4486;
    const custLng = 78.3808;
    const restLat = 17.4399;
    const restLng = 78.3989;

    const distanceKm = calcKm(partnerLat, partnerLng, custLat, custLng);
    let etaMinutes = Number(o.eta_minutes || Math.max(2, Math.round(distanceKm * 4)));
    if (deliveryStatus === 'DELIVERED') etaMinutes = 0;
    if (deliveryStatus === 'NEAR_CUSTOMER') etaMinutes = 5;

    // Build 7 Checkpoints Timeline
    const assignedLabel = hasPartner ? `${partnerName} Assigned` : 'Delivery Partner to be assigned';
    const checkpoints = [
      { key: 'CONFIRMED', label: 'Order Confirmed' },
      { key: 'PREPARING', label: 'Restaurant Preparing' },
      { key: 'ASSIGNED', label: assignedLabel },
      { key: 'PICKED_UP', label: 'Food Picked Up' },
      { key: 'ON_THE_WAY', label: 'On the Way' },
      { key: 'NEAR_CUSTOMER', label: '5 Minutes Away' },
      { key: 'DELIVERED', label: 'Delivered' }
    ];

    let activeIdx = 1; // Default to step 2 'Restaurant Preparing' when partner pending
    if (hasPartner) {
      const currentIdx = checkpoints.findIndex(c => c.key === checkpointStatus || c.key === deliveryStatus);
      activeIdx = currentIdx >= 0 ? currentIdx : 2;
    }

    const timeline = checkpoints.map((c, idx) => ({
      ...c,
      isDone: idx <= activeIdx,
      isCurrent: idx === activeIdx
    }));

    res.json({
      service: 'Delivery Microservice (Port 5001)',
      orderId: o.id,
      status: o.status,
      deliveryStatus,
      checkpointStatus,
      partnerName,
      partnerPhone,
      partnerLatitude: partnerLat,
      partnerLongitude: partnerLng,
      locationUpdatedAt: o.location_updated_at || new Date().toISOString(),
      customerCoords: { lat: custLat, lng: custLng },
      restaurantCoords: { lat: restLat, lng: restLng },
      distanceKm,
      etaMinutes,
      timeline
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 10. Complete Delivery
app.post('/api/delivery/complete', async (req, res) => {
  try {
    const { orderId } = req.body;
    const orderIdVal = orderId || 'FD10245';

    await execute(
      "UPDATE orders SET delivery_status = 'DELIVERED', checkpoint_status = 'DELIVERED', status = 'Delivered', eta_minutes = 0, location_updated_at = CURRENT_TIMESTAMP WHERE id = ?",
      [orderIdVal]
    );

    await execute(
      "UPDATE order_restaurants SET status = 'Delivered' WHERE order_id = ?",
      [orderIdVal]
    );

    res.json({
      success: true,
      service: 'Delivery Microservice (Port 5001)',
      message: 'Order marked as DELIVERED.',
      orderId: orderIdVal,
      deliveryStatus: 'DELIVERED',
      checkpointStatus: 'DELIVERED'
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 11. Fetch Delivery Status
app.get('/api/delivery/status/:orderId', async (req, res) => {
  try {
    const orderId = req.params.orderId;
    const orders = await query('SELECT id, status, delivery_status, checkpoint_status, delivery_partner_name, delivery_partner_phone, location_updated_at FROM orders WHERE id = ?', [orderId]);

    if (orders.length === 0) {
      return res.json({ orderId, status: 'On the Way', deliveryStatus: 'ON_THE_WAY', partnerName: 'Ramesh Kumar' });
    }

    const o = orders[0];
    res.json({
      service: 'Delivery Microservice (Port 5001)',
      orderId: o.id,
      status: o.status,
      deliveryStatus: o.delivery_status,
      checkpointStatus: o.checkpoint_status,
      partnerName: o.delivery_partner_name || 'Ramesh Kumar',
      partnerPhone: o.delivery_partner_phone || '+91 98765 11223',
      locationUpdatedAt: o.location_updated_at
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`====================================================`);
  console.log(`🛵 Delivery & Live GPS Microservice running on http://localhost:${PORT}`);
  console.log(`====================================================`);
});
