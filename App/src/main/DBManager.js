import Database from 'better-sqlite3';

const path = require('path');
const fs = require('fs');

/**
 * Robuster Database Manager für die Electron App
 * Erstellt automatisch Verzeichnisse und Datenbank wenn sie nicht existieren
 * Behandelt fehlende better-sqlite3 Dependency graceful
 */

// Lade die .env-Datei
require('dotenv').config({ path: path.join(__dirname, '../../.env') });

// Hole den Datenbanknamen aus der ENV-Variable oder verwende einen Fallback
const dbName = process.env.DB_NAME || 'bde.sqlite';

// Versuche better-sqlite3 zu laden

let databaseAvailable = false;
let bindingError = null;

try {
  // Zuerst prüfen, ob das Modul überhaupt verfügbar ist
  const moduleCheck = require.resolve('better-sqlite3');
  console.info('better-sqlite3 Modul gefunden:', moduleCheck);

  // Dann versuchen zu laden

  databaseAvailable = true;
  console.info('✓ better-sqlite3 erfolgreich geladen');
} catch (err) {
  bindingError = err;
  databaseAvailable = false;

  if (err.message.includes('binding') || err.message.includes('.node')) {
    console.warn('⚠ better-sqlite3 Binding-Fehler:', err.message);
    console.warn('Dies ist ein bekanntes Problem in Electron-Apps');
    console.warn('Lösungsvorschläge:');
    console.warn('  1. npm run rebuild ausführen');
    console.warn('  2. electron-rebuild --force --module better-sqlite3');
    console.warn('  3. App im Production-Build testen');
  } else if (err.code === 'MODULE_NOT_FOUND') {
    console.warn('⚠ better-sqlite3 nicht installiert:', err.message);
    console.warn('Installiere mit: npm install better-sqlite3');
  } else {
    console.warn('⚠ better-sqlite3 Ladefehler:', err.message);
  }

  console.warn(
    'Die Anwendung läuft im Mock-Modus ohne echte Datenbankfunktionalität',
  );
}

/**
 * Ermittelt den korrekten Datenbankpfad basierend auf der Umgebung
 */
function getDatabasePath() {
  let dbPath;

  // Überprüfe ob es ein ARM-System ist (Raspberry Pi)
  const isArmSystem =
    process.arch === 'arm' ||
    process.arch === 'arm64' ||
    process.env.RASPBERRY_PI === 'true';

  if (process.env.NODE_ENV === 'development') {
    // Development: Relative zum Projektverzeichnis
    dbPath = path.resolve(__dirname, '../../public/database/', dbName);
  } else if (isArmSystem) {
    // Raspberry Pi Production: Verwende User-Home oder /tmp für beschreibbare Bereiche
    const os = require('os');
    const homeDir = os.homedir();

    // Versuche verschiedene Pfade in der Reihenfolge der Priorität
    const possiblePaths = [
      path.join(homeDir, '.mthbdeiotclient', 'database', dbName), // ~/.mthbdeiotclient/database/
      path.join('/var/lib/mthbdeiotclient', 'database', dbName), // System-wide data
      path.join('/tmp/mthbdeiotclient', 'database', dbName), // Temporary fallback
      path.join(homeDir, 'mthbdeiotclient-data', 'database', dbName), // Alternative home
    ];

    // Teste welcher Pfad beschreibbar ist
    for (const testPath of possiblePaths) {
      try {
        const testDir = path.dirname(testPath);

        // Erstelle Verzeichnis wenn nicht vorhanden
        if (!fs.existsSync(testDir)) {
          fs.mkdirSync(testDir, { recursive: true });
        }

        // Teste Schreibberechtigung
        const testFile = path.join(testDir, '.write-test');
        fs.writeFileSync(testFile, 'test');
        fs.unlinkSync(testFile);

        dbPath = testPath;
        console.info(
          '🍓 Raspberry Pi: Beschreibbarer Datenbankpfad gefunden:',
          dbPath,
        );
        break;
      } catch (err) {
        console.warn(
          '🍓 Raspberry Pi: Pfad nicht beschreibbar:',
          testPath,
          err.message,
        );
        continue;
      }
    }

    // Falls kein Pfad funktioniert, verwende /tmp als letzten Ausweg
    if (!dbPath) {
      dbPath = path.join('/tmp', dbName);
      console.warn(
        '🍓 Raspberry Pi: Verwende /tmp als Fallback-Datenbankpfad:',
        dbPath,
      );
    }
  } else {
    // Standard Production: Relative zu den App-Ressourcen
    dbPath = path.join(process.resourcesPath, 'public/database/', dbName);
  }

  console.info('Ermittelter Database path:', dbPath);
  return dbPath;
}

/**
 * Erstellt das Datenbankverzeichnis rekursiv wenn es nicht existiert
 */
function ensureDatabaseDirectory(dbPath) {
  const dbDir = path.dirname(dbPath);
  const absoluteDbDir = path.resolve(dbDir);

  console.info('Überprüfe Datenbankverzeichnis:', absoluteDbDir);

  try {
    if (!fs.existsSync(absoluteDbDir)) {
      console.info('Datenbankverzeichnis existiert nicht, erstelle es...');
      fs.mkdirSync(absoluteDbDir, { recursive: true });
      console.info('Datenbankverzeichnis erfolgreich erstellt:', absoluteDbDir);
    } else {
      console.info('Datenbankverzeichnis existiert bereits:', absoluteDbDir);
    }

    // Verifikation der Verzeichniserstellung
    if (!fs.existsSync(absoluteDbDir)) {
      throw new Error('Datenbankverzeichnis konnte nicht erstellt werden');
    }

    // Überprüfe Schreibberechtigung
    const testFile = path.join(absoluteDbDir, '.write-test');
    try {
      fs.writeFileSync(testFile, 'test');
      fs.unlinkSync(testFile);
      console.info('Schreibberechtigung für Datenbankverzeichnis bestätigt');
    } catch (writeErr) {
      throw new Error(
        `Keine Schreibberechtigung für Datenbankverzeichnis: ${writeErr.message}`,
      );
    }
  } catch (err) {
    console.error('Fehler beim Erstellen des Datenbankverzeichnisses:', err);

    // Raspberry Pi spezifische Hilfe
    const isArmSystem =
      process.arch === 'arm' ||
      process.arch === 'arm64' ||
      process.env.RASPBERRY_PI === 'true';

    if (isArmSystem) {
      console.error('🍓 RASPBERRY PI DATENBANK-FEHLER:');
      console.error('   Pfad:', absoluteDbDir);
      console.error('   Fehler:', err.message);
      console.error('');
      console.error('🔧 LÖSUNGSVORSCHLÄGE:');
      console.error('   1. Erstelle Verzeichnis manuell:');
      console.error(`      mkdir -p ${absoluteDbDir}`);
      console.error(`      chmod 755 ${absoluteDbDir}`);
      console.error('   2. Überprüfe verfügbaren Speicherplatz: df -h');
      console.error('   3. Überprüfe Read-Only Filesystem: mount | grep ro');
      console.error(
        '   4. Verwende alternatives Verzeichnis: ~/.mthbdeiotclient/database',
      );
      console.error('   5. Setze Umgebungsvariable: export RASPBERRY_PI=true');
      console.error('');
      console.error('📋 Weitere Hilfe: Führe troubleshoot-raspberry-db.sh aus');
    }

    throw new Error(
      `Datenbankverzeichnis konnte nicht erstellt werden: ${err.message}`,
    );
  }
}

/**
 * Erstellt und konfiguriert die Datenbankverbindung
 */
function createDatabaseConnection(dbPath) {
  if (!databaseAvailable) {
    console.warn('Database nicht verfügbar, erstelle Mock-Objekt');
    return createMockDatabase();
  }

  const absoluteDbPath = path.resolve(dbPath);
  console.info('Versuche Datenbankverbindung zu erstellen:', absoluteDbPath);

  let db;
  try {
    // Öffne die Datenbank (wird automatisch erstellt wenn sie nicht existiert)
    db = new Database(absoluteDbPath);
    console.info('Datenbank erfolgreich geöffnet/erstellt:', absoluteDbPath);

    // Teste die Datenbankverbindung
    const testQuery = db.prepare('SELECT 1 as test');
    const result = testQuery.get();
    if (result && result.test === 1) {
      console.info('Datenbankverbindung erfolgreich getestet');
    } else {
      throw new Error('Datenbankverbindungstest fehlgeschlagen');
    }
  } catch (err) {
    console.error(
      'Fehler beim Öffnen/Erstellen der Datenbank:',
      absoluteDbPath,
      err,
    );
    throw new Error(
      `Datenbank konnte nicht geöffnet/erstellt werden: ${err.message}`,
    );
  }

  return db;
}

/**
 * Erstellt ein Mock-Database-Objekt für Tests ohne better-sqlite3
 */
function createMockDatabase() {
  console.warn('Erstelle Mock-Database für Entwicklung ohne better-sqlite3');

  const mockData = new Map();

  return {
    prepare: (sql) => ({
      run: (...args) => {
        console.log('Mock DB Run:', sql, args);
        return { changes: 1, lastInsertRowid: 1 };
      },
      get: (...args) => {
        console.log('Mock DB Get:', sql, args);
        if (sql.includes('SELECT 1 as test')) {
          return { test: 1 };
        }
        if (sql.includes('sqlite_master')) {
          return { name: 'config' };
        }
        if (sql.includes('config') && args[0]) {
          return { value: mockData.get(args[0]) || 'mock_value' };
        }
        return null;
      },
      all: (...args) => {
        console.log('Mock DB All:', sql, args);
        return [{ name: 'config' }];
      },
    }),
    pragma: (setting) => {
      console.log('Mock DB Pragma:', setting);
      if (setting.includes('journal_mode')) {
        return { journal_mode: 'wal' };
      }
      return {};
    },
    close: () => {
      console.log('Mock DB Close');
    },
  };
}

/**
 * Erstellt die erforderlichen Tabellen in der Datenbank
 */
function createRequiredTables(db) {
  console.info('Erstelle erforderliche Datenbanktabellen...');

  const tables = [
    {
      name: 'config',
      sql: 'CREATE TABLE IF NOT EXISTS config (key TEXT PRIMARY KEY, value TEXT NOT NULL)',
    },
    // Hier können weitere Tabellen hinzugefügt werden
  ];

  tables.forEach((table) => {
    try {
      console.info(`Erstelle Tabelle: ${table.name}`);
      db.prepare(table.sql).run();
      console.info(`Tabelle ${table.name} erfolgreich erstellt/überprüft`);

      // Verifikation der Tabellenerstellung
      const tableExists = db
        .prepare("SELECT name FROM sqlite_master WHERE type='table' AND name=?")
        .get(table.name);

      if (!tableExists) {
        throw new Error(`Tabelle ${table.name} konnte nicht erstellt werden`);
      }
    } catch (err) {
      console.error(`Fehler beim Erstellen der Tabelle ${table.name}:`, err);
      throw new Error(
        `Tabelle ${table.name} konnte nicht erstellt werden: ${err.message}`,
      );
    }
  });
} /**
 * Konfiguriert die Datenbankeinstellungen
 */
function configureDatabaseSettings(db) {
  console.info('Konfiguriere Datenbankeinstellungen...');

  try {
    // WAL-Modus für bessere Concurrent-Performance
    db.pragma('journal_mode = WAL');
    console.info('WAL-Modus aktiviert');

    // Weitere Optimierungen
    db.pragma('synchronous = NORMAL');
    db.pragma('cache_size = 1000');
    db.pragma('temp_store = memory');

    console.info('Datenbankeinstellungen erfolgreich konfiguriert');
  } catch (err) {
    console.error('Fehler beim Konfigurieren der Datenbankeinstellungen:', err);
    // Nicht kritisch, App kann trotzdem funktionieren
    console.warn(
      'Datenbankeinstellungen konnten nicht vollständig konfiguriert werden, fahre trotzdem fort',
    );
  }
}

/**
 * Hauptfunktion zur Initialisierung der Datenbank
 */
function initializeDatabase() {
  console.info('=== Starte Datenbankinitialisierung ===');

  try {
    // 1. Datenbankpfad ermitteln
    const dbPath = getDatabasePath();

    // 2. Verzeichnis erstellen
    ensureDatabaseDirectory(dbPath);

    // 3. Datenbankverbindung erstellen
    const db = createDatabaseConnection(dbPath);

    // 4. Tabellen erstellen
    createRequiredTables(db);

    // 5. Datenbankeinstellungen konfigurieren
    configureDatabaseSettings(db);

    console.info('=== Datenbankinitialisierung erfolgreich abgeschlossen ===');
    return db;
  } catch (err) {
    console.error('=== Kritischer Fehler bei der Datenbankinitialisierung ===');
    console.error('Fehlerdetails:', err);
    throw new Error(`Datenbankinitialisierung fehlgeschlagen: ${err.message}`);
  }
}

// Initialisiere die Datenbank
let db;
try {
  db = initializeDatabase();
} catch (err) {
  console.error('Anwendung kann nicht gestartet werden:', err.message);
  throw err;
}

module.exports = { db };
