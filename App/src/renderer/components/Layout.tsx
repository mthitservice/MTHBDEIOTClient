// src/components/Layout.tsx
import React from 'react';
import DateTime from '../helper/DateTime';
import icon from '../../../assets/icon.svg';
import 'bootstrap/dist/css/bootstrap.min.css';
import 'bootstrap-icons/font/bootstrap-icons.css';

export const Layout: React.FC<{ children: React.ReactNode }> = ({
  children,
}) => {
  return (
    <div className="d-flex flex-column min-vh-100">
      {/* Kopfzeile */}
      <header>
        <div className="bg-orange container-fluid py-2 ">
          <div className="row text-center text-md-start">&nbsp;</div>
        </div>
        <div className="bg-orange-soft container-fluid py-2 ">
          <div className="row text-center text-md-end">
            <div className="col-md-1">
              <img width="35px" alt="icon" src={icon} />
            </div>
            <div className="col-md-2 text-md-start">
              <b>Weiterverarbeitung</b>
            </div>
            <div className="col-md-2 text-md-center">
              geplante Zeit: <strong>00:00 h</strong>
            </div>
            <div className="col-md-2 text-md-center">
              Druckzeit: <strong>00:00 h</strong>
            </div>
            <div className="col-md-2 text-md-center">
              frei ab: <b>01.01.2026</b>
            </div>
            <div className="col-md-2 text-md-end">
              <i
                className="bi bi-person"
                style={{ fontSize: '16px', color: 'black' }}
              >
                {' '}
              </i>{' '}
              <b>User01</b>
            </div>
          </div>
        </div>
      </header>

      {/* Hauptinhalt */}
      <main className="flex-fill container ">{children}</main>

      {/* Fußzeile */}
      <footer className="bg-orange-soft py-2 border-top mt-auto bde-header">
        <div className="container-fluid">
          <div className="row text-center text-md-start">
            <div className="col-md-3">©MTH-IT-SERVICE</div>
            <div className="col-md-3 text-center">
              letzte Aktion: 01.01.2025 00:00:00
            </div>
            <div className="col-md-3 text-md-center">IOT-Gerät: BDE01</div>
            <div className="col-md-2 text-end">
              <i className="bi bi-clock"> </i>
              <DateTime />
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
};
