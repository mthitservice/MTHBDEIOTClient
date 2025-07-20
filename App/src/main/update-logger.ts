import * as fs from 'fs';
import * as path from 'path';
import { app } from 'electron';
import log from 'electron-log';

interface LogEntry {
  timestamp: string;
  level: string;
  category: string;
  message: string;
  data?: any;
  pid: number;
  platform: string;
  arch: string;
}

interface LogConfig {
  maxRetentionDays: number;
  enableRemoteLogging: boolean;
  remoteLogEndpoint?: string;
  maxLogFileSize: number; // in MB
}

class UpdateLogger {
  private logDir: string;

  private logFile: string;

  private config: LogConfig;

  private electronLog: any;

  constructor() {
    // Log-Verzeichnis in userData Ordner
    this.logDir = path.join(app.getPath('userData'), 'logs');
    this.logFile = path.join(this.logDir, 'update-system.log');

    // Konfiguration für Log-Retention und Remote-Logging
    this.config = {
      maxRetentionDays: 30,
      enableRemoteLogging: false,
      maxLogFileSize: 10, // 10MB
    };

    // Stelle sicher, dass das Log-Verzeichnis existiert
    this.ensureLogDirectory();

    // Initialisiere electron-log integration
    this.initElectronLogIntegration();

    // Cleanup alte Logs beim Start
    this.cleanupOldLogs();

    // Remote-Logging Setup prüfen
    this.setupRemoteLogging();
  }

  private ensureLogDirectory(): void {
    if (!fs.existsSync(this.logDir)) {
      fs.mkdirSync(this.logDir, { recursive: true });
    }
  }

  private initElectronLogIntegration(): void {
    try {
      // eslint-disable-next-line @typescript-eslint/no-var-requires
      this.electronLog = require('electron-log');

      // Konfiguriere electron-log für bessere Performance
      this.electronLog.transports.file.maxSize =
        this.config.maxLogFileSize * 1024 * 1024;
      this.electronLog.transports.file.archiveLog = true;
      this.electronLog.transports.file.level = 'info';

      this.info('LOGGER', 'Electron-log integration initialized', {
        logPath: this.electronLog.transports.file.getFile().path,
        maxSize: `${this.config.maxLogFileSize}MB`,
      });
    } catch (error) {
      console.warn('Failed to initialize electron-log integration:', error);
    }
  }

  private setupRemoteLogging(): void {
    // Prüfe globale Konfiguration für Remote-Logging
    try {
      const configDB = require('../../../public/database/DBConfig');
      configDB.getAll((err: any, config: any[]) => {
        if (!err && config) {
          const ipv4Address = config.find(
            (item: any) => item.key === 'ipv4Address',
          )?.value;
          const enableRemoteLogging =
            config.find((item: any) => item.key === 'enableRemoteLogging')
              ?.value === 'true';

          if (ipv4Address && enableRemoteLogging) {
            this.config.enableRemoteLogging = true;
            this.config.remoteLogEndpoint = `http://${ipv4Address}/logs`;

            this.info('LOGGER', 'Remote logging enabled', {
              endpoint: this.config.remoteLogEndpoint,
              testConnection: 'will verify on first log',
            });
          }
        }
      });
    } catch (error) {
      this.debug('LOGGER', 'Could not setup remote logging', error);
    }
  }

  private cleanupOldLogs(): void {
    try {
      const maxAgeMs = this.config.maxRetentionDays * 24 * 60 * 60 * 1000;
      const cutoffDate = Date.now() - maxAgeMs;

      // Cleanup eigene Log-Dateien
      const files = fs.readdirSync(this.logDir);
      let cleanedCount = 0;

      files.forEach((file) => {
        const filePath = path.join(this.logDir, file);
        const stats = fs.statSync(filePath);

        if (stats.mtime.getTime() < cutoffDate) {
          fs.unlinkSync(filePath);
          cleanedCount++;
        }
      });

      // Cleanup electron-log Dateien (falls vorhanden)
      if (this.electronLog) {
        try {
          const electronLogDir = path.dirname(
            this.electronLog.transports.file.getFile().path,
          );
          const electronLogFiles = fs.readdirSync(electronLogDir);

          electronLogFiles.forEach((file) => {
            if (file.includes('main.log') || file.includes('renderer.log')) {
              const filePath = path.join(electronLogDir, file);
              const stats = fs.statSync(filePath);

              if (stats.mtime.getTime() < cutoffDate) {
                fs.unlinkSync(filePath);
                cleanedCount++;
              }
            }
          });
        } catch (error) {
          // Ignoriere Fehler beim electron-log cleanup
        }
      }

      if (cleanedCount > 0) {
        this.info(
          'LOGGER',
          `Cleaned up ${cleanedCount} old log files older than ${this.config.maxRetentionDays} days`,
        );
      }
    } catch (error) {
      console.error('Failed to cleanup old logs:', error);
    }
  }

  private async sendToRemoteLogger(logEntry: LogEntry): Promise<void> {
    if (!this.config.enableRemoteLogging || !this.config.remoteLogEndpoint) {
      return;
    }

    try {
      // AbortController für Timeout
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 2000); // 2s Timeout

      const response = await fetch(this.config.remoteLogEndpoint, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': `MTH-BDE-IOT-Client/${require('../../../package.json').version}`,
        },
        body: JSON.stringify({
          logs: [logEntry],
          source: 'mth-bde-iot-client',
          hostname: require('os').hostname(),
        }),
        signal: controller.signal,
      });

      clearTimeout(timeoutId);

      if (!response.ok) {
        // Deaktiviere Remote-Logging bei wiederholten Fehlern
        this.config.enableRemoteLogging = false;
        console.warn(
          `Remote logging disabled due to error: ${response.status}`,
        );
      }
    } catch (error: any) {
      // Stille Ignorierung von Remote-Logging Fehlern um Performance nicht zu beeinträchtigen
      if (error?.name !== 'AbortError') {
        console.debug(
          'Remote logging failed (non-critical):',
          error?.message || error,
        );
      }
    }
  }

  private getTimestamp(): string {
    return new Date().toISOString();
  }

  private writeLog(
    level: string,
    category: string,
    message: string,
    data?: any,
  ): void {
    const timestamp = this.getTimestamp();
    const logEntry: LogEntry = {
      timestamp,
      level,
      category,
      message,
      data: data || null,
      pid: process.pid,
      platform: process.platform,
      arch: process.arch,
    };

    const logLine = `${JSON.stringify(logEntry)}\n`;

    // Console-Output für Entwicklung
    const colorCode = this.getColorCode(level);
    const dataStr = data ? ` | ${JSON.stringify(data)}` : '';
    console.log(
      `${colorCode}[${timestamp}] ${level.padEnd(5)} ${category}: ${message}${dataStr}\x1b[0m`,
    );

    // File-Output (lokale Datei)
    try {
      fs.appendFileSync(this.logFile, logLine);
    } catch (error) {
      console.error('Failed to write to log file:', error);
    }

    // Electron-log Integration
    if (this.electronLog) {
      const electronLogLevel = level.toLowerCase();
      switch (electronLogLevel) {
        case 'error':
          this.electronLog.error(`[${category}] ${message}`, data);
          break;
        case 'warn':
          this.electronLog.warn(`[${category}] ${message}`, data);
          break;
        case 'debug':
          this.electronLog.debug(`[${category}] ${message}`, data);
          break;
        default:
          this.electronLog.info(`[${category}] ${message}`, data);
      }
    }

    // Remote-Logging (asynchron, nicht blockierend)
    if (this.config.enableRemoteLogging) {
      this.sendToRemoteLogger(logEntry).catch(() => {
        // Ignoriere Fehler - Remote-Logging ist optional
      });
    }

    // Log-Rotation prüfen
    this.checkAndRotateLogs();
  }

  private checkAndRotateLogs(): void {
    try {
      const stats = fs.statSync(this.logFile);
      const fileSizeInMB = stats.size / (1024 * 1024);

      if (fileSizeInMB > this.config.maxLogFileSize) {
        this.rotateLogs();
      }
    } catch (error) {
      // Ignoriere Fehler beim Size-Check
    }
  }

  private getColorCode(level: string): string {
    switch (level.toLowerCase()) {
      case 'info':
        return '\x1b[36m'; // Cyan
      case 'warn':
        return '\x1b[33m'; // Yellow
      case 'error':
        return '\x1b[31m'; // Red
      case 'debug':
        return '\x1b[90m'; // Gray
      case 'success':
        return '\x1b[32m'; // Green
      default:
        return '\x1b[0m'; // Reset
    }
  }

  // Update-spezifische Log-Methoden
  updateCheckStarted(source?: string): void {
    this.writeLog(
      'INFO',
      'UPDATE_CHECK',
      `Update check started${source ? ` for ${source}` : ''}`,
    );
  }

  internetCheckStarted(): void {
    this.writeLog(
      'INFO',
      'INTERNET_CHECK',
      'Checking for updates from GitHub API',
    );
  }

  internetCheckSuccess(updateInfo: any): void {
    this.writeLog(
      'SUCCESS',
      'INTERNET_CHECK',
      'Internet update check successful',
      updateInfo,
    );
  }

  internetCheckFailed(error: any): void {
    this.writeLog(
      'WARN',
      'INTERNET_CHECK',
      'Internet update check failed, trying local server fallback',
      {
        error: error.message || error.toString(),
        code: error.code,
        timeout: error.name === 'AbortError',
      },
    );
  }

  localServerCheckStarted(serverIP: string): void {
    this.writeLog(
      'INFO',
      'LOCAL_SERVER',
      `Checking for updates from local server: http://${serverIP}/update`,
    );
  }

  localServerCheckSuccess(updateInfo: any): void {
    this.writeLog(
      'SUCCESS',
      'LOCAL_SERVER',
      'Local server update check successful',
      updateInfo,
    );
  }

  localServerCheckFailed(error: any): void {
    this.writeLog('ERROR', 'LOCAL_SERVER', 'Local server update check failed', {
      error: error.message || error.toString(),
      code: error.code,
      timeout: error.name === 'AbortError',
    });
  }

  noUpdateSourceAvailable(): void {
    this.writeLog(
      'WARN',
      'UPDATE_SYSTEM',
      'No update source available - neither internet nor local server accessible',
    );
  }

  updateCheckCompleted(result: any): void {
    this.writeLog('INFO', 'UPDATE_CHECK', 'Update check completed', {
      source: result.source,
      hasUpdate: result.hasUpdate,
      currentVersion: result.currentVersion,
      latestVersion: result.latestVersion,
    });
  }

  downloadStarted(source: string, version: string): void {
    this.writeLog(
      'INFO',
      'DOWNLOAD',
      `Starting download from ${source} for version ${version}`,
    );
  }

  downloadCompleted(success: boolean, error?: any): void {
    if (success) {
      this.writeLog(
        'SUCCESS',
        'DOWNLOAD',
        'Update download completed successfully',
      );
    } else {
      this.writeLog('ERROR', 'DOWNLOAD', 'Update download failed', {
        error: error?.message || error,
      });
    }
  }

  autoUpdateEvent(event: string, data?: any): void {
    this.writeLog('INFO', 'AUTO_UPDATE', `AutoUpdater event: ${event}`, data);
  }

  systemInfo(info: any): void {
    this.writeLog('INFO', 'SYSTEM', 'System information', info);
  }

  // Allgemeine Log-Methoden
  info(category: string, message: string, data?: any): void {
    this.writeLog('INFO', category, message, data);
  }

  warn(category: string, message: string, data?: any): void {
    this.writeLog('WARN', category, message, data);
  }

  error(category: string, message: string, data?: any): void {
    this.writeLog('ERROR', category, message, data);
  }

  debug(category: string, message: string, data?: any): void {
    this.writeLog('DEBUG', category, message, data);
  }

  success(category: string, message: string, data?: any): void {
    this.writeLog('SUCCESS', category, message, data);
  }

  // Log-Datei Verwaltung
  getLogPath(): string {
    return this.logFile;
  }

  clearLogs(): void {
    try {
      fs.writeFileSync(this.logFile, '');
      this.info('LOGGER', 'Log file cleared');
    } catch (error) {
      console.error('Failed to clear log file:', error);
    }
  }

  getRecentLogs(lines: number = 100): string[] {
    try {
      const content = fs.readFileSync(this.logFile, 'utf8');
      return content
        .split('\n')
        .slice(-lines)
        .filter((line: string) => line.trim());
    } catch (error) {
      console.error('Failed to read log file:', error);
      return [];
    }
  }

  // Log-Rotation
  rotateLogs(): void {
    try {
      const stats = fs.statSync(this.logFile);
      const fileSizeInMB = stats.size / (1024 * 1024);

      if (fileSizeInMB > this.config.maxLogFileSize) {
        const rotatedFile = this.logFile.replace('.log', `-${Date.now()}.log`);
        fs.renameSync(this.logFile, rotatedFile);
        this.info('LOGGER', `Log file rotated to ${rotatedFile}`);
      }
    } catch (error) {
      console.error('Failed to rotate log file:', error);
    }
  }

  // Remote-Logging Management
  async configureRemoteLogging(enable: boolean): Promise<void> {
    this.config.enableRemoteLogging = enable;

    if (enable) {
      // Prüfe Konfiguration
      try {
        // eslint-disable-next-line @typescript-eslint/no-var-requires
        const configDB = require('../../../public/database/DBConfig');
        return new Promise((resolve, reject) => {
          configDB.getAll((err: any, config: any[]) => {
            if (err) {
              reject(new Error('Failed to read configuration'));
              return;
            }

            const ipv4Address = config.find(
              (item: any) => item.key === 'ipv4Address',
            )?.value;
            if (!ipv4Address) {
              reject(new Error('IPv4 address not configured'));
              return;
            }

            this.config.remoteLogEndpoint = `http://${ipv4Address}/logs`;

            // Speichere Remote-Logging Einstellung
            configDB.update('enableRemoteLogging', 'true', () => {
              this.info('REMOTE_LOGGING', 'Remote logging enabled', {
                endpoint: this.config.remoteLogEndpoint,
              });
              resolve();
            });
          });
        });
      } catch (error) {
        throw new Error('Failed to configure remote logging');
      }
    } else {
      // Deaktiviere Remote-Logging
      try {
        // eslint-disable-next-line @typescript-eslint/no-var-requires
        const configDB = require('../../../public/database/DBConfig');
        return new Promise<void>((resolve) => {
          configDB.update('enableRemoteLogging', 'false', () => {
            this.info('REMOTE_LOGGING', 'Remote logging disabled');
            resolve();
          });
        });
      } catch (error) {
        // Ignoriere Fehler beim Deaktivieren
        this.warn('REMOTE_LOGGING', 'Failed to disable remote logging', {
          error,
        });
      }
    }
  }

  getRemoteLoggingStatus(): any {
    return {
      enabled: this.config.enableRemoteLogging,
      endpoint: this.config.remoteLogEndpoint,
      maxRetentionDays: this.config.maxRetentionDays,
      maxLogFileSize: this.config.maxLogFileSize,
    };
  }

  getElectronLogPath(): string | null {
    try {
      return this.electronLog?.transports?.file?.getFile()?.path || null;
    } catch (error) {
      return null;
    }
  }

  async testRemoteConnection(): Promise<any> {
    if (!this.config.enableRemoteLogging || !this.config.remoteLogEndpoint) {
      return { success: false, error: 'Remote logging not configured' };
    }

    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 5000);

      const testLog = {
        timestamp: new Date().toISOString(),
        level: 'INFO',
        category: 'CONNECTION_TEST',
        message: 'Remote logging connection test',
        data: { test: true },
        pid: process.pid,
        platform: process.platform,
        arch: process.arch,
      };

      // eslint-disable-next-line @typescript-eslint/no-var-requires
      const packageJson = require('../../../package.json');
      // eslint-disable-next-line @typescript-eslint/no-var-requires
      const os = require('os');

      const response = await fetch(this.config.remoteLogEndpoint, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': `MTH-BDE-IOT-Client/${packageJson.version}`,
        },
        body: JSON.stringify({
          logs: [testLog],
          source: 'mth-bde-iot-client',
          hostname: os.hostname(),
        }),
        signal: controller.signal,
      });

      clearTimeout(timeoutId);

      return {
        success: response.ok,
        status: response.status,
        endpoint: this.config.remoteLogEndpoint,
        responseTime: Date.now() - Date.parse(testLog.timestamp),
      };
    } catch (error: any) {
      return {
        success: false,
        error: error?.message || error,
        endpoint: this.config.remoteLogEndpoint,
      };
    }
  }

  // Erweiterte Log-Management Funktionen
  getLogStatistics(): any {
    try {
      const content = fs.readFileSync(this.logFile, 'utf8');
      const lines = content.split('\n').filter((line) => line.trim());

      const stats = {
        totalEntries: lines.length,
        fileSize: fs.statSync(this.logFile).size,
        fileSizeMB: (fs.statSync(this.logFile).size / 1024 / 1024).toFixed(2),
        oldestEntry: null as string | null,
        newestEntry: null as string | null,
        categoryBreakdown: {} as Record<string, number>,
        levelBreakdown: {} as Record<string, number>,
      };

      if (lines.length > 0) {
        try {
          const firstEntry = JSON.parse(lines[0]);
          const lastEntry = JSON.parse(lines[lines.length - 1]);
          stats.oldestEntry = firstEntry.timestamp;
          stats.newestEntry = lastEntry.timestamp;

          // Analysiere Kategorien und Level
          lines.forEach((line) => {
            try {
              const entry = JSON.parse(line);
              stats.categoryBreakdown[entry.category] =
                (stats.categoryBreakdown[entry.category] || 0) + 1;
              stats.levelBreakdown[entry.level] =
                (stats.levelBreakdown[entry.level] || 0) + 1;
            } catch {
              // Ignoriere fehlerhafte Zeilen
            }
          });
        } catch {
          // Ignoriere Parse-Fehler
        }
      }

      return stats;
    } catch (error) {
      return {
        error: 'Failed to read log statistics',
        totalEntries: 0,
        fileSize: 0,
      };
    }
  }
}

export default UpdateLogger;
