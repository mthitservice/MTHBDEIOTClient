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

import { app, BrowserWindow, shell, ipcMain } from 'electron';
import { autoUpdater } from 'electron-updater';
import log from 'electron-log';

import MenuBuilder from './menu';
import { resolveHtmlPath } from './util';

const configDB = require('../../public/database/DBConfig');

let globalConfig: any = 0;
let mainWindow: BrowserWindow | null = null;

require('dotenv').config();

console.log('APP Name:', process.env.APP_NAME);
console.log('APP Version:', process.env.APP_VERSION);

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

    // Prüfe nur in Production auf Updates
    if (process.env.NODE_ENV === 'production') {
      autoUpdater.checkForUpdatesAndNotify();
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
  if (process.env.NODE_ENV === 'production') {
    return autoUpdater.checkForUpdates();
  }
  return { updateInfo: null };
});

ipcMain.handle('download-update', async () => {
  if (process.env.NODE_ENV === 'production') {
    return autoUpdater.downloadUpdate();
  }
  return false;
});

ipcMain.handle('install-update', async () => {
  if (process.env.NODE_ENV === 'production') {
    autoUpdater.quitAndInstall();
  }
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

  mainWindow = new BrowserWindow({
    show: false,
    width: 1024,
    height: 728,
    icon: getAssetPath('icon.png'),
    webPreferences: {
      preload: app.isPackaged
        ? path.join(__dirname, 'preload.js')
        : path.join(__dirname, '../../.erb/dll/preload.js'),
    },
  });

  mainWindow.loadURL(resolveHtmlPath('index.html'));
  mainWindow.on('ready-to-show', () => {
    if (!mainWindow) {
      throw new Error('"mainWindow" is not defined');
    }
    if (process.env.START_MINIMIZED) {
      mainWindow.minimize();
    } else {
      mainWindow.show();
      mainWindow.focus();

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

  // Remove this if your app does not use auto updates
  // eslint-disable-next-line
  new AppUpdater();
};

/**
 * Add event listeners...
 */

app.on('window-all-closed', () => {
  // Respect the OSX convention of having the application in memory even
  // after all windows have been closed
  if (process.platform !== 'darwin') {
    app.quit();
  }
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

ipcMain.handle('get-env', async () => {
  return {
    API_URL: process.env.API_URL,
    APP_NAME: process.env.APP_NAME,
    APP_VERSION: process.env.APP_VERSION,
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
