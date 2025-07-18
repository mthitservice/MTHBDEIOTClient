const path = require('path');
const Database = require('better-sqlite3');
const fs = require('fs');
const { app } = require('electron');

// Verwende das User Data Directory für die Datenbank
const getUserDataPath = () => {
  try {
    return app.getPath('userData');
  } catch (err) {
    // Fallback für Fälle, wo app nicht verfügbar ist
    return process.env.HOME || process.env.USERPROFILE || __dirname;
  }
};

const dbPath =
  process.env.NODE_ENV === 'development'
    ? path.join(__dirname, '../../public/database/bde.sqlite')
    : path.join(getUserDataPath(), 'database', 'bde.sqlite');

console.info('Database path:', dbPath);

// Stelle sicher, dass das Database-Verzeichnis existiert
const dbDir = path.dirname(dbPath);
if (!fs.existsSync(dbDir)) {
  fs.mkdirSync(dbDir, { recursive: true });
  console.info('Created database directory:', dbDir);
}

// Prüfe ob Datenbank existiert, wenn nicht erstelle eine leere
if (!fs.existsSync(dbPath)) {
  console.info('Database file does not exist, creating new one:', dbPath);
  // Erstelle eine leere Datei
  fs.writeFileSync(dbPath, '');
}

try {
  console.info('Database file exists:', dbPath);
} catch (err) {
  console.error('Database file does not exist:', dbPath);
  throw new Error('Database file not found: ' + err.message);
}

let db;
try {
  // Attempt to open the database
  db = new Database(dbPath);
  console.info('Database opened successfully:', dbPath);
} catch (err) {
  console.error('Failed to open database:', dbPath, err);
  throw new Error('Failed to open database: ' + err.message);
}

try {
  db.prepare(
    'CREATE TABLE IF NOT EXISTS config (key TEXT PRIMARY KEY, value TEXT NOT NULL)',
  ).run();
  console.info('Config table created/verified successfully');
} catch (err) {
  console.error('Failed to create Config Table:', err);
  throw new Error('Failed to create Config Table: ' + err.message);
}
// Konfigurationstabelle

db.pragma('journal_mode = WAL');

module.exports = { db };
