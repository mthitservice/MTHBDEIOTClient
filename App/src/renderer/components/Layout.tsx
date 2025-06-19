// src/components/Layout.tsx
import React from 'react';
import icon from '../../../assets/icon.svg';
import 'bootstrap/dist/css/bootstrap.min.css';
import 'bootstrap-icons/font/bootstrap-icons.css';
import '../App.css';

export const Layout: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  return (
    <div className="d-flex flex-column min-vh-100">
      {/* Kopfzeile */}
      <header className="bg-orange py-2 ">
        <div className="container-fluid">
          <div className="row text-center text-md-start">&nbsp;</div>
        </div>
      </header>
      <header className="bg-orange-soft py-2 border-bottom bde-header">
        <div className="container-fluid">
          <div className="row text-center text-md-end">
            <div className="col-md-1">
              <img width="35px" alt="icon" src={icon} />
            </div>
            <div className="col-md-2 text-md-start">
              <b>Weiterverarbeitung</b>
            </div>
            <div className="col-md-2 text-md-begin">
              geplante Zeit: <strong>00:00 h</strong>
            </div>
            <div className="col-md-2 text-md-begin">
              Druckzeit: <strong>00:00 h</strong>
            </div>
            <div className="col-md-2 text-md-begin">
              frei ab: <b>01.01.2026</b>
            </div>
            <div className="col-md-1 text-md-begin">
              <i
                className="bi bi-person"
                style={{ fontSize: '16px', color: 'black' }}
              >
                {' '}
              </i>{' '}
              <b>User01</b>
            </div>
            <div className="col-md-2 text-center">
              <i
                className="bi bi-clock"
                style={{ fontSize: '16px', color: 'black' }}
              >
                {' '}
              </i>
              01.01.2025 00:00:00
            </div>
          </div>
        </div>
      </header>

      {/* Hauptinhalt */}
      <main className="flex-fill container py-4">{children}</main>

      {/* Fußzeile */}
      <footer className="bg-orange-soft py-2 border-top mt-auto bde-header">
        <div className="container-fluid">
          <div className="row text-center text-md-start">
            <div className="col-md-4">©MTH-IT-SERVICE</div>
            <div className="col-md-4 text-center">
              letzte Aktion: 01.01.2025 00:00:00
            </div>
            <div className="col-md-4 text-md-end">IOT-Gerät: BDE01</div>
          </div>
        </div>
      </footer>
    </div>
  );
};
