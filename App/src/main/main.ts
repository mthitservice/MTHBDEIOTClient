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

import { app, BrowserWindow, shell, ipcMain, globalShortcut } from 'electron';
import { autoUpdater } from 'electron-updater';
import log from 'electron-log';

import MenuBuilder from './menu';
import { resolveHtmlPath } from './util';

const configDB = require('../../public/database/DBConfig');

let globalConfig: any = 0;
let mainWindow: BrowserWindow | null = null;

require('dotenv').config({
  path: path.resolve(__dirname, '../../.env'),
  debug: true
});

const packageJson = require('../../package.json');

console.log('ENV Debug - dotenv loaded from:', path.resolve(__dirname, '../../.env'));
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
      console.log('Checking for update...');
    });

    autoUpdater.on('update-available', (info) => {
      console.log('Update available:', info);
      if (mainWindow) {
        mainWindow.webContents.send('update-available', info);
      }
    });

    autoUpdater.on('update-not-available', (info) => {
      console.log('Update not available:', info);
    });

    autoUpdater.on('error', (err) => {
      console.error('Error in auto-updater:', err);
      // Für ARM/Linux-Systeme: Auto-Update Fehler sind normal (DEB-Pakete unterstützen kein Auto-Update)
      if (isArmSystem || process.platform === 'linux') {
        console.log('Auto-Update ist für ARM/Linux DEB-Installationen nicht verfügbar - verwenden Sie die manuelle Update-Methode');
      }
    });

    autoUpdater.on('download-progress', (progressObj) => {
      console.log('Download progress:', progressObj);
      if (mainWindow) {
        mainWindow.webContents.send('download-progress', progressObj);
      }
    });

    autoUpdater.on('update-downloaded', (info) => {
      console.log('Update downloaded:', info);
      if (mainWindow) {
        mainWindow.webContents.send('update-downloaded', info);
      }
    });

    // Auto-Update nur für Windows und nicht-ARM Systeme aktivieren
    // ARM/Linux DEB-Pakete unterstützen kein Auto-Update über GitHub
    const shouldCheckForUpdates = process.env.NODE_ENV === 'production' &&
      !isArmSystem &&
      process.platform !== 'linux';

    if (shouldCheckForUpdates) {
      console.log('Auto-Update aktiviert für unterstützte Plattform');
      autoUpdater.checkForUpdatesAndNotify();
    } else {
      console.log('Auto-Update deaktiviert für diese Plattform (ARM/Linux DEB)');
      console.log('Für Updates: Neues DEB-Paket von GitHub herunterladen und installieren');
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
    // Für ARM/Linux: Manueller Update-Check über GitHub API
    if (isArmSystem || process.platform === 'linux') {
      console.log(
        'Checking for updates via GitHub API for ARM/Linux system...',
      );

      const response = await fetch(
        'https://api.github.com/repos/mthitservice/MTHBDEIOTClient/releases/latest',
      );
      const data = await response.json();

      const latestVersion = data.tag_name.replace('v', '');
      const currentVersion = process.env.APP_VERSION || '1.0.0';

      const updateInfo = {
        currentVersion,
        latestVersion,
        hasUpdate: latestVersion !== currentVersion,
        downloadUrl: `https://github.com/mthitservice/MTHBDEIOTClient/releases/download/${data.tag_name}`,
        releaseNotes: data.body,
        publishedAt: data.published_at,
      };

      console.log('Update check result:', updateInfo);
      return updateInfo;
    }

    // Standard Auto-Updater für andere Plattformen
    return autoUpdater.checkForUpdates();
  } catch (error: any) {
    console.error('Error checking for updates:', error);
    return { error: error.message };
  }
});

ipcMain.handle('download-update', async () => {
  try {
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
    console.error('Error downloading update:', error);
    return { error: error.message };
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
    process.argv.includes('--dev1080') ||
    process.env.DEV_1080 === 'true';

  // Fenstergröße bestimmen
  let windowWidth = 1024;
  let windowHeight = 728;

  if (isDev1080Mode || isFullscreenMode) {
    windowWidth = 1920;
    windowHeight = 1080;
  }

  console.log(`🖥️  Window size: ${windowWidth}x${windowHeight} (Fullscreen: ${isFullscreenMode}, Dev1080: ${isDev1080Mode})`);

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
    const fs = require('fs');
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
      if (process.env.RASPBERRY_PI === 'true' && process.env.NODE_ENV === 'development') {
        console.log('🍓 Raspberry Pi Entwicklungsmodus aktiviert');

        // DevTools öffnen mit Responsive Design Mode
        mainWindow?.webContents.openDevTools({
          mode: 'right'
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
    if (globalConfig?.DEBUG_MODE === 'true') {
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
  return {
    API_URL: process.env.API_URL,
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
  const result = configDB?.getByKey(key);
  console.log('getByKey result:', result);
  return result;
});
ipcMain.handle('db-config-create-or-update', (event, key, value) => {
  const result = configDB?.createOrUpdateConfig(key, value);
  console.log('createOrUpdate result:', result);
  return result;
});
ipcMain.handle('db-config-delete-by-key', (event, key) => {
  const result = configDB?.deleteByKey(key);
  console.log('deleteByKey result:', result);
  return result;
});
