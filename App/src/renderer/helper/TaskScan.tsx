import React from 'react';
import moment from 'moment';
import BarCode from '../helper/BarCode';
import './TaskView.css';
import 'bootstrap/dist/css/bootstrap.min.css';

interface TaskScanProps {
  barcode: string | null;
  onBack: () => void;
  onBarcodeAction?: (code: string) => void; // <-- NEU
}
interface TaskDetails {
  AuftrNr: string;
  LDatum: string;
  PDatum: string;
  Objekt: string;
  Status: string;
  Prozessstatus: string;
  Auftraggeber: string;
  Anzahl: string;
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

const TaskScan: React.FC<TaskScanProps> = (props) => {
  const Task = {
    Terminstatus: 0,
    LDatum: '2025-09-15',
    AuftrNr: '1281985',
    Anzahl: 522494,
    Objekt: 'Einzelblätter - Satz STS                          ',
    Auftraggeber: 'Rowe-Roth',
    Prozessstatus: 'nicht begonnen',
    Status: 'Problem',
    PDatum: '2025-08-14',
    Kundennummer: '12345',
    Kundenbetreuer: 'Testbetreuer 1',
    Maschine: '654321',
    Beschreibung:
      'Der Auftrag kann durchgeführt werden. Auch wenn es hier  Probleme gibt, ist der Auftrag nicht in Gefahr. Es muss aber ein neues Projekt angelegt werden welches dazu führt ....',
  } as TaskDetails; // Beispiel-Task, hier sollte die Logik zum Abrufen des Tasks stehen
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

    { label: 'Kundennummer', value: Task.Kundennummer },
    { label: 'Artikelnummer', value: Task.Artikelnummer },
    { label: 'Kundenbetreuer', value: Task.Kundenbetreuer },
    { label: 'Maschine', value: Task.Maschine },
    { label: 'Auftraggeber', value: Task.Auftraggeber },
    { label: 'Anschrift', value: Task.Anschrift },
    { label: 'PLZ/Ort', value: Task.PLZ_Ort },
    { label: 'Telefon', value: Task.Telefon },
    { label: 'Telefax', value: Task.Telefax },
    { label: 'Email', value: Task.Email },
    { label: 'Ansprechpartner', value: Task.Ansprechpartner },
  ];

  // In 2er-Gruppen für 2 Felder pro Zeile aufteilen
  const rows = [];
  for (let i = 0; i < details.length; i += 2) {
    rows.push(details.slice(i, i + 2));
  }
  const handleBarcodeClick = (code: string) => {
    if (props.onBarcodeAction) {
      props.onBarcodeAction(code);
    }
    if (code === '000006' && props.onBack) {
      props.onBack();
    }
  };
  return (
    <div className="TaskViewArea container mt-4">
      <h2 className="mb-4">Auftragsdetails</h2>
      <table className="table table-nobordered table-striped">
        <tbody>
          {rows.map((row, idx) => (
            <tr key={idx}>
              {/* Erstes Feld */}
              <th
                className={
                  row[0].label == 'Auftragsnummer'
                    ? 'text-md-end TaskNr'
                    : 'text-md-end'
                }
                style={{ width: '10%' }}
              >
                {row[0]?.label}
              </th>
              <td
                className={
                  row[0].label == 'Auftragsnummer'
                    ? 'text-md-start TaskNr'
                    : 'text-md-start'
                }
                style={{ width: '30%' }}
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
                      row[1].label == 'Auftragsnummer'
                        ? 'text-md-end TaskNr'
                        : 'text-md-end '
                    }
                    style={{ width: '10%' }}
                  >
                    {row[1].label}
                  </th>
                  <td style={{ width: '30%' }}>{row[1].value}</td>
                </>
              ) : (
                <>
                  <th style={{ width: '10%' }}></th>
                  <td style={{ width: '30%' }}></td>
                </>
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
      <div className="row MainPageBarcodeArea">
        <div className="col-sm">
          <BarCode
            code="000001"
            text={
              <>
                <i className="bi bi-border-style"></i> Auftrag starten
              </>
            }
            onClick={() => handleBarcodeClick('000001')}
          />
        </div>
        <div className="col-sm">
          <BarCode
            code="00002"
            text={
              <>
                <i className="bi bi-border-style"></i> Auftrag beenden
              </>
            }
            onClick={() => handleBarcodeClick('000002')}
          />
        </div>
        <div className="col-sm">
          <BarCode
            code="000003"
            text={
              <>
                <i className="bi bi-border-style"></i> Problem melden
              </>
            }
            onClick={() => handleBarcodeClick('000003')}
          />
        </div>
        <div className="col-sm">
          <BarCode
            code="000006"
            text={
              <>
                <i className="bi bi-briefcase-fill"></i> Abbrechen
              </>
            }
            onClick={() => handleBarcodeClick('000006')}
          />
        </div>
      </div>
    </div>
  );
};

export default TaskScan;
