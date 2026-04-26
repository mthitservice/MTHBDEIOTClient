import React, { useEffect, useState } from 'react';
import MainPage from './MainPage';
import { InfomonitorDisplay, type InfoContent } from './InfomonitorDisplay';
import './ModeRouter.css';

interface ModeRouterProps {
  navigate?: (path: string) => void;
}

/**
 * ModeRouter: Wählt basierend auf clientMode die richtige Komponente
 *
 * Unterstützte Modi:
 * - druckmaschine: Auftragsbearbeitung für Druckmaschinen (MainPage)
 * - weiterverarbeitung: Auftragsbearbeitung für Weiterverarbeitung (MainPage)
 * - infomonitor: Info-Terminal mit automatischer Rotation (InfomonitorDisplay)
 */
export function ModeRouter({ navigate }: ModeRouterProps) {
  const [clientMode, setClientMode] = useState<string>('druckmaschine');
  const [infomonitorContent, setInfomonitorContent] = useState<InfoContent[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  const isVisibleNow = (newsItem: any) => {
    const now = new Date();
    const active = newsItem?.active === true;
    const from = newsItem?.from ? new Date(newsItem.from) : null;
    const to = newsItem?.to ? new Date(newsItem.to) : null;

    const fromOk = !from || from <= now;
    const toOk = !to || to >= now;

    return active && fromOk && toOk;
  };

  // Lade den clientMode aus der DB beim Mount
  useEffect(() => {
    const loadClientMode = async () => {
      try {
        const config = await window.electron.dbConfig.readAllConfig();
        if (Array.isArray(config)) {
          const modeEntry = config.find((item: any) => item.key === 'clientMode');
          if (modeEntry) {
            setClientMode(modeEntry.value);
          }
        }
      } catch (error) {
        console.warn('Fehler beim Laden des clientMode:', error);
        setClientMode('druckmaschine'); // Fallback
      } finally {
        setIsLoading(false);
      }
    };

    loadClientMode();
  }, []);

  // Lade Infomonitor-Inhalte vom Portal, falls clientMode === 'infomonitor'
  useEffect(() => {
    if (clientMode !== 'infomonitor') return;

    const loadInfomonitorContent = async () => {
      try {
        const config = await window.electron.dbConfig.readAllConfig();
        const configList = Array.isArray(config) ? config : [];
        const clientIdentifier =
          configList.find((item: any) => item.key === 'clientIdentifier')?.value ||
          configList.find((item: any) => item.key === 'deviceName')?.value;

        if (!clientIdentifier) {
          console.warn('Kein clientIdentifier für Infomonitor-Inhalte');
          // Fallback: Leeres Array, um "Keine Inhalte verfügbar" zu zeigen
          setInfomonitorContent([]);
          return;
        }

        // Dedizierter News-Endpunkt für Infomonitor
        const response = await window.electron.portalApi.getNews(clientIdentifier);
        const rawNews = Array.isArray(response?.news)
          ? response.news
          : Array.isArray(response?.News)
            ? response.News
            : [];

        const visibleNews = rawNews
          .filter(isVisibleNow)
          .sort((a: any, b: any) => {
            const aTime = new Date(a?.from || a?.creationDate || 0).getTime();
            const bTime = new Date(b?.from || b?.creationDate || 0).getTime();
            return bTime - aTime;
          });

        if (visibleNews.length === 0) {
          console.warn('Keine Inhalte vom Portal für Infomonitor');
          setInfomonitorContent([]);
          return;
        }

        const content: InfoContent[] = visibleNews.map((item: any) => ({
          title: item?.name || item?.title || 'Information',
          body: item?.text || item?.description || item?.Beschreibung || '',
          imageUrl:
            item?.image?.document ||
            item?.imageUrl ||
            item?.Bild?.document ||
            item?.Bild ||
            undefined,
        }));

        setInfomonitorContent(content);
      } catch (error) {
        console.error('Fehler beim Laden von Infomonitor-Inhalten:', error);
        setInfomonitorContent([]);
      }
    };

    loadInfomonitorContent();

    // Optional: Inhalte alle 5 Minuten aktualisieren
    const refreshInterval = setInterval(loadInfomonitorContent, 5 * 60 * 1000);
    return () => clearInterval(refreshInterval);
  }, [clientMode]);

  if (isLoading) {
    return (
      <div className="mode-router-loading">
        <div className="spinner-border text-primary" role="status">
          <span className="visually-hidden">Lädt...</span>
        </div>
        <p>App wird initialisiert...</p>
      </div>
    );
  }

  // Rendere basierend auf clientMode
  switch (clientMode) {
    case 'infomonitor':
      return (
        <InfomonitorDisplay
          items={infomonitorContent}
          autoRotateInterval={15000}
        />
      );

    case 'weiterverarbeitung':
      // Weiterverarbeitung: Ähnlich MainPage, aber mit Filter/Unterscheidung möglich
      return (
        <MainPage
          navigate={navigate}
        />
      );

    case 'druckmaschine':
    default:
      // Druckmaschine: Standard MainPage
      return (
        <MainPage
          navigate={navigate}
        />
      );
  }
}
