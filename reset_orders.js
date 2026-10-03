import sqlite3 from 'sqlite3';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const dbPath = path.join(__dirname, 'food_delivery.db');

const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error('Error opening db:', err);
    process.exit(1);
  }
});

db.run(
  `UPDATE orders SET delivery_partner_id = NULL, delivery_partner_name = NULL, delivery_partner_phone = NULL, delivery_status = 'PENDING_ASSIGNMENT', checkpoint_status = 'PREPARING' WHERE id != 'FD79665' AND (status = 'Order Confirmed' OR status = 'Preparing' OR delivery_status = 'ASSIGNED')`,
  function (err) {
    if (err) console.error('Error resetting orders:', err);
    else console.log(`Successfully reset ${this.changes} existing orders to PENDING_ASSIGNMENT in SQLite database.`);
    db.close();
  }
);
