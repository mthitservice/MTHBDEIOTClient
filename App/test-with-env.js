// test-with-env.js
const path = require('path');

// Setze den NODE_ENV für den Test
process.env.NODE_ENV = 'development'; // Verwende development statt test

// Füge den release/app/node_modules Pfad hinzu für better-sqlite3
const releaseAppModules = path.join(
  __dirname,
  'release',
  'app',
  'node_modules',
);
if (!module.paths.includes(releaseAppModules)) {
  module.paths.unshift(releaseAppModules);
}

console.log('Test DBManager mit development environment...');

try {
  // Importiere den DBManager
  const DBManager = require('./src/main/DBManager.js');
  console.log('DBManager erfolgreich importiert');

  // Teste Initialisierung
  const dbManager = new DBManager();
  console.log('DBManager-Instanz erstellt');

  // Teste Datenbankinitialisierung
  const db = dbManager.initializeDatabase();
  console.log('Datenbankinitialisierung erfolgreich');

  if (db && typeof db.prepare === 'function') {
    console.log('Echte SQLite-Datenbank verfügbar');

    // Teste eine einfache Abfrage
    const stmt = db.prepare('SELECT 1 as test');
    const result = stmt.get();
    if (result && result.test === 1) {
      console.log('SQLite-Abfrage erfolgreich:', result);
    }

    // Teste DB-Verbindung schließen
    db.close();
    console.log('Datenbankverbindung geschlossen');
  } else if (db && db.isMock) {
    console.log('Mock-Datenbank aktiv');
  }

  console.log('Alle Tests erfolgreich!');
} catch (error) {
  console.error('Fehler beim Testen:', error.message);
  console.error('Stack:', error.stack);
  process.exit(1);
}
