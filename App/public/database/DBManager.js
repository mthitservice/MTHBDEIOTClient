const path = require('path');
const Database = require('better-sqlite3');

const dbPath =
  process.env.NODE_ENV === 'development'
    ? path.join(__dirname, '../../public/database/bde.sqlite')
    : path.join(process.resourcesPath, 'public/database/bde.sqlite');

console.info('Database path:', dbPath);
try {
  // Check if the database file exists
  require('fs').accessSync(dbPath);
  console.info('Database file exists:', dbPath);
} catch (err) {
  console.error('Database file does not exist:', dbPath);
  throw new Error('Database file not found: ' + err.message);
}

try {
  // Attempt to open the database
  new Database(dbPath);
  console.info('Database opened successfully:', dbPath);
} catch (err) {
  console.error('Failed to open database:', dbPath, err);
  throw new Error('Failed to open database: ');
}
const db = new Database(dbPath);
console.log('Databasfunctions');
console.log(typeof db); // sollte 'object' sein
console.log(Object.keys(db));

db.pragma('journal_mode = WAL');

module.exports = db;
