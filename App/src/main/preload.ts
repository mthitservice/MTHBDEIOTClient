// Disable no-unused-vars, broken for spread args
/* eslint no-unused-vars: off */
import { contextBridge, ipcRenderer, IpcRendererEvent } from 'electron';

export type Channels =
  | 'ipc-example'
  | 'update-available'
  | 'download-progress'
  | 'update-downloaded'
  | 'update-not-available'
  | 'update-error'
  | 'navigate-to-config'
  | 'escape-pressed';

const electronHandler = {
  app: {
    restart: () => ipcRenderer.invoke('restart-app'),
  },
  dbConfig: {
    getInitialConfig: () => ipcRenderer.invoke('get-initial-config'),

    readAllConfig: () => ipcRenderer.invoke('db-config-get-all'),
    getByKey: (key: string) => ipcRenderer.invoke('db-config-get-by-key', key),
    createOrUpdate: (key: string, value: string) =>
      ipcRenderer.invoke('db-config-create-or-update', key, value),
    deleteByKey: (key: string) =>
      ipcRenderer.invoke('db-config-delete-by-key', key),
  },
  dbQuery: (query: string) => ipcRenderer.invoke('db-query', query),
  getEnv: () => ipcRenderer.invoke('get-env'),
  portalApi: {
    bootstrap: () => ipcRenderer.invoke('portal-bootstrap'),
    registerClient: (payload: unknown) =>
      ipcRenderer.invoke('portal-register-client', payload),
    heartbeat: (payload: unknown) =>
      ipcRenderer.invoke('portal-heartbeat', payload),
    getWorkload: (clientIdentifier: string, page = 1, pageSize = 25) =>
      ipcRenderer.invoke(
        'portal-get-workload',
        clientIdentifier,
        page,
        pageSize,
      ),
    getNews: (clientIdentifier: string) =>
      ipcRenderer.invoke('portal-get-news', clientIdentifier),
    acknowledgeCommand: (clientIdentifier: string, payload: unknown) =>
      ipcRenderer.invoke(
        'portal-acknowledge-command',
        clientIdentifier,
        payload,
      ),
  },
  autoUpdater: {
    checkForUpdates: () => ipcRenderer.invoke('check-for-updates'),
    downloadUpdate: () => ipcRenderer.invoke('download-update'),
    installUpdate: () => ipcRenderer.invoke('install-update'),
    getAppVersion: () => ipcRenderer.invoke('get-app-version'),
    getUpdateInfo: () => ipcRenderer.invoke('get-update-info'),
  },
  ipcRenderer: {
    sendMessage(channel: Channels, ...args: unknown[]) {
      ipcRenderer.send(channel, ...args);
    },
    on(channel: Channels, func: (...args: unknown[]) => void) {
      const subscription = (_event: IpcRendererEvent, ...args: unknown[]) =>
        func(...args);
      ipcRenderer.on(channel, subscription);

      return () => {
        ipcRenderer.removeListener(channel, subscription);
      };
    },
    once(channel: Channels, func: (...args: unknown[]) => void) {
      ipcRenderer.once(channel, (_event, ...args) => func(...args));
    },
    removeAllListeners(channel: Channels) {
      ipcRenderer.removeAllListeners(channel);
    },
    invoke(channel: string, ...args: unknown[]) {
      return ipcRenderer.invoke(channel, ...args);
    },
  },
};

contextBridge.exposeInMainWorld('electron', electronHandler);

export type ElectronHandler = typeof electronHandler;
