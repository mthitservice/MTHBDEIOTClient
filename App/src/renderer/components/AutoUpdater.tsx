import React, { useState, useEffect } from 'react';
import './AutoUpdater.css';

interface UpdateInfo {
  version: string;
  releaseDate: string;
  releaseName?: string;
  releaseNotes?: string;
}

interface DownloadProgress {
  bytesPerSecond: number;
  percent: number;
  transferred: number;
  total: number;
}

const AutoUpdater: React.FC = () => {
  const [currentVersion, setCurrentVersion] = useState<string>('');
  const [checking, setChecking] = useState<boolean>(false);
  const [updateAvailable, setUpdateAvailable] = useState<boolean>(false);
  const [updateInfo, setUpdateInfo] = useState<UpdateInfo | null>(null);
  const [downloading, setDownloading] = useState<boolean>(false);
  const [downloadProgress, setDownloadProgress] =
    useState<DownloadProgress | null>(null);
  const [updateReady, setUpdateReady] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);
  const [updateCheckEnabled, setUpdateCheckEnabled] = useState<boolean>(false);

  useEffect(() => {
    initializeUpdater();
    setupUpdateListeners();
  }, []);

  const initializeUpdater = async () => {
    try {
      const appVersion = await window.electron.autoUpdater.getAppVersion();
      const updateInfo = await window.electron.autoUpdater.getUpdateInfo();

      setCurrentVersion(appVersion);
      setUpdateCheckEnabled(updateInfo.updateCheckEnabled);
    } catch (err) {
      console.error('Failed to initialize updater:', err);
    }
  };

  const setupUpdateListeners = () => {
    // Listen for update events
    window.electron.ipcRenderer.on('update-available', (...args: unknown[]) => {
      const updateInfo = args[0] as UpdateInfo;
      setUpdateAvailable(true);
      setUpdateInfo(updateInfo);
      setError(null);
    });

    window.electron.ipcRenderer.on(
      'download-progress',
      (...args: unknown[]) => {
        const progress = args[0] as DownloadProgress;
        setDownloadProgress(progress);
      },
    );

    window.electron.ipcRenderer.on('update-downloaded', () => {
      setUpdateReady(true);
      setDownloading(false);
      setDownloadProgress(null);
    });

    window.electron.ipcRenderer.on('update-not-available', () => {
      setChecking(false);
      setError(null);
    });

    window.electron.ipcRenderer.on('update-error', (...args: unknown[]) => {
      const errorMessage = args[0] as string;
      setError(errorMessage);
      setChecking(false);
      setDownloading(false);
    });

    // Cleanup listeners on unmount
    return () => {
      window.electron.ipcRenderer.removeAllListeners('update-available');
      window.electron.ipcRenderer.removeAllListeners('download-progress');
      window.electron.ipcRenderer.removeAllListeners('update-downloaded');
      window.electron.ipcRenderer.removeAllListeners('update-not-available');
      window.electron.ipcRenderer.removeAllListeners('update-error');
    };
  };

  const checkForUpdates = async () => {
    if (!updateCheckEnabled) {
      setError('Update-Prüfung ist nur in der Produktionsversion verfügbar');
      return;
    }

    setChecking(true);
    setError(null);
    setUpdateAvailable(false);
    setUpdateInfo(null);

    try {
      await window.electron.autoUpdater.checkForUpdates();
    } catch (err) {
      setError('Fehler beim Prüfen auf Updates: ' + (err as Error).message);
    } finally {
      setChecking(false);
    }
  };

  const downloadUpdate = async () => {
    if (!updateAvailable) return;

    setDownloading(true);
    setError(null);

    try {
      await window.electron.autoUpdater.downloadUpdate();
    } catch (err) {
      setError(
        'Fehler beim Herunterladen des Updates: ' + (err as Error).message,
      );
      setDownloading(false);
    }
  };

  const installUpdate = async () => {
    if (!updateReady) return;

    try {
      await window.electron.autoUpdater.installUpdate();
    } catch (err) {
      setError(
        'Fehler beim Installieren des Updates: ' + (err as Error).message,
      );
    }
  };

  const formatBytes = (bytes: number): string => {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  };

  return (
    <div className="auto-updater">
      <div className="auto-updater-header">
        <h3>🔄 App-Updates</h3>
      </div>

      <div className="auto-updater-content">
        <div className="version-info">
          <strong>Aktuelle Version: </strong>
          <span className="version-tag">{currentVersion}</span>
          {!updateCheckEnabled && (
            <span className="dev-mode-tag">Development Mode</span>
          )}
        </div>

        {error && (
          <div className="error-message">
            <div className="error-content">
              ⚠️ {error}
              <button className="close-button" onClick={() => setError(null)}>
                ×
              </button>
            </div>
          </div>
        )}

        {updateAvailable && updateInfo && (
          <div className="update-info">
            <div className="update-content">
              ℹ️ <strong>Update verfügbar: </strong>
              <span className="update-version">v{updateInfo.version}</span>
              <br />
              <span className="release-date">
                Veröffentlicht:{' '}
                {new Date(updateInfo.releaseDate).toLocaleDateString('de-DE')}
              </span>
            </div>
          </div>
        )}

        {downloading && downloadProgress && (
          <div className="download-progress">
            <div>Download läuft...</div>
            <div className="progress-bar">
              <div
                className="progress-fill"
                style={{ width: `${downloadProgress.percent}%` }} // eslint-disable-line
              />
            </div>
            <div className="progress-text">
              {Math.round(downloadProgress.percent)}% -
              {formatBytes(downloadProgress.transferred)} /{' '}
              {formatBytes(downloadProgress.total)}(
              {formatBytes(downloadProgress.bytesPerSecond)}/s)
            </div>
          </div>
        )}

        {updateReady && (
          <div className="update-ready">
            ✅ Update heruntergeladen! Neustart erforderlich.
          </div>
        )}

        <div className="actions">
          <button
            className="btn btn-primary"
            onClick={checkForUpdates}
            disabled={checking || !updateCheckEnabled}
          >
            {checking ? '🔄 Prüfe...' : '🔄 Auf Updates prüfen'}
          </button>

          {updateAvailable && !downloading && !updateReady && (
            <button className="btn btn-secondary" onClick={downloadUpdate}>
              ⬇️ Update herunterladen
            </button>
          )}

          {updateReady && (
            <button className="btn btn-danger" onClick={installUpdate}>
              🔄 Jetzt installieren & neustarten
            </button>
          )}

          <a
            href="https://github.com/mthitservice/MTHBDEIOTClient/releases"
            target="_blank"
            rel="noopener noreferrer"
            className="btn btn-link"
          >
            📝 GitHub Releases
          </a>
        </div>

        <div className="footer-info">
          Updates werden automatisch von GitHub heruntergeladen.
          <br />
          Repository: mthitservice/MTHBDEIOTClient
        </div>
      </div>
    </div>
  );
};

export default AutoUpdater;
