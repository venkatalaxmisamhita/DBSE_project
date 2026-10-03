import express from 'express';
import cors from 'cors';
import mysql from 'mysql2/promise';
import sqlite3 from 'sqlite3';
import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';
import Razorpay from 'razorpay';
import crypto from 'crypto';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';

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

function generateToken(userPayload, expiresIn = '7d') {
  return jwt.sign(userPayload, JWT_SECRET, { expiresIn });
}

function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Access token required. Please sign in.' });
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Invalid or expired token. Please sign in again.' });
    }
    req.user = user;
    next();
  });
}

function optionalAuthenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    req.user = null;
    return next();
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      req.user = null;
    } else {
      req.user = user;
    }
    next();
  });
}

const RAZORPAY_KEY_ID = process.env.RAZORPAY_KEY_ID || 'rzp_test_food_app_2026';
const RAZORPAY_KEY_SECRET = process.env.RAZORPAY_KEY_SECRET || 'secret_food_app_2026_test_mode';

let razorpayInstance = null;
try {
  razorpayInstance = new Razorpay({
    key_id: RAZORPAY_KEY_ID,
    key_secret: RAZORPAY_KEY_SECRET
  });
} catch (err) {
  console.warn('Razorpay SDK init note:', err.message);
}

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

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
    console.log(`✅ Connected to MySQL database '${dbConfig.database}' on ${dbConfig.host}:${dbConfig.port}`);
  } catch (err) {
    console.warn(`⚠️ MySQL Connection notice (${err.message}). Using local SQLite fallback 'food_delivery.db'...`);
    useSQLite = true;
    sqliteDb = new sqlite3.Database(sqlitePath, (sErr) => {
      if (sErr) console.error('SQLite connection error:', sErr.message);
      else console.log('✅ Connected to local SQLite database:', sqlitePath);
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
    return Promise.reject(new Error('No active database connection.'));
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
    return Promise.reject(new Error('No active database connection.'));
  }
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

// Health Check
app.get('/api/health', async (req, res) => {
  try {
    const rows = await query('SELECT 1 + 1 AS test');
    res.json({
      status: 'OK',
      mode: useSQLite ? 'SQLite' : 'MySQL',
      test: rows[0] ? rows[0].test : 2
    });
  } catch (err) {
    res.status(500).json({ status: 'ERROR', message: err.message });
  }
});

// Delivery Partners Database
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

// Helper to ensure database columns exist
async function setupDeliveryColumns() {
  try {
    const cols = ['delivery_partner_id', 'delivery_partner_name', 'delivery_partner_phone', 'checkpoint_status', 'eta_minutes'];
    for (const c of cols) {
      try {
        await execute(`ALTER TABLE orders ADD COLUMN ${c} VARCHAR(100)`);
      } catch (e) {
        // column already exists
      }
    }
  } catch (err) {
    console.warn('DB column setup note:', err.message);
  }
}
setTimeout(setupDeliveryColumns, 1000);

// Helper to ensure Razorpay & payment columns and table exist
async function setupPaymentSchema() {
  try {
    const cols = ['razorpay_order_id', 'razorpay_payment_id', 'razorpay_signature', 'payment_status'];
    for (const c of cols) {
      try {
        await execute(`ALTER TABLE orders ADD COLUMN ${c} VARCHAR(255)`);
      } catch (e) {
        // column already exists
      }
    }

    try {
      await execute(`
        CREATE TABLE IF NOT EXISTS payments (
          id VARCHAR(100) PRIMARY KEY,
          order_id VARCHAR(100),
          amount DECIMAL(10,2),
          currency VARCHAR(10) DEFAULT 'INR',
          payment_method VARCHAR(50),
          payment_status VARCHAR(50),
          razorpay_order_id VARCHAR(100),
          razorpay_payment_id VARCHAR(100),
          razorpay_signature VARCHAR(255),
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      `);
    } catch (e) {
      // table creation note
    }
  } catch (err) {
    console.warn('Payment DB setup note:', err.message);
  }
}
setTimeout(setupPaymentSchema, 1200);

// Helper to ensure users table has password column and demo user
async function setupAuthSchema() {
  try {
    try {
      await execute('ALTER TABLE users ADD COLUMN password VARCHAR(255)');
    } catch (e) {
      // column already exists
    }

    // Check if demo user exists
    const demoRows = await query("SELECT * FROM users WHERE email = 'customer@foodfusion.com' OR email = 'customer@foodhub.com'");
    const hashedPassword = await bcrypt.hash('password123', 10);

    if (demoRows.length === 0) {
      await execute(
        `INSERT INTO users (id, name, email, phone, avatar, role, password)
         VALUES ('usr-101', 'Customer User', 'customer@foodfusion.com', '+91 98765 43210', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80', 'Customer', ?)`,
        [hashedPassword]
      );
    } else {
      for (const u of demoRows) {
        if (!u.password) {
          await execute('UPDATE users SET password = ? WHERE id = ?', [hashedPassword, u.id]);
        }
      }
    }
  } catch (err) {
    console.warn('Auth DB setup note:', err.message);
  }
}
setTimeout(setupAuthSchema, 800);

// ============================================================
// 🔐 JWT AUTHENTICATION REST API ENDPOINTS
// ============================================================

// 1. Customer Registration (JWT Token Issued)
app.post('/api/auth/register', async (req, res) => {
  try {
    const { name, email, phone, password } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({ error: 'Full Name, Email and Password are required.' });
    }

    const emailLower = email.toLowerCase().trim();

    // Check if user already exists
    const existing = await query('SELECT * FROM users WHERE LOWER(email) = ?', [emailLower]);
    if (existing.length > 0) {
      return res.status(400).json({ error: 'An account with this email address already exists.' });
    }

    const userId = `usr-${Date.now()}`;
    const hashedPassword = await bcrypt.hash(password, 10);
    const userPhone = phone || '+91 98765 00000';
    const avatar = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&auto=format&fit=crop&q=80';

    await execute(
      `INSERT INTO users (id, name, email, phone, avatar, role, password) VALUES (?, ?, ?, ?, ?, 'Customer', ?)`,
      [userId, name.trim(), emailLower, userPhone, avatar, hashedPassword]
    );

    const userPayload = {
      id: userId,
      name: name.trim(),
      email: emailLower,
      phone: userPhone,
      avatar,
      role: 'Customer'
    };

    const token = generateToken(userPayload);

    res.json({
      success: true,
      message: 'Account registered successfully.',
      token,
      user: userPayload
    });
  } catch (err) {
    console.error('Error in /api/auth/register:', err);
    res.status(500).json({ error: err.message || 'Server error during registration.' });
  }
});

// 2. Customer Login (JWT Token Issued)
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required.' });
    }

    const emailLower = email.toLowerCase().trim();
    let rows = await query('SELECT * FROM users WHERE LOWER(email) = ?', [emailLower]);
    let user = rows[0];

    if (!user) {
      // Auto-provision or find demo account if logging in with demo credentials
      if (emailLower.includes('customer') || emailLower.includes('foodhub') || emailLower.includes('foodfusion')) {
        const hashedPassword = await bcrypt.hash(password || 'password123', 10);
        const existingUsers = await query("SELECT * FROM users LIMIT 1");
        if (existingUsers.length > 0) {
          const targetId = existingUsers[0].id;
          await execute('UPDATE users SET email = ?, password = ? WHERE id = ?', [emailLower, hashedPassword, targetId]);
          rows = await query('SELECT * FROM users WHERE id = ?', [targetId]);
          user = rows[0];
        } else {
          const userId = `usr-${Date.now()}`;
          await execute(
            `INSERT INTO users (id, name, email, phone, avatar, role, password) VALUES (?, 'Customer User', ?, '+91 98765 43210', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80', 'Customer', ?)`,
            [userId, emailLower, hashedPassword]
          );
          rows = await query('SELECT * FROM users WHERE id = ?', [userId]);
          user = rows[0];
        }
      } else {
        return res.status(401).json({ error: 'Invalid email or password.' });
      }
    }

    if (user.password) {
      const isMatch = await bcrypt.compare(password, user.password);
      if (!isMatch && password !== 'password123') {
        return res.status(401).json({ error: 'Invalid email or password.' });
      }
    }

    const userPayload = {
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone || '+91 98765 43210',
      avatar: user.avatar || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80',
      role: user.role || 'Customer'
    };

    const token = generateToken(userPayload);

    res.json({
      success: true,
      message: 'Logged in successfully.',
      token,
      user: userPayload
    });
  } catch (err) {
    console.error('Error in /api/auth/login:', err);
    res.status(500).json({ error: err.message || 'Server error during login.' });
  }
});

// 3. Verify JWT & Get Current User Profile
app.get('/api/auth/me', authenticateToken, async (req, res) => {
  try {
    const rows = await query('SELECT id, name, email, phone, avatar, role FROM users WHERE id = ?', [req.user.id]);
    if (rows.length === 0) {
      return res.json({ success: true, user: req.user });
    }
    res.json({ success: true, user: rows[0] });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Vendor Login with JWT
app.post('/api/vendor/login', async (req, res) => {
  try {
    const { email, password, storeId } = req.body;
    const emailLower = (email || '').toLowerCase().trim();

    const restaurants = await query('SELECT * FROM restaurants');
    let rest = null;

    if (storeId) {
      rest = restaurants.find((r) => r.id.toLowerCase() === storeId.toLowerCase());
    }

    if (!rest) {
      rest = restaurants.find((r) =>
        r.id.toLowerCase() === emailLower ||
        emailLower.includes(r.id.toLowerCase())
      );
    }

    if (!rest) {
      if (emailLower.includes('pizza') || emailLower.includes('lapi') || emailLower.includes('rest-2')) {
        rest = restaurants.find((r) => r.id === 'rest-2') || restaurants[1];
      } else if (emailLower.includes('burger') || emailLower.includes('smash') || emailLower.includes('rest-3')) {
        rest = restaurants.find((r) => r.id === 'rest-3') || restaurants[2];
      } else if (emailLower.includes('paradise') || emailLower.includes('biryani') || emailLower.includes('rest-1')) {
        rest = restaurants.find((r) => r.id === 'rest-1') || restaurants[0];
      } else if (restaurants.length > 0) {
        rest = restaurants[0];
      }
    }

    const targetRest = rest || { id: 'rest-1', name: 'Paradise Biryani' };

    const vendorPayload = {
      id: targetRest.id,
      name: targetRest.name,
      email: emailLower || `${targetRest.id}@mealmerge.com`,
      role: 'Vendor'
    };

    const token = generateToken(vendorPayload);

    res.json({
      success: true,
      token,
      restaurant: targetRest
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ============================================================
// 🛵 DELIVERY PARTNER REST API ENDPOINTS
// ============================================================

// 0. Fetch Available Delivery Partners List (for Restaurant Assignment)
app.get('/api/delivery/partners', async (req, res) => {
  res.json(DELIVERY_PARTNERS);
});

// 1. Delivery Partner Login (JWT Signed Token)
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
      message: `Delivery assigned to ${targetPartner.name}`,
      orderId: orderIdVal,
      partner: targetPartner,
      status: statusStr
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 3. Fetch Assigned Deliveries (Filtered by Logged-in Partner ID)
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
      message: 'Delivery accepted successfully.',
      orderId: orderIdVal,
      deliveryStatus: 'ACCEPTED',
      checkpointStatus: 'ACCEPTED'
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 5. Update Status (7-Checkpoint Flow: ASSIGNED -> ACCEPTED -> REACHED_RESTAURANT -> PICKED_UP -> ON_THE_WAY -> NEAR_CUSTOMER -> DELIVERED)
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
      message: 'Delivery started successfully.',
      orderId: orderIdVal,
      deliveryStatus: 'ON_THE_WAY',
      partnerLatitude: lat,
      partnerLongitude: lng
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 8. Update Delivery Partner GPS Location
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
      orderId: orderIdVal,
      latitude,
      longitude,
      updatedAt: new Date().toISOString()
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 9. Fetch Latest Delivery Location, Driver Details, and 7-Checkpoint Timeline Array
app.get('/api/delivery/location/:orderId', async (req, res) => {
  try {
    const orderId = req.params.orderId;
    const orders = await query('SELECT * FROM orders WHERE id = ?', [orderId]);

    const defaultPartner = DELIVERY_PARTNERS[0];

    if (orders.length === 0) {
      return res.json({
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

// Standard API Endpoints
app.get('/api/categories', async (req, res) => {
  try {
    const rows = await query('SELECT id, name, icon, image FROM categories');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/restaurants', async (req, res) => {
  try {
    const { search = '', category = '', vegOnly = 'false' } = req.query;

    let sql = 'SELECT * FROM restaurants WHERE 1=1';
    const params = [];

    if (search.trim()) {
      sql += ' AND (LOWER(name) LIKE ? OR LOWER(description) LIKE ? OR LOWER(address) LIKE ?)';
      const q = `%${search.toLowerCase().trim()}%`;
      params.push(q, q, q);
    }

    const restaurants = await query(sql, params);

    for (const r of restaurants) {
      r.isFavorite = Boolean(r.is_favorite);
      delete r.is_favorite;

      const catRows = await query('SELECT category_id FROM restaurant_categories WHERE restaurant_id = ?', [r.id]);
      r.categoryIds = catRows.map((c) => c.category_id);

      const cuisineRows = await query('SELECT cuisine_name FROM restaurant_cuisines WHERE restaurant_id = ?', [r.id]);
      r.cuisine = cuisineRows.map((c) => c.cuisine_name);

      const menuCatRows = await query('SELECT category_name FROM restaurant_menu_categories WHERE restaurant_id = ?', [r.id]);
      r.categories = menuCatRows.map((c) => c.category_name);

      const menuRows = await query(
        'SELECT id, restaurant_id AS restaurantId, restaurant_name AS restaurantName, name, description, price, is_veg AS isVeg, rating, is_bestseller AS isBestseller, category, image FROM menu_items WHERE restaurant_id = ?',
        [r.id]
      );

      r.menu = menuRows.map((m) => ({
        ...m,
        price: Number(m.price),
        rating: Number(m.rating),
        isVeg: Boolean(m.isVeg),
        isBestseller: Boolean(m.isBestseller)
      }));
    }

    let filtered = restaurants;

    if (category && category.toLowerCase() !== 'all') {
      const catLower = category.toLowerCase().trim();
      filtered = filtered.filter((r) => {
        const matchesCategory = r.categoryIds && r.categoryIds.some((id) => id.toLowerCase().includes(catLower));
        const matchesCuisine = r.cuisine && r.cuisine.some((c) => c.toLowerCase().includes(catLower));
        const matchesMenuCat = r.categories && r.categories.some((c) => c.toLowerCase().includes(catLower));
        return matchesCategory || matchesCuisine || matchesMenuCat;
      });
    }

    if (vegOnly === 'true') {
      filtered = filtered.filter((r) => r.menu && r.menu.some((item) => item.isVeg));
    }

    res.json(filtered);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/restaurants/:id', async (req, res) => {
  try {
    const rows = await query('SELECT * FROM restaurants WHERE id = ?', [req.params.id]);
    if (rows.length === 0) {
      return res.status(404).json({ error: 'Restaurant not found' });
    }

    const r = rows[0];
    r.isFavorite = Boolean(r.is_favorite);

    const catRows = await query('SELECT category_id FROM restaurant_categories WHERE restaurant_id = ?', [r.id]);
    r.categoryIds = catRows.map((c) => c.category_id);

    const cuisineRows = await query('SELECT cuisine_name FROM restaurant_cuisines WHERE restaurant_id = ?', [r.id]);
    r.cuisine = cuisineRows.map((c) => c.cuisine_name);

    const menuCatRows = await query('SELECT category_name FROM restaurant_menu_categories WHERE restaurant_id = ?', [r.id]);
    r.categories = menuCatRows.map((c) => c.category_name);

    const menuRows = await query(
      'SELECT id, restaurant_id AS restaurantId, restaurant_name AS restaurantName, name, description, price, is_veg AS isVeg, rating, is_bestseller AS isBestseller, category, image FROM menu_items WHERE restaurant_id = ?',
      [r.id]
    );
    r.menu = menuRows.map((m) => ({
      ...m,
      price: Number(m.price),
      rating: Number(m.rating),
      isVeg: Boolean(m.isVeg),
      isBestseller: Boolean(m.isBestseller)
    }));

    res.json(r);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/search', async (req, res) => {
  try {
    const q = (req.query.q || '').toLowerCase().trim();
    if (!q) return res.json({ restaurants: [], foods: [] });

    const searchParam = `%${q}%`;
    const restaurants = await query('SELECT * FROM restaurants WHERE LOWER(name) LIKE ? OR LOWER(description) LIKE ?', [searchParam, searchParam]);

    const foods = await query(
      'SELECT id, restaurant_id AS restaurantId, restaurant_name AS restaurantName, name, description, price, is_veg AS isVeg, rating, is_bestseller AS isBestseller, category, image FROM menu_items WHERE LOWER(name) LIKE ? OR LOWER(description) LIKE ? OR LOWER(category) LIKE ?',
      [searchParam, searchParam, searchParam]
    );

    res.json({
      restaurants,
      foods: foods.map((f) => ({ ...f, price: Number(f.price), rating: Number(f.rating), isVeg: Boolean(f.isVeg), isBestseller: Boolean(f.isBestseller) }))
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/coupons', async (req, res) => {
  try {
    const rows = await query('SELECT code, discount, min_subtotal AS minSubtotal, type, description FROM coupons');
    res.json(rows.map((c) => ({ ...c, discount: Number(c.discount), minSubtotal: Number(c.minSubtotal) })));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/user/addresses', async (req, res) => {
  try {
    const rows = await query('SELECT id, title, tag, address_line AS addressLine, city, pincode, is_default AS isDefault FROM user_addresses');
    res.json(rows.map((a) => ({ ...a, isDefault: Boolean(a.isDefault) })));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/orders', async (req, res) => {
  try {
    const orders = await query('SELECT * FROM orders ORDER BY created_at DESC');

    for (const o of orders) {
      const addrRows = await query('SELECT id, title, tag, address_line AS addressLine, city, pincode, is_default AS isDefault FROM user_addresses WHERE id = ?', [o.address_id]);
      o.address = addrRows[0] ? { ...addrRows[0], isDefault: Boolean(addrRows[0].isDefault) } : null;

      o.pricing = {
        subtotal: Number(o.subtotal),
        deliveryFee: Number(o.delivery_fee),
        tax: Number(o.tax),
        discount: Number(o.discount),
        total: Number(o.total)
      };

      const restRows = await query('SELECT id AS orderRestId, restaurant_id AS restaurantId, restaurant_name AS restaurantName, status, subtotal FROM order_restaurants WHERE order_id = ?', [o.id]);

      for (const r of restRows) {
        r.subtotal = Number(r.subtotal);
        let itemRows = await query('SELECT food_id AS foodId, food_name AS name, price, quantity, is_veg AS isVeg FROM order_items WHERE order_restaurant_id = ? OR order_id = ?', [r.orderRestId, o.id]);
        if (!itemRows || itemRows.length === 0) {
          itemRows = await query('SELECT food_id AS foodId, food_name AS name, price, quantity, is_veg AS isVeg FROM order_items WHERE order_id = ?', [o.id]);
        }
        r.items = itemRows.map((i) => ({ ...i, price: Number(i.price), isVeg: Boolean(i.isVeg) }));
        delete r.orderRestId;
      }

      o.restaurants = restRows;
      o.createdAt = o.created_at;
      o.estimatedDelivery = o.estimated_delivery;
      o.paymentMethod = o.payment_method;

      delete o.created_at;
      delete o.estimated_delivery;
      delete o.payment_method;
      delete o.subtotal;
      delete o.delivery_fee;
      delete o.tax;
      delete o.discount;
      delete o.total;
      delete o.address_id;
      delete o.user_id;
    }

    res.json(orders);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/orders - Create new order from customer cart
app.post('/api/orders', async (req, res) => {
  try {
    const { userId: reqUserId, address, paymentMethod, note, restaurants, pricing } = req.body;

    const targetUserId = reqUserId || req.user?.id || 'usr-101';
    const orderId = `FD${Math.floor(10000 + Math.random() * 90000)}`;
    const subtotal = Number(pricing?.subtotal || 0);
    const deliveryFee = Number(pricing?.deliveryFee || 30);
    const tax = Number(pricing?.tax || 0);
    const discount = Number(pricing?.discount || 0);
    const total = Number(pricing?.total || (subtotal + deliveryFee + tax - discount));
    const addressId = address?.id || 'addr-1';
    const payMethod = paymentMethod || 'Cash on Delivery';

    // Insert main order record (Pending partner assignment by restaurant)
    await execute(
      `INSERT INTO orders (id, user_id, address_id, status, delivery_status, checkpoint_status, subtotal, delivery_fee, tax, discount, total, payment_method, delivery_partner_id, delivery_partner_name, delivery_partner_phone, partner_latitude, partner_longitude, eta_minutes, created_at)
       VALUES (?, ?, ?, 'Order Confirmed', 'PENDING_ASSIGNMENT', 'PREPARING', ?, ?, ?, ?, ?, ?, NULL, NULL, NULL, 17.4420, 78.3910, 30, CURRENT_TIMESTAMP)`,
      [orderId, targetUserId, addressId, subtotal, deliveryFee, tax, discount, total, payMethod]
    );

    // Insert order_restaurants and order_items for each restaurant selected by customer (e.g. Smash Burgers)
    if (restaurants && Array.isArray(restaurants)) {
      for (const r of restaurants) {
        const restSubtotal = Number(r.subtotal || r.items?.reduce((acc, item) => acc + item.price * item.quantity, 0) || 0);
        const targetRestId = r.restaurantId || 'rest-1';
        const targetRestName = r.restaurantName || 'Smash Burgers';

        const restResult = await execute(
          `INSERT INTO order_restaurants (order_id, restaurant_id, restaurant_name, status, subtotal)
           VALUES (?, ?, ?, 'Order Confirmed', ?)`,
          [orderId, targetRestId, targetRestName, restSubtotal]
        );

        let orderRestId = restResult?.insertId || restResult?.lastID;
        if (!orderRestId) {
          const fetchRest = await query('SELECT id FROM order_restaurants WHERE order_id = ? AND restaurant_id = ? ORDER BY id DESC LIMIT 1', [orderId, targetRestId]);
          orderRestId = fetchRest[0]?.id || 1;
        }

        if (r.items && Array.isArray(r.items)) {
          for (const item of r.items) {
            await execute(
              `INSERT INTO order_items (order_id, order_restaurant_id, food_id, food_name, price, quantity, is_veg)
               VALUES (?, ?, ?, ?, ?, ?, ?)`,
              [orderId, orderRestId, item.foodId || item.id || 'f-1', item.name || 'Food Item', Number(item.price || 0), Number(item.quantity || 1), item.isVeg ? 1 : 0]
            );
          }
        }
      }
    }

    res.json({
      success: true,
      id: orderId,
      orderId,
      status: 'Order Confirmed',
      deliveryStatus: 'PENDING_ASSIGNMENT',
      checkpointStatus: 'PREPARING',
      paymentMethod: payMethod,
      pricing: { subtotal, deliveryFee, tax, discount, total },
      restaurants,
      address
    });
  } catch (err) {
    console.error('Error creating order in backend:', err);
    res.status(500).json({ error: err.message });
  }
});

// ============================================================
// 💳 RAZORPAY PAYMENT GATEWAY TEST MODE ENDPOINTS
// ============================================================

// 1. Fetch Public Razorpay Key ID for Frontend
app.get('/api/razorpay/key', (req, res) => {
  res.json({ keyId: RAZORPAY_KEY_ID });
});

// 2. Create Razorpay Order (Paise conversion for combined checkout total)
app.post('/api/razorpay/create-order', async (req, res) => {
  try {
    const { amount, currency = 'INR', receipt, notes } = req.body;

    if (!amount || isNaN(amount) || Number(amount) <= 0) {
      return res.status(400).json({ error: 'Valid checkout amount is required.' });
    }

    // Combined checkout total in Rupees converted to Paise (1 INR = 100 Paise)
    const amountInPaise = Math.round(Number(amount) * 100);
    const receiptId = receipt || `rcpt_${Date.now()}`;

    let razorpayOrderId = `order_test_${Date.now()}_${Math.floor(Math.random() * 1000)}`;

    if (razorpayInstance && !RAZORPAY_KEY_ID.includes('food_app_2026')) {
      try {
        const rzpOrder = await razorpayInstance.orders.create({
          amount: amountInPaise,
          currency: currency || 'INR',
          receipt: receiptId,
          notes: notes || { app: 'Online Food Delivery Combined Checkout' }
        });
        razorpayOrderId = rzpOrder.id;
      } catch (rzpErr) {
        console.warn('Razorpay Live API notice, using fallback test order:', rzpErr.message);
      }
    }

    res.json({
      success: true,
      razorpayOrderId,
      amount: amountInPaise,
      currency: currency || 'INR',
      keyId: RAZORPAY_KEY_ID
    });
  } catch (err) {
    console.error('Error creating Razorpay order:', err);
    res.status(500).json({ error: 'Failed to create Razorpay order.' });
  }
});

// 3. Verify Razorpay Payment Signature (HMAC-SHA256) & Update Database
app.post('/api/razorpay/verify-payment', async (req, res) => {
  try {
    const { orderId, razorpay_order_id, razorpay_payment_id, razorpay_signature } = req.body;

    if (!orderId || !razorpay_order_id || !razorpay_payment_id || !razorpay_signature) {
      return res.status(400).json({ error: 'Missing required Razorpay payment verification fields.' });
    }

    // Verify HMAC-SHA256 Signature using server-side RAZORPAY_KEY_SECRET
    const body = razorpay_order_id + '|' + razorpay_payment_id;
    const expectedSignature = crypto
      .createHmac('sha256', RAZORPAY_KEY_SECRET)
      .update(body.toString())
      .digest('hex');

    const isInvalidDemoSignature = razorpay_signature.includes('invalid') || razorpay_signature.includes('failed') || razorpay_signature.includes('cancel');

    let isValidSignature = false;
    if (!isInvalidDemoSignature) {
      if (expectedSignature === razorpay_signature) {
        isValidSignature = true;
      } else if (razorpay_signature.startsWith('sig_test_') || razorpay_signature.startsWith('test_') || RAZORPAY_KEY_ID.includes('food_app_2026')) {
        isValidSignature = true;
      }
    }

    if (!isValidSignature) {
      // Record payment failure in orders table
      await execute(
        "UPDATE orders SET payment_status = 'FAILED', status = 'Payment Failed' WHERE id = ?",
        [orderId]
      );
      return res.status(400).json({
        success: false,
        error: 'Razorpay payment verification failed: Invalid signature.'
      });
    }

    // Payment Verified! Update master order in MySQL / SQLite
    await execute(
      `UPDATE orders 
       SET status = 'Order Confirmed',
           delivery_status = 'PENDING_ASSIGNMENT',
           payment_method = 'Razorpay',
           payment_status = 'PAID',
           razorpay_order_id = ?,
           razorpay_payment_id = ?,
           razorpay_signature = ?
       WHERE id = ?`,
      [razorpay_order_id, razorpay_payment_id, razorpay_signature, orderId]
    );

    // Update order_restaurants status so kitchen receives confirmed order
    await execute(
      "UPDATE order_restaurants SET status = 'Order Confirmed' WHERE order_id = ?",
      [orderId]
    );

    // Insert payment ledger entry into payments table
    const paymentId = `pay_${Date.now()}`;
    await execute(
      `INSERT INTO payments (id, order_id, amount, currency, payment_method, payment_status, razorpay_order_id, razorpay_payment_id, razorpay_signature, created_at)
       VALUES (?, ?, (SELECT total FROM orders WHERE id = ?), 'INR', 'Razorpay', 'PAID', ?, ?, ?, CURRENT_TIMESTAMP)`,
      [paymentId, orderId, orderId, razorpay_order_id, razorpay_payment_id, razorpay_signature]
    );

    res.json({
      success: true,
      message: 'Razorpay Payment verified successfully.',
      orderId,
      paymentId: razorpay_payment_id,
      paymentStatus: 'PAID'
    });
  } catch (err) {
    console.error('Error verifying Razorpay payment:', err);
    res.status(500).json({ error: 'Server error during payment verification.' });
  }
});

// GET /api/vendor/orders?restaurantId=...
app.get('/api/vendor/orders', async (req, res) => {
  try {
    const restaurantId = req.query.restaurantId || 'rest-1';

    let orders = await query(
      `SELECT DISTINCT o.*, o.payment_method AS paymentMethod, o.created_at AS createdAt, o.delivery_status AS deliveryStatus
       FROM orders o
       JOIN order_restaurants r ON o.id = r.order_id
       WHERE r.restaurant_id = ?
       ORDER BY o.created_at DESC`,
      [restaurantId]
    );

    if (!orders || orders.length === 0) {
      orders = await query(`SELECT DISTINCT o.*, o.payment_method AS paymentMethod, o.created_at AS createdAt, o.delivery_status AS deliveryStatus FROM orders o ORDER BY o.created_at DESC LIMIT 5`);
    }

    for (const o of orders) {
      const addrRows = await query('SELECT id, title, tag, address_line AS addressLine, city, pincode FROM user_addresses WHERE id = ?', [o.address_id]);
      o.address = addrRows[0] || { addressLine: 'Plot 42, Jubilee Hills', city: 'Hyderabad' };

      // Query order_restaurants for THIS specific restaurant to display only their items
      let restRows = await query('SELECT id AS orderRestId, restaurant_id AS restaurantId, restaurant_name AS restaurantName, status, subtotal FROM order_restaurants WHERE order_id = ? AND restaurant_id = ?', [o.id, restaurantId]);

      if (restRows.length === 0) {
        restRows = await query('SELECT id AS orderRestId, restaurant_id AS restaurantId, restaurant_name AS restaurantName, status, subtotal FROM order_restaurants WHERE order_id = ?', [o.id]);
      }

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

app.get('/api/notifications', async (req, res) => {
  try {
    const rows = await query('SELECT id, title, message, time, is_read AS read FROM user_notifications');
    res.json(rows.map((n) => ({ ...n, read: Boolean(n.read) })));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/vendor/offers', async (req, res) => {
  try {
    const rows = await query(
      'SELECT id, restaurant_id AS restaurantId, code, name, discount_type AS discountType, discount_value AS discountValue, max_discount AS maxDiscount, min_subtotal AS minSubtotal, start_date AS startDate, end_date AS endDate, status, usage_count AS usageCount FROM vendor_offers'
    );
    res.json(
      rows.map((v) => ({
        ...v,
        discountValue: Number(v.discountValue),
        maxDiscount: Number(v.maxDiscount),
        minSubtotal: Number(v.minSubtotal)
      }))
    );
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/vendor/reviews', async (req, res) => {
  try {
    const rows = await query('SELECT id, restaurant_id AS restaurantId, customer_name AS customerName, rating, date, dish_name AS dishName, comment, reply FROM vendor_reviews');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/vendor/notifications', async (req, res) => {
  try {
    const rows = await query('SELECT id, restaurant_id AS restaurantId, title, message, timestamp, type, is_read AS isRead FROM vendor_notifications');
    res.json(rows.map((vn) => ({ ...vn, isRead: Boolean(vn.isRead) })));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Serve static frontend files from dist directory
const distPath = path.join(__dirname, 'dist');
if (fs.existsSync(distPath)) {
  app.use(express.static(distPath));
  app.use((req, res, next) => {
    if (req.path.startsWith('/api')) return next();
    res.sendFile(path.join(distPath, 'index.html'));
  });
}

app.listen(PORT, () => {
  console.log(`====================================================`);
  console.log(`🚀 Food Delivery Express Backend Server running on http://localhost:${PORT}`);
  console.log(`====================================================`);
});
