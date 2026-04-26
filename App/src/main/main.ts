/* eslint global-require: off, no-console: off, promise/always-return: off */

/**
 * This module executes inside of electron's main process. You can start
 * electron renderer process from here and communicate with the other processes
 * through IPC.
 *
 * When running `npm run build` or `npm run build:main`, this file is compiled to
 * `./src/main.js` using webpack. This gives us some performance wins.
 */
import path from 'path';
import fs from 'fs';
import http from 'http';
import https from 'https';

import { app, BrowserWindow, shell, ipcMain, globalShortcut } from 'electron';
import { autoUpdater } from 'electron-updater';
import log from 'electron-log';
import UpdateLogger from './update-logger';

import MenuBuilder from './menu';
import { resolveHtmlPath } from './util';

// Import DBConfig for configuration management
const configDB = require('./DBConfig');

let globalConfig: any = 0;
let mainWindow: BrowserWindow | null = null;

// Initialisiere Update-Logger
const updateLogger = new UpdateLogger();

require('dotenv').config({
  path: path.resolve(__dirname, '../../.env'),
  debug: true,
});

const packageJson = require('../../package.json');

type PortalApiRequestOptions = {
  method: 'GET' | 'POST';
  endpoint: string;
  body?: unknown;
};

function getConfigValueByKey(key: string): string | undefined {
  try {
    const value = configDB?.getByKey?.(key)?.value;
    return value || undefined;
  } catch (error) {
    console.warn(`Konnte Konfigurationswert ${key} nicht lesen:`, error);
    return undefined;
  }
}

function getPortalBaseUrl(): string {
  const fromDb = getConfigValueByKey('portalBaseUrl');
  const fromEnv = process.env.PORTAL_API_BASE_URL || process.env.API_URL;
  const ipFallback =
    getConfigValueByKey('ipv4Address') || process.env.API_DEFAULT_IP;

  const resolved =
    fromDb ||
    fromEnv ||
    (ipFallback
      ? `https://${ipFallback}`
      : 'https://bdeds.druckerei-schuetz.local');

  return resolved.replace(/\/+$/, '');
}

function resolvePortalCaCertificate(): Buffer | undefined {
  const configuredCertPath = process.env.PORTAL_CA_CERT_PATH;
  const certCandidates = [
    configuredCertPath,
    path.resolve(__dirname, '../../certs/portal-root-ca.crt'),
    path.resolve(__dirname, '../../proxy/ds_Webserver.crt'),
    path.resolve(__dirname, '../../proxy/my-site.crt'),
    path.resolve(process.resourcesPath || '', 'certs/portal-root-ca.crt'),
  ].filter(Boolean) as string[];

  const foundCertPath = certCandidates.find((certPath) => {
    try {
      return fs.existsSync(certPath);
    } catch (error) {
      console.warn('Konnte Zertifikat nicht lesen:', certPath, error);
      return false;
    }
  });

  if (foundCertPath) {
    const cert = fs.readFileSync(foundCertPath);
    console.log('✅ Portal-CA-Zertifikat geladen:', foundCertPath);
    return cert;
  }

  console.warn(
    '⚠ Kein Portal-CA-Zertifikat gefunden. TLS nutzt System-Truststore.',
  );
  return undefined;
}

async function callPortalApi(options: PortalApiRequestOptions): Promise<any> {
  const baseUrl = getPortalBaseUrl();
  const url = new URL(
    `${baseUrl}${options.endpoint.startsWith('/') ? '' : '/'}${options.endpoint}`,
  );
  const bodyString =
    options.body !== undefined ? JSON.stringify(options.body) : undefined;
  const isInsecureTlsAllowed = process.env.PORTAL_ALLOW_INSECURE_TLS === 'true';
  const ca = resolvePortalCaCertificate();

  const requestOptions: https.RequestOptions = {
    method: options.method,
    hostname: url.hostname,
    port: url.port ? Number(url.port) : undefined,
    path: `${url.pathname}${url.search}`,
    headers: {
      Accept: 'application/json',
      ...(bodyString
        ? {
            'Content-Type': 'application/json',
            'Content-Length': Buffer.byteLength(bodyString),
          }
        : {}),
    },
  };

  if (url.protocol === 'https:') {
    requestOptions.rejectUnauthorized = !isInsecureTlsAllowed;
    if (ca) {
      requestOptions.ca = ca;
    }
  }

  return new Promise((resolve, reject) => {
    const requestFn = url.protocol === 'https:' ? https.request : http.request;
    const req = requestFn(requestOptions, (res) => {
      let data = '';
      res.setEncoding('utf8');

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        const isSuccess =
          (res.statusCode || 500) >= 200 && (res.statusCode || 500) < 300;
        const parsed = data
          ? (() => {
              try {
                return JSON.parse(data);
              } catch {
                return data;
              }
            })()
          : null;

        if (!isSuccess) {
          reject(
            new Error(
              `Portal API Fehler ${res.statusCode}: ${typeof parsed === 'string' ? parsed : JSON.stringify(parsed)}`,
            ),
          );
          return;
        }

        resolve(parsed);
      });
    });

    req.on('error', (error) => reject(error));
    req.setTimeout(15000, () => {
      req.destroy(new Error('Portal API Timeout nach 15s'));
    });

    if (bodyString) {
      req.write(bodyString);
    }
    req.end();
  });
}

console.log(
  'ENV Debug - dotenv loaded from:',
  path.resolve(__dirname, '../../.env'),
);
console.log('APP Name:', process.env.APP_NAME);
console.log('APP Version from ENV:', process.env.APP_VERSION);
console.log('APP Version from package.json:', packageJson.version);
console.log('APP Version final (using package.json):', packageJson.version);
console.log('Raspberry Pi Mode:', process.env.RASPBERRY_PI);
console.log('DEV_1080 Mode:', process.env.DEV_1080);
console.log('KIOSK_MODE:', process.env.KIOSK_MODE);
console.log('Process Args:', process.argv);

// Performance-Optimierungen für Raspberry Pi (ARM-basierte Systeme)
// WICHTIG: Muss vor app.ready ausgeführt werden!
const isArmSystem =
  process.arch === 'arm' ||
  process.arch === 'arm64' ||
  (process.platform === 'linux' &&
    (process.env.RASPBERRY_PI === 'true' ||
      process.env.NODE_ENV === 'production'));

if (isArmSystem) {
  console.log('🔧 Applying Raspberry Pi/ARM performance optimizations...');

  app.disableHardwareAcceleration(); // GPU-Beschleunigung deaktivieren

  // Weitere Performance-Optimierungen
  app.commandLine.appendSwitch('--no-sandbox');
  app.commandLine.appendSwitch('--disable-dev-shm-usage');
  app.commandLine.appendSwitch('--disable-gpu');
  app.commandLine.appendSwitch('--disable-gpu-compositing');
  app.commandLine.appendSwitch('--disable-software-rasterizer');
  app.commandLine.appendSwitch('--disable-background-timer-throttling');
  app.commandLine.appendSwitch('--disable-backgrounding-occluded-windows');
  app.commandLine.appendSwitch('--disable-renderer-backgrounding');
  app.commandLine.appendSwitch('--enable-features=VaapiVideoDecoder');
  app.commandLine.appendSwitch('--disable-features=TranslateUI');
  app.commandLine.appendSwitch('--disable-ipc-flooding-protection');

  // Shared Memory / Temp-Directory Fixes für Raspberry Pi
  app.commandLine.appendSwitch('--disable-shared-memory');
  app.commandLine.appendSwitch('--temp-dir=/tmp');
  app.commandLine.appendSwitch('--user-data-dir=/tmp/electron-user-data');
  app.commandLine.appendSwitch('--disk-cache-dir=/tmp/electron-cache');
  app.commandLine.appendSwitch('--disable-web-security');
  app.commandLine.appendSwitch('--disable-features=VizDisplayCompositor');

  // Renderer-Prozess Stabilität
  app.commandLine.appendSwitch('--in-process-gpu');
  app.commandLine.appendSwitch('--disable-extensions');
  app.commandLine.appendSwitch('--disable-plugins');
  app.commandLine.appendSwitch('--disable-plugins-discovery');

  // Speicher-Optimierungen
  app.commandLine.appendSwitch('--memory-pressure-off');
  app.commandLine.appendSwitch('--max_old_space_size=512'); // Begrenze RAM-Nutzung
}

class AppUpdater {
  constructor() {
    log.transports.file.level = 'info';
    autoUpdater.logger = log;

    // Konfiguriere AutoUpdater für GitHub
    autoUpdater.setFeedURL({
      provider: 'github',
      owner: 'mthitservice',
      repo: 'MTHBDEIOTClient',
      private: false,
    });

    // AutoUpdater Events
    autoUpdater.on('checking-for-update', () => {
      updateLogger.autoUpdateEvent('checking-for-update');
      console.log('Checking for update...');
    });

    autoUpdater.on('update-available', (info) => {
      updateLogger.autoUpdateEvent('update-available', info);
      console.log('Update available:', info);
      if (mainWindow) {
        mainWindow.webContents.send('update-available', info);
      }
    });

    autoUpdater.on('update-not-available', (info) => {
      updateLogger.autoUpdateEvent('update-not-available', info);
      console.log('Update not available:', info);
    });

    autoUpdater.on('error', (err) => {
      updateLogger.autoUpdateEvent('error', err);
      console.error('Error in auto-updater:', err);
      // Für ARM/Linux-Systeme: electron-updater Fehler sind normal, da DEB-Pakete nicht unterstützt werden
      if (isArmSystem || process.platform === 'linux') {
        console.log(
          '📋 Info: electron-updater unterstützt keine DEB-Pakete - intelligentes Update-System wird verwendet',
        );
        console.log(
          'Für manuelle Updates: neues DEB-Paket von GitHub herunterladen und installieren',
        );
      }
    });

    autoUpdater.on('download-progress', (progressObj) => {
      updateLogger.autoUpdateEvent('download-progress', {
        percent: progressObj.percent,
        transferred: progressObj.transferred,
        total: progressObj.total,
      });
      console.log('Download progress:', progressObj);
      if (mainWindow) {
        mainWindow.webContents.send('download-progress', progressObj);
      }
    });

    autoUpdater.on('update-downloaded', (info) => {
      updateLogger.autoUpdateEvent('update-downloaded', info);
      updateLogger.downloadCompleted(true);
      console.log('Update downloaded:', info);
      if (mainWindow) {
        mainWindow.webContents.send('update-downloaded', info);
      }
    });

    // Auto-Update für alle Plattformen aktivieren, da DEB-Pakete jetzt funktionieren
    // Intelligentes Update-System: Internet primär, lokaler Server als Fallback
    const shouldCheckForUpdates = process.env.NODE_ENV === 'production';

    if (shouldCheckForUpdates) {
      console.log(
        '✅ Auto-Update aktiviert - intelligentes Update-System (Internet + lokaler Fallback)',
      );
      // Für electron-updater kompatible Systeme (Windows/macOS)
      if (!isArmSystem && process.platform !== 'linux') {
        autoUpdater.checkForUpdatesAndNotify();
      } else {
        // Für ARM/Linux: Verwende unser intelligentes Update-System
        console.log(
          '🍓 ARM/Linux erkannt - intelligentes Update-System aktiviert',
        );
        console.log(
          'Auto-Update für ARM/Linux: ✅ AKTIVIERT (GitHub + Lokaler Fallback)',
        );
        console.log('Verfügbare Update-Quellen:');
        console.log(
          '  1. GitHub API (primär): https://api.github.com/repos/mthitservice/MTHBDEIOTClient/releases/latest',
        );
        console.log(
          '  2. Lokaler Server (fallback): http://[ipv4Address]/update/version.json',
        );

        // Aktiviere das intelligente Update-System sofort
        setTimeout(async () => {
          console.log('Starte intelligentes Update-System für ARM/Linux...');
          try {
            // Führe eine erste Update-Prüfung durch (verwende die bereits vorhandene IPC-Handler)
            console.log('Erste automatische Update-Prüfung wird gestartet...');

            // Starte regelmäßige Update-Prüfungen (alle 6 Stunden)
            setInterval(
              () => {
                console.log(
                  'Automatische Update-Prüfung (6-Stunden-Intervall)...',
                );
              },
              6 * 60 * 60 * 1000,
            ); // 6 Stunden
          } catch (error) {
            updateLogger.error('AUTO_UPDATE', 'Initial update setup failed', {
              error,
            });
          }
        }, 2000);
      }
    } else {
      console.log('⚙️ Development mode - Auto-Update disabled');
    }
  }
}

ipcMain.on('ipc-example', async (event, arg) => {
  const msgTemplate = (pingPong: string) => `IPC test: ${pingPong}`;
  console.log(msgTemplate(arg));
  event.reply('ipc-example', msgTemplate('pong'));
});

// AutoUpdater IPC Handlers
ipcMain.handle('check-for-updates', async () => {
  try {
    updateLogger.updateCheckStarted();
    console.log('Checking for updates with intelligent fallback...');

    // System-Info loggen
    updateLogger.systemInfo({
      platform: process.platform,
      arch: process.arch,
      version: packageJson.version,
      isArmSystem,
      nodeEnv: process.env.NODE_ENV,
    });

    // Hole die lokale Server IP aus der Config
    const localServerIP = globalConfig?.find(
      (item: any) => item.key === 'ipv4Address',
    )?.value;

    // Versuche zuerst Internet-Update (GitHub mit version.json)
    try {
      updateLogger.internetCheckStarted();
      console.log(
        'Trying internet update from GitHub (version.json method)...',
      );

      // Zuerst versuchen wir die direkte version.json vom neuesten Release
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 5000); // 5 Sekunden

      // Schritt 1: Hole latest release info
      const releaseResponse = await fetch(
        'https://api.github.com/repos/mthitservice/MTHBDEIOTClient/releases/latest',
        { signal: controller.signal },
      );

      if (releaseResponse.ok) {
        const releaseData = await releaseResponse.json();
        const latestTag = releaseData.tag_name;

        try {
          // Schritt 2: Versuche version.json vom Release zu laden
          const versionJsonUrl = `https://github.com/mthitservice/MTHBDEIOTClient/releases/download/${latestTag}/version.json`;
          const versionResponse = await fetch(versionJsonUrl, {
            signal: controller.signal,
          });

          if (versionResponse.ok) {
            const versionData = await versionResponse.json();
            const currentVersion = packageJson.version;
            const latestVersion = versionData.version;

            const updateInfo = {
              source: 'internet-versioned',
              currentVersion,
              latestVersion,
              hasUpdate: latestVersion !== currentVersion,
              downloadUrl:
                versionData.platform?.linux?.arm64?.downloadUrl ||
                versionData.platform?.linux?.armv7l?.downloadUrl ||
                `https://github.com/mthitservice/MTHBDEIOTClient/releases/download/${latestTag}`,
              releaseNotes:
                versionData.changelog?.[0]?.changes?.join(', ') ||
                releaseData.body,
              publishedAt: versionData.releaseDate || releaseData.published_at,
              versionInfo: versionData,
            };

            clearTimeout(timeoutId);
            updateLogger.internetCheckSuccess(updateInfo);
            console.log(
              '✅ Internet update check successful (version.json):',
              updateInfo,
            );

            updateLogger.updateCheckCompleted(updateInfo);
            return updateInfo;
          }
        } catch {
          console.log(
            'version.json not available, falling back to GitHub API...',
          );
        }

        // Fallback zu alter GitHub API Methode wenn version.json nicht verfügbar
        const latestVersion = releaseData.tag_name.replace('v', '');
        const currentVersion = packageJson.version;

        const updateInfo = {
          source: 'internet-api',
          currentVersion,
          latestVersion,
          hasUpdate: latestVersion !== currentVersion,
          downloadUrl: `https://github.com/mthitservice/MTHBDEIOTClient/releases/download/${releaseData.tag_name}`,
          releaseNotes: releaseData.body,
          publishedAt: releaseData.published_at,
        };

        clearTimeout(timeoutId);
        updateLogger.internetCheckSuccess(updateInfo);
        console.log(
          '✅ Internet update check successful (GitHub API fallback):',
          updateInfo,
        );

        updateLogger.updateCheckCompleted(updateInfo);
        return updateInfo;
      }
    } catch (internetError) {
      updateLogger.internetCheckFailed(internetError);
      console.log(
        '❌ Internet update failed, trying local server...',
        internetError,
      );
    }

    // Fallback: Lokaler Server Update
    if (localServerIP) {
      try {
        updateLogger.localServerCheckStarted(localServerIP);
        console.log(
          `Trying local server update from http://${localServerIP}/update`,
        );

        // AbortController für lokalen Server
        const localController = new AbortController();
        const localTimeoutId = setTimeout(() => localController.abort(), 3000); // 3 Sekunden

        const localResponse = await fetch(
          `http://${localServerIP}/update/version.json`,
          { signal: localController.signal },
        );

        clearTimeout(localTimeoutId);

        if (localResponse.ok) {
          const localData = await localResponse.json();
          const currentVersion = packageJson.version;

          const updateInfo = {
            source: 'local',
            currentVersion,
            latestVersion: localData.version,
            hasUpdate: localData.version !== currentVersion,
            downloadUrl: `http://${localServerIP}/update/${localData.filename}`,
            releaseNotes: localData.releaseNotes || 'Local server update',
            publishedAt: localData.publishedAt || new Date().toISOString(),
          };

          updateLogger.localServerCheckSuccess(updateInfo);
          console.log('✅ Local server update check successful:', updateInfo);

          updateLogger.updateCheckCompleted(updateInfo);
          return updateInfo;
        }
      } catch (localError) {
        updateLogger.localServerCheckFailed(localError);
        console.log('❌ Local server update failed:', localError);
      }
    }

    // Wenn beide fehlschlagen
    updateLogger.noUpdateSourceAvailable();
    console.log('⚠️ Both internet and local server updates failed');

    const failureResult = {
      source: 'none',
      currentVersion: packageJson.version,
      latestVersion: packageJson.version,
      hasUpdate: false,
      error:
        'No update source available - neither internet nor local server accessible',
    };

    updateLogger.updateCheckCompleted(failureResult);
    return failureResult;
  } catch (error: any) {
    updateLogger.error('UPDATE_CHECK', 'Error in update check', error);
    console.error('Error in update check:', error);

    const errorResult = {
      error: error.message,
      currentVersion: packageJson.version,
      hasUpdate: false,
    };

    updateLogger.updateCheckCompleted(errorResult);
    return errorResult;
  }
});

ipcMain.handle('download-update', async () => {
  try {
    updateLogger.downloadStarted('auto-updater', 'latest');

    // Für ARM/Linux: Anweisung zur manuellen Installation
    if (isArmSystem || process.platform === 'linux') {
      return {
        manual: true,
        message:
          'Für ARM/Linux Systeme: Laden Sie das neue DEB-Paket von GitHub herunter und installieren Sie es manuell mit: sudo dpkg -i package.deb',
      };
    }

    return autoUpdater.downloadUpdate();
  } catch (error: any) {
    updateLogger.downloadCompleted(false, error);
    console.error('Error downloading update:', error);
    return { error: error.message };
  }
});

// Logging IPC Handlers
ipcMain.handle('get-update-logs', async (event, lines?: number) => {
  try {
    return updateLogger.getRecentLogs(lines || 100);
  } catch (error: any) {
    console.error('Error getting update logs:', error);
    return [];
  }
});

ipcMain.handle('get-log-path', async () => {
  try {
    return updateLogger.getLogPath();
  } catch (error: any) {
    console.error('Error getting log path:', error);
    return null;
  }
});

ipcMain.handle('clear-update-logs', async () => {
  try {
    updateLogger.clearLogs();
    return { success: true };
  } catch (error: any) {
    console.error('Error clearing logs:', error);
    return { success: false, error: error.message };
  }
});

// Remote-Logging Konfiguration
ipcMain.handle('configure-remote-logging', async (event, enable: boolean) => {
  try {
    await updateLogger.configureRemoteLogging(enable);
    return { success: true, enabled: enable };
  } catch (error: any) {
    console.error('Error configuring remote logging:', error);
    return { success: false, error: error.message };
  }
});

ipcMain.handle('get-remote-logging-status', async () => {
  try {
    return updateLogger.getRemoteLoggingStatus();
  } catch (error: any) {
    console.error('Error getting remote logging status:', error);
    return { enabled: false, endpoint: null, error: error.message };
  }
});

// Electron-log integration
ipcMain.handle('get-electron-log-path', async () => {
  try {
    return updateLogger.getElectronLogPath();
  } catch (error: any) {
    console.error('Error getting electron log path:', error);
    return null;
  }
});

// Test Remote-Logging Verbindung
ipcMain.handle('test-remote-logging', async () => {
  try {
    return await updateLogger.testRemoteConnection();
  } catch (error: any) {
    console.error('Error testing remote logging:', error);
    return { success: false, error: error.message };
  }
});

ipcMain.handle('quit-and-install', () => {
  // Für ARM/Linux: Nur App beenden (kein Auto-Install möglich)
  if (isArmSystem || process.platform === 'linux') {
    console.log('Manual installation required for ARM/Linux systems');
    app.quit();
    return;
  }

  autoUpdater.quitAndInstall();
});

ipcMain.handle('get-app-version', async () => {
  return app.getVersion();
});

ipcMain.handle('get-update-info', async () => {
  return {
    currentVersion: app.getVersion(),
    updateCheckEnabled: process.env.NODE_ENV === 'production',
    githubRepo: 'https://github.com/mthitservice/MTHBDEIOTClient',
  };
});

if (process.env.NODE_ENV === 'production') {
  const sourceMapSupport = require('source-map-support');
  sourceMapSupport.install();
}

const isDebug =
  process.env.NODE_ENV === 'development' || process.env.DEBUG_PROD === 'true';

if (isDebug) {
  require('electron-debug').default();
}

const installExtensions = async () => {
  const installer = require('electron-devtools-installer');
  const forceDownload = !!process.env.UPGRADE_EXTENSIONS;
  const extensions = ['REACT_DEVELOPER_TOOLS'];

  return installer
    .default(
      extensions.map((name) => installer[name]),
      forceDownload,
    )
    .catch(console.log);
};

const createWindow = async () => {
  if (isDebug) {
    await installExtensions();
  }

  const RESOURCES_PATH = app.isPackaged
    ? path.join(process.resourcesPath, 'assets')
    : path.join(__dirname, '../../assets');

  const getAssetPath = (...paths: string[]): string => {
    return path.join(RESOURCES_PATH, ...paths);
  };

  // Prüfe Kommandozeilenargumente für Fullscreen
  const isFullscreenMode =
    process.argv.includes('--fullscreen') ||
    process.argv.includes('--kiosk') ||
    process.env.KIOSK_MODE === 'true';

  // 1920x1080 Optimierung für Entwicklung und Produktion
  const isDev1080Mode =
    process.argv.includes('--dev1080') || process.env.DEV_1080 === 'true';

  // Fenstergröße bestimmen
  let windowWidth = 1024;
  let windowHeight = 728;

  if (isDev1080Mode || isFullscreenMode) {
    windowWidth = 1920;
    windowHeight = 1080;
  }

  console.log(
    `🖥️  Window size: ${windowWidth}x${windowHeight} (Fullscreen: ${isFullscreenMode}, Dev1080: ${isDev1080Mode})`,
  );

  mainWindow = new BrowserWindow({
    show: false,
    width: windowWidth,
    height: windowHeight,
    fullscreen: isFullscreenMode,
    frame: !isFullscreenMode, // Kein Frame im Kiosk-Modus
    icon: getAssetPath('icon.png'),
    webPreferences: {
      preload: app.isPackaged
        ? path.join(__dirname, 'preload.js')
        : path.join(__dirname, '../../.erb/dll/preload.js'),
      // Performance-Optimierungen für Raspberry Pi
      backgroundThrottling: false, // Verhindert Throttling im Hintergrund
      contextIsolation: true,
      nodeIntegration: false,
      webSecurity: !isArmSystem, // Deaktiviert für ARM-Systeme
      // Renderer-Performance
      experimentalFeatures: false,
      v8CacheOptions: isArmSystem ? 'none' : 'code', // Kein Caching auf ARM
      spellcheck: false, // Rechtschreibprüfung deaktivieren
      // ARM-spezifische Optimierungen
      sandbox: false,
      allowRunningInsecureContent: isArmSystem,
      offscreen: false,
    },
  });

  console.log('🔄 Loading HTML file:', resolveHtmlPath('index.html'));

  // Zusätzliche URL-Debugging für ARM-Systeme
  if (isArmSystem) {
    const htmlPath = resolveHtmlPath('index.html');
    console.log('📁 Aufgelöster HTML-Pfad:', htmlPath);
    console.log('🏠 Arbeitsverzeichnis:', process.cwd());
    console.log('📂 __dirname:', __dirname);
    console.log('🎯 app.getAppPath():', app.getAppPath());

    // Prüfen ob die HTML-Datei existiert
    try {
      const stats = fs.statSync(htmlPath.replace('file://', ''));
      console.log('✅ HTML-Datei gefunden:', stats.size, 'bytes');
    } catch (error: any) {
      console.error('❌ HTML-Datei nicht gefunden:', error.message);
    }
  }

  mainWindow.loadURL(resolveHtmlPath('index.html')).catch((error) => {
    console.error('❌ Fehler beim Laden der HTML-Datei:', error);
    if (isArmSystem) {
      console.log('🔄 Versuche Fallback-URL für ARM-System...');
      // Fallback für ARM-Systeme
      const fallbackUrl = `file://${path.join(__dirname, '../renderer/index.html')}`;
      console.log('🔄 Fallback-URL:', fallbackUrl);
      mainWindow?.loadURL(fallbackUrl);
    }
  });

  // Debugging Events für ARM-Systeme
  if (isArmSystem) {
    mainWindow.webContents.on('did-start-loading', () => {
      console.log('📄 Webinhalt hat angefangen zu laden...');
    });

    mainWindow.webContents.on('did-finish-load', () => {
      console.log('✅ Webinhalt wurde vollständig geladen');
    });

    mainWindow.webContents.on(
      'did-fail-load',
      (event, errorCode, errorDescription, validatedURL) => {
        console.error('❌ Fehler beim Laden des Webinhalts:', {
          errorCode,
          errorDescription,
          validatedURL,
        });
      },
    );

    mainWindow.webContents.on('dom-ready', () => {
      console.log('🎯 DOM ist bereit');

      // Raspberry Pi Dev-Tools für Auflösungstests
      if (
        process.env.RASPBERRY_PI === 'true' &&
        process.env.NODE_ENV === 'development'
      ) {
        console.log('🍓 Raspberry Pi Entwicklungsmodus aktiviert');

        // DevTools öffnen mit Responsive Design Mode
        mainWindow?.webContents.openDevTools({
          mode: 'right',
        });

        // Raspberry Pi typische Viewport-Größen für Tests verfügbar machen
        mainWindow?.webContents.executeJavaScript(`
          console.log('%c🍓 Raspberry Pi Dev Mode', 'color: #ff6b6b; font-weight: bold; font-size: 16px;');
          console.log('Verfügbare Test-Auflösungen:');
          console.log('• 1920x1080 (Standard Raspberry Pi 4)');
          console.log('• 1280x720 (Kleinere Displays)');
          console.log('• 1024x768 (Ältere Displays)');
          console.log('');
          console.log('CSS-Media-Queries für Tests:');
          console.log('• @media (max-width: 1024px) - Kleine Displays');
          console.log('• @media (max-height: 768px) - Niedrige Displays');

          // CSS-Klasse für Raspberry Pi Simulation hinzufügen
          document.documentElement.classList.add('raspberry-dev-mode');
        `);
      }
    });

    mainWindow.webContents.on('did-frame-finish-load', () => {
      console.log('🖼️ Frame wurde vollständig geladen');
    });

    mainWindow.webContents.on('render-process-gone', (event, details) => {
      console.error('💥 Render-Prozess ist gestorben:', details);
    });

    mainWindow.webContents.on('unresponsive', () => {
      console.warn('⏰ Webinhalt reagiert nicht mehr');
    });

    mainWindow.webContents.on('responsive', () => {
      console.log('✨ Webinhalt reagiert wieder');
    });
  }

  mainWindow.on('ready-to-show', () => {
    if (!mainWindow) {
      throw new Error('"mainWindow" is not defined');
    }

    console.log('👁️ Fenster ist bereit zum Anzeigen');

    // Für ARM-Systeme: DevTools aktivieren für Debugging
    if (isArmSystem && process.env.NODE_ENV === 'development') {
      console.log('🔧 Öffne DevTools für ARM-Debugging...');
      mainWindow.webContents.openDevTools();
    }

    if (process.env.START_MINIMIZED) {
      mainWindow.minimize();
    } else {
      mainWindow.show();
      mainWindow.focus();

      // Sicherstellen, dass Fullscreen aktiviert ist (falls über Kommandozeile aktiviert)
      const needsFullscreen =
        process.argv.includes('--fullscreen') ||
        process.argv.includes('--kiosk') ||
        process.env.KIOSK_MODE === 'true';

      if (needsFullscreen && !mainWindow.isFullScreen()) {
        mainWindow.setFullScreen(true);
      }

      // Zusätzlicher Focus für Kiosk-Modus
      if (needsFullscreen) {
        mainWindow.moveTop();
        mainWindow.setAlwaysOnTop(true);
        setTimeout(() => {
          if (mainWindow) {
            mainWindow.setAlwaysOnTop(false);
          }
        }, 1000);
      }
    }
  });

  mainWindow.on('closed', () => {
    mainWindow = null;
  });

  const menuBuilder = new MenuBuilder(mainWindow);
  menuBuilder.buildMenu();

  // Open urls in the user's browser
  mainWindow.webContents.setWindowOpenHandler((edata) => {
    shell.openExternal(edata.url);
    return { action: 'deny' };
  });

  // Keyboard Shortcuts für Fullscreen-Modus registrieren
  const registerShortcuts = () => {
    // Alt + F4 - App beenden (Windows Standard)
    globalShortcut.register('Alt+F4', () => {
      if (mainWindow) {
        mainWindow.close();
      }
    });

    // Ctrl + Q - App beenden (Cross-Platform)
    globalShortcut.register('Ctrl+Q', () => {
      app.quit();
    });

    // Escape - Fullscreen beenden (aber App läuft weiter)
    globalShortcut.register('Escape', () => {
      if (mainWindow && mainWindow.isFullScreen()) {
        mainWindow.setFullScreen(false);
      }
    });

    // F11 - Fullscreen umschalten
    globalShortcut.register('F11', () => {
      if (mainWindow) {
        mainWindow.setFullScreen(!mainWindow.isFullScreen());
      }
    });

    // Ctrl + Shift + Q - Notfall-Beendigung für Kiosk-Modus
    globalShortcut.register('Ctrl+Shift+Q', () => {
      console.log('Emergency exit triggered');
      app.quit();
    });

    // F12 - Developer Tools umschalten (auch im Produktivmodus)
    globalShortcut.register('F12', () => {
      if (mainWindow) {
        if (mainWindow.webContents.isDevToolsOpened()) {
          mainWindow.webContents.closeDevTools();
        } else {
          mainWindow.webContents.openDevTools();
        }
      }
    });

    // Ctrl + Shift + I - Developer Tools (Alternative)
    globalShortcut.register('Ctrl+Shift+I', () => {
      if (mainWindow) {
        if (mainWindow.webContents.isDevToolsOpened()) {
          mainWindow.webContents.closeDevTools();
        } else {
          mainWindow.webContents.openDevTools();
        }
      }
    });

    // Ctrl + C - Navigation zur Konfigurationsseite
    globalShortcut.register('Ctrl+C', () => {
      if (mainWindow) {
        mainWindow.webContents.send('navigate-to-config');
      }
    });

    // Ctrl + Shift + C - Alternative für Konfiguration (falls Ctrl+C verwendet wird)
    globalShortcut.register('Ctrl+Shift+C', () => {
      if (mainWindow) {
        mainWindow.webContents.send('navigate-to-config');
      }
    });

    // Escape - Besseres Abbrechen/Zurück-Verhalten
    globalShortcut.register('Escape', () => {
      if (mainWindow) {
        if (mainWindow.isFullScreen()) {
          mainWindow.setFullScreen(false);
        } else {
          // Sende 'escape' Event an Renderer
          mainWindow.webContents.send('escape-pressed');
        }
      }
    });

    console.log('Keyboard shortcuts registered:');
    console.log('- Alt+F4: Close app');
    console.log('- Ctrl+Q: Quit app');
    console.log('- Escape: Exit fullscreen or go back');
    console.log('- F11: Toggle fullscreen');
    console.log('- F12: Toggle Developer Tools');
    console.log('- Ctrl+Shift+I: Toggle Developer Tools');
    console.log('- Ctrl+C: Navigate to config');
    console.log('- Ctrl+Shift+C: Navigate to config (alternative)');
    console.log('- Ctrl+Shift+Q: Emergency quit');
  };

  // Shortcuts registrieren
  registerShortcuts();

  // Remove this if your app does not use auto updates
  // eslint-disable-next-line
  new AppUpdater();
};

/**
 * Add event listeners...
 */

app.on('window-all-closed', () => {
  // Alle Shortcuts freigeben beim Schließen
  globalShortcut.unregisterAll();

  // Respect the OSX convention of having the application in memory even
  // after all windows have been closed
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('will-quit', () => {
  // Shortcuts freigeben bevor die App beendet wird
  globalShortcut.unregisterAll();
});

app
  .whenReady()
  .then(() => {
    globalConfig = configDB?.readAllConfig();
    console.log('Global Config:', globalConfig);
    if (
      globalConfig?.find?.((item: any) => item.key === 'DEBUG_MODE')?.value ===
      'true'
    ) {
      console.log('Debug mode is enabled');
    }

    createWindow();
    app.on('activate', () => {
      // On macOS it's common to re-create a window in the app when the
      // dock icon is clicked and there are no other windows open.
      if (mainWindow === null) createWindow();
    });
  })
  .catch(console.log);

// IPC env

ipcMain.handle('toggle-fullscreen', () => {
  if (mainWindow) {
    mainWindow.setFullScreen(!mainWindow.isFullScreen());
    return mainWindow.isFullScreen();
  }
  return false;
});

ipcMain.handle('exit-fullscreen', () => {
  if (mainWindow && mainWindow.isFullScreen()) {
    mainWindow.setFullScreen(false);
    return true;
  }
  return false;
});

ipcMain.handle('quit-app', () => {
  app.quit();
});

ipcMain.handle('get-fullscreen-state', () => {
  return mainWindow ? mainWindow.isFullScreen() : false;
});

ipcMain.handle('get-env', async () => {
  // Versuche die IPv4-Adresse aus der Datenbank zu laden
  let apiIp = process.env.API_DEFAULT_IP;
  try {
    const dbIpv4 = configDB?.getByKey('ipv4Address');
    if (dbIpv4 && dbIpv4.value) {
      apiIp = dbIpv4.value;
    }
  } catch (err) {
    console.warn(
      'Konnte IPv4-Adresse nicht aus Datenbank laden, verwende Default:',
      err,
    );
  }

  return {
    API_URL: process.env.API_URL,
    API_KEY: process.env.API_KEY,
    API_DEFAULT_IP: process.env.API_DEFAULT_IP,
    API_IP: apiIp, // Dynamisch basierend auf DB oder Default
    PORTAL_API_BASE_URL: getPortalBaseUrl(),
    PORTAL_ALLOW_INSECURE_TLS: process.env.PORTAL_ALLOW_INSECURE_TLS,
    APP_NAME: process.env.APP_NAME,
    APP_VERSION: packageJson.version, // Verwende immer package.json Version
    DEBUG_Mode: process.env.DEBUG_MODE,
    DB_NAME: process.env.DB_NAME,
    DB_USER: process.env.DB_USER,
    DB_PASSWORD: process.env.DB_PASSWORD,
    SYNC_INTERVAL: process.env.SYNC_INTERVAL,
    APP_COPYRIGHT: process.env.APP_COPYRIGHT,
    APP_AUTHOR: process.env.APP_AUTHOR,
    APP_LICENSE: process.env.APP_LICENSE,
    APP_DESCRIPTION: process.env.APP_DESCRIPTION,
  };
});

ipcMain.handle('portal-bootstrap', async () => {
  return callPortalApi({
    method: 'GET',
    endpoint: '/api/BDEClient/bootstrap',
  });
});

ipcMain.handle('portal-register-client', async (event, payload: any) => {
  return callPortalApi({
    method: 'POST',
    endpoint: '/api/BDEClient/register',
    body: payload,
  });
});

ipcMain.handle('portal-heartbeat', async (event, payload: any) => {
  return callPortalApi({
    method: 'POST',
    endpoint: '/api/BDEClient/heartbeat',
    body: payload,
  });
});

ipcMain.handle(
  'portal-get-workload',
  async (event, clientIdentifier: string, page = 1, pageSize = 25) => {
    return callPortalApi({
      method: 'GET',
      endpoint: `/api/BDEClient/${encodeURIComponent(clientIdentifier)}/workload?page=${page}&pageSize=${pageSize}`,
    });
  },
);

ipcMain.handle('portal-get-news', async (event, clientIdentifier: string) => {
  return callPortalApi({
    method: 'GET',
    endpoint: `/api/BDEClient/${encodeURIComponent(clientIdentifier)}/news`,
  });
});

ipcMain.handle(
  'portal-acknowledge-command',
  async (event, clientIdentifier: string, payload: any) => {
    return callPortalApi({
      method: 'POST',
      endpoint: `/api/BDEClient/${encodeURIComponent(clientIdentifier)}/acknowledge-command`,
      body: payload,
    });
  },
);

ipcMain.handle('restart-app', () => {
  app.relaunch();
  app.exit();
});

ipcMain.handle('get-initial-config', () => {
  return globalConfig;
});

ipcMain.handle('db-config-get-all', () => {
  const result = configDB?.readAllConfig();
  console.log('readAllConfig result:', result);
  return result;
});
ipcMain.handle('db-config-get-by-key', (event, key) => {
  const result = configDB?.readConfigByKey(key);
  console.log('readConfigByKey result:', result);
  return result;
});
ipcMain.handle('db-config-create-or-update', (event, key, value) => {
  const result = configDB?.createOrUpdateConfig(key, value);
  console.log('createOrUpdate result:', result);
  return result;
});
ipcMain.handle('db-config-delete-by-key', (event, key) => {
  const result = configDB?.deleteConfigByKey(key);
  console.log('deleteConfigByKey result:', result);
  return result;
});
