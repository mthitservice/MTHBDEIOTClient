const dbmgr = require('./DBManager');

const db = dbmgr.db;

const readAllConfig = () => {
  const stmt = db.prepare('SELECT * FROM config');
  return stmt.all();
};

const readConfigByKey = (key) => {
  const stmt = db.prepare('SELECT * FROM config WHERE key = ?');
  return stmt.get(key);
};

const createOrUpdateConfig = (key, value) => {
  const stmt = db.prepare(
    'INSERT INTO config (key, value) VALUES (?, ?) ON CONFLICT(key) DO UPDATE SET value = excluded.value',
  );
  return stmt.run(key, value);
};

const deleteConfigByKey = (key) => {
  const stmt = db.prepare('DELETE FROM config WHERE key = ?');
  return stmt.run(key);
};

module.exports = {
  readAllConfig,
  readConfigByKey,
  createOrUpdateConfig,
  deleteConfigByKey,
};
// This module provides functions to manage configuration settings in the database.
