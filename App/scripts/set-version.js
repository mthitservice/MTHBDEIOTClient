const fs = require('fs');
const path = require('path');

// Version aus Environment Variable oder Package.json lesen
const version =
  process.env.APP_VERSION || process.env.npm_package_version || '1.0.0';

console.log(`Setting application version to: ${version}`);

// Package.json aktualisieren
const packagePath = path.join(__dirname, '..', 'package.json');
const packageJson = JSON.parse(fs.readFileSync(packagePath, 'utf8'));
packageJson.version = version;
fs.writeFileSync(packagePath, JSON.stringify(packageJson, null, 2));

// Release/app/package.json aktualisieren (falls vorhanden)
const releasePackagePath = path.join(
  __dirname,
  '..',
  'release',
  'app',
  'package.json',
);
if (fs.existsSync(releasePackagePath)) {
  const releasePackageJson = JSON.parse(
    fs.readFileSync(releasePackagePath, 'utf8'),
  );
  releasePackageJson.version = version;
  fs.writeFileSync(
    releasePackagePath,
    JSON.stringify(releasePackageJson, null, 2),
  );
}

// Environment-Datei für Electron erstellen
const envContent = `NODE_ENV=production
APP_VERSION=${version}
REACT_APP_VERSION=${version}
BUILD_DATE=${new Date().toISOString()}
`;

fs.writeFileSync(path.join(__dirname, '..', '.env.production'), envContent);

console.log('Version successfully updated in all files');
console.log(`Environment variables set for version: ${version}`);
