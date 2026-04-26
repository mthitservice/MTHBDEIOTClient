import React, { useEffect, useState } from 'react';
import 'bootstrap/dist/css/bootstrap.min.css';
import './InfomonitorDisplay.css';

export interface InfoContent {
  title: string;
  body: string;
  imageUrl?: string;
}

interface InfomonitorDisplayProps {
  items: InfoContent[];
  autoRotateInterval?: number;
}

/**
 * InfomonitorDisplay: Dynamischer Infomonitor mit automatischer Rotation und responsive Layout
 *
 * Layout-Logik:
 * - Nur Text: Vollständige Textanzeige (volle Breite)
 * - Text + Bild: Zweieinhalb-Layout (Links: Text, Rechts: Bild)
 * - Nur Bild: Vollbild
 */
export function InfomonitorDisplay({ items, autoRotateInterval = 15000 }: InfomonitorDisplayProps) {
  const [currentIndex, setCurrentIndex] = useState(0);

  // Automatische Rotation durch Inhalte
  useEffect(() => {
    if (!items || items.length === 0) return;

    const timer = setInterval(() => {
      setCurrentIndex((prevIndex) => (prevIndex + 1) % items.length);
    }, autoRotateInterval);

    return () => clearInterval(timer);
  }, [items, autoRotateInterval]);

  if (!items || items.length === 0) {
    return (
      <div className="infodisplay-container bg-dark d-flex align-items-center justify-content-center">
        <div className="text-light text-center">
          <h1>Keine Inhalte verfügbar</h1>
          <p>Warte auf Daten vom Portal...</p>
        </div>
      </div>
    );
  }

  const current = items[currentIndex];
  const hasText = current.body && current.body.trim().length > 0;
  const hasImage = current.imageUrl && current.imageUrl.trim().length > 0;

  // Layout bestimmen
  let layoutType: 'text-only' | 'image-only' | 'text-and-image';
  if (hasText && hasImage) {
    layoutType = 'text-and-image';
  } else if (hasImage) {
    layoutType = 'image-only';
  } else {
    layoutType = 'text-only';
  }

  return (
    <div className="infodisplay-container">
      {/* Header mit Uhrzeit und Status */}
      <div className="infodisplay-header">
        <div className="infodisplay-header-left">
          <h2 className="infodisplay-title">{current.title || 'Information'}</h2>
        </div>
        <div className="infodisplay-header-right">
          <div className="infodisplay-datetime">
            <span className="datetime-label">
              {new Date().toLocaleDateString('de-DE')}
            </span>
            <span className="datetime-separator">|</span>
            <span className="datetime-label">
              {new Date().toLocaleTimeString('de-DE')}
            </span>
          </div>
          <div className="infodisplay-page-indicator">
            {currentIndex + 1} / {items.length}
          </div>
        </div>
      </div>

      {/* Inhalts-Bereich mit dynamischem Layout */}
      <div className={`infodisplay-content infodisplay-${layoutType}`}>
        {layoutType === 'text-only' && (
          <div className="infodisplay-text-full">
            <div className="infodisplay-text-content">
              <div
                className="infodisplay-body"
                dangerouslySetInnerHTML={{ __html: current.body || '' }}
              />
            </div>
          </div>
        )}

        {layoutType === 'image-only' && (
          <div className="infodisplay-image-full">
            <img src={current.imageUrl} alt="Information" className="infodisplay-image" />
          </div>
        )}

        {layoutType === 'text-and-image' && (
          <div className="infodisplay-two-column">
            <div className="infodisplay-text-column">
              <div className="infodisplay-text-content">
                <div
                  className="infodisplay-body"
                  dangerouslySetInnerHTML={{ __html: current.body || '' }}
                />
              </div>
            </div>
            <div className="infodisplay-image-column">
              <img src={current.imageUrl} alt="Information" className="infodisplay-image" />
            </div>
          </div>
        )}
      </div>

      {/* Fußzeile mit Navigation */}
      <div className="infodisplay-footer">
        <button
          className="infodisplay-nav-btn"
          onClick={() => setCurrentIndex((prev) => (prev - 1 + items.length) % items.length)}
        >
          ← Zurück
        </button>
        <span className="infodisplay-footer-info">Automatische Rotation: {Math.round(autoRotateInterval / 1000)}s</span>
        <button
          className="infodisplay-nav-btn"
          onClick={() => setCurrentIndex((prev) => (prev + 1) % items.length)}
        >
          Weiter →
        </button>
      </div>
    </div>
  );
}
