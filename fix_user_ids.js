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

db.serialize(() => {
  db.run("UPDATE orders SET user_id = 'usr-101' WHERE user_id = 'user-101' OR user_id IS NULL", function (err) {
    if (err) console.error('Error updating orders user_id:', err);
    else console.log('Updated orders user_id count:', this.changes);
  });

  db.run("UPDATE user_addresses SET user_id = 'usr-101' WHERE user_id = 'user-101' OR user_id IS NULL", function (err) {
    if (err) console.error('Error updating user_addresses user_id:', err);
    else console.log('Updated user_addresses user_id count:', this.changes);
  });

  db.run("UPDATE user_notifications SET user_id = 'usr-101' WHERE user_id = 'user-101' OR user_id IS NULL", function (err) {
    if (err) console.error('Error updating user_notifications user_id:', err);
    else console.log('Updated user_notifications user_id count:', this.changes);
  });
});

setTimeout(() => db.close(), 1000);
