import React from 'react';
import moment from 'moment';
import './TaskView.css';
import 'bootstrap/dist/css/bootstrap.min.css';

interface TaskViewProps {
  Task: TaskDetails | null;
  LogData?: LogDetails[];
}
interface TaskDetails {
  id: string;
  AuftrNr: string;
  LDatum: string;
  PDatum: string;
  Objekt: string;
  Status: string;
  Prozessstatus: string;
  Auftraggeber: string;
  Auflage: string;
  Liefermenge: string;
  Terminstatus: string;
  Typ: string;
  Kundennummer: string;
  Artikelnummer: string;
  Kundenbetreuer: string;
  Maschine: string;
  Anschrift: string;
  PLZ_Ort: string;
  Telefon: string;
  Telefax: string;
  Email: string;
  Ansprechpartner: string;
}

interface LogDetails {
  ID: string;
  Datum: string;
  Schritt: string;
  Status: string;
  Bearbeiter: string;
  Info: string;
}

const TaskView: React.FC<TaskViewProps> = ({ Task, LogData }) => {
  if (!Task) {
    return (
      <div className="TaskViewArea container mt-4">
        <div className="alert alert-info">Kein Auftrag ausgewählt.</div>
      </div>
    );
  }
  // Datumsfelder mit moment formatieren
  const liefertermin = Task.LDatum
    ? moment(Task.LDatum).format('DD.MM.YYYY')
    : '';
  const produktionsdatum = Task.PDatum
    ? moment(Task.PDatum).format('DD.MM.YYYY')
    : '';

  // Alle Felder als Array für dynamische Darstellung
  const details = [
    { label: 'Auftragsnummer', value: Task.AuftrNr },
    { label: 'Liefertermin', value: liefertermin },
    { label: 'Produktionsdatum', value: produktionsdatum },
    { label: 'Auflage', value: Task.Anzahl },
    { label: 'Auflagegesamt', value: Task.AnzahlGesamt },
    { label: 'Kundennummer', value: Task.Kundennummer },
    { label: 'Artikelnummer', value: Task.Artikelnummer },
    { label: 'Kundenbetreuer', value: Task.Kundenbetreuer },
    { label: 'Maschine', value: Task.Maschine },
    { label: 'Auftraggeber', value: Task.Auftraggeber },
    { label: 'Anschrift', value: Task.Anschrift },
    { label: 'PLZ/Ort', value: Task.PLZ_Ort },
    { label: 'Telefon', value: Task.Telefon },

    { label: 'Email', value: Task.Email },
    { label: 'Ansprechpartner', value: Task.Ansprechpartner },
    { label: 'Ersteller', value: Task.Ersteller },
  ];

  // In 2er-Gruppen für 2 Felder pro Zeile aufteilen
  const rows = [];
  for (let i = 0; i < details.length; i += 2) {
    rows.push(details.slice(i, i + 2));
  }

  return (
    <div className="TaskViewArea container">
      <h2 className="">Auftragsdetails</h2>
      <div style={{ overflowX: 'auto' }}>
        <table className="table table-nobordered table-striped">
          <tbody>
            {rows.map((row, idx) => (
              <tr key={idx}>
                {/* Erstes Feld */}
                <th
                  className={
                    row[0].label == 'Auftragsnummer' ||
                    row[0].label == 'Produktionsdatum'
                      ? 'text-md-end TaskNr p-2'
                      : 'text-md-end  p-2'
                  }
                  style={{ width: '10%' }}
                >
                  {row[0]?.label}
                </th>
                <td
                  className={
                    row[0].label == 'Auftragsnummer' ||
                    row[0].label == 'Produktionsdatum'
                      ? 'text-md-start TaskNr p-2'
                      : 'text-md-start p-2'
                  }
                  style={{ width: '20%' }}
                >
                  {row[0]?.value}
                </td>
                {/* Leere Spalte ohne Rahmen/Linien */}
                <td className="noborder-cell"></td>
                {/* Zweites Feld */}
                {row[1] ? (
                  <>
                    <th
                      className={
                        row[1].label == 'Auftragsnummer' ||
                        row[1].label == 'Produktionsdatum'
                          ? 'text-md-end TaskNr p-2'
                          : 'text-md-end p-2'
                      }
                      style={{ width: '10%' }}
                    >
                      {row[1].label}
                    </th>
                    <td style={{ width: '20%' }}>{row[1].value}</td>
                  </>
                ) : (
                  <>
                    <th style={{ width: '10%' }}></th>
                    <td style={{ width: '20%' }}></td>
                  </>
                )}
                {/* Rechte Objekt-Spalte nur beim ersten Row mit Rowspan */}
                {idx === 0 && (
                  <td
                    rowSpan={rows.length}
                    style={{
                      minWidth: 180,
                      maxWidth: 300,
                      verticalAlign: 'top',
                      background: '#fffbe6',
                      fontWeight: 'bold',
                      textAlign: 'left',
                      borderLeft: '2px solid #ff8800',
                    }}
                  >
                    <div style={{ padding: 8 }}>
                      <div
                        style={{
                          color: '#ff8800',
                          fontSize: 16,
                          marginBottom: 8,
                        }}
                      >
                        Objekt
                      </div>
                      <div style={{ whiteSpace: 'pre-line' }}>
                        {Task.Objekt}
                      </div>
                    </div>
                  </td>
                )}
              </tr>
            ))}
            <tr>
              <td
                className={Task.Beschreibung ? 'TaskWarning' : ''}
                colSpan={5}
                style={{
                  textAlign: 'center',
                }}
              >
                {Task.Beschreibung
                  ? Task.Beschreibung
                  : 'Keine Beschreibung vorhanden.'}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      {/* Log-Tabelle unterhalb */}
      {LogData && LogData.length > 0 && (
        <div className="mt-1">
          <table className="table table-no-bordered table-striped ">
            <thead>
              <tr>
                <th>Datum</th>
                <th>Schritt</th>
                <th>Status</th>
                <th>Bearbeiter</th>
                <th>Info</th>
              </tr>
            </thead>
            <tbody>
              {LogData.map((log) => (
                <tr key={log.ID}>
                  <td>{log.Datum}</td>
                  <td>{log.Schritt}</td>
                  <td>{log.Status}</td>
                  <td>{log.Bearbeiter}</td>
                  <td>{log.Info}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
};

export default TaskView;
