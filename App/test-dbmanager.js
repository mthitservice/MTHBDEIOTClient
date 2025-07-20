// Test-Script für DBManager
console.log('=== DBManager Test ===');
console.log('Arbeitsverzeichnis:', process.cwd());
console.log('__dirname:', __dirname);
console.log('NODE_ENV:', process.env.NODE_ENV);

try {
  console.log('Lade DBManager...');
  const { db } = require('./src/main/DBManager.js');

  console.log('✓ DBManager erfolgreich geladen');

  // Test: Datenbankverbindung
  console.log('Teste Datenbankverbindung...');
  const result = db.prepare('SELECT 1 as test').get();
  console.log('✓ Datenbankverbindung erfolgreich:', result);

  // Test: Config-Tabelle
  console.log('Teste Config-Tabelle...');
  const tables = db
    .prepare("SELECT name FROM sqlite_master WHERE type='table'")
    .all();
  console.log(
    '✓ Verfügbare Tabellen:',
    tables.map((t) => t.name),
  );

  // Test: Insert/Select in Config-Tabelle
  console.log('Teste Insert/Select...');
  const insertStmt = db.prepare(
    'INSERT OR REPLACE INTO config (key, value) VALUES (?, ?)',
  );
  insertStmt.run('test_key', 'test_value');

  const selectStmt = db.prepare('SELECT value FROM config WHERE key = ?');
  const value = selectStmt.get('test_key');
  console.log('✓ Insert/Select erfolgreich:', value);

  // Test: Datenbankinfo
  console.log('Datenbankinfo:');
  const pragma = db.prepare('PRAGMA journal_mode').get();
  console.log('  Journal Mode:', pragma.journal_mode);

  const dbSize = db
    .prepare(
      'SELECT page_count * page_size as size FROM pragma_page_count(), pragma_page_size()',
    )
    .get();
  console.log('  Größe:', dbSize.size, 'Bytes');

  console.log('=== Alle Tests erfolgreich! ===');
} catch (error) {
  console.error('✗ Fehler beim DBManager Test:', error.message);
  console.error('Stack:', error.stack);
  process.exit(1);
}
