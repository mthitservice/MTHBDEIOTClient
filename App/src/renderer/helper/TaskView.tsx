import React from 'react';
import moment from 'moment';
import './TaskView.css';
import 'bootstrap/dist/css/bootstrap.min.css';

interface TaskViewProps {
  Task: TaskDetails | null;
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

const TaskView: React.FC<TaskViewProps> = ({ Task }) => {
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

  return (
    <div className="TaskViewArea container mt-4">
      <h2 className="mb-4">Auftragsdetails</h2>
      <table className="table table-nobordered table-striped">
        <tbody>
          {rows.map((row, idx) => (
            <tr key={idx}>
              {/* Erstes Feld */}
              <th className="text-md-end" style={{ width: '10%' }}>
                {row[0]?.label}
              </th>
              <td style={{ width: '30%' }}>{row[0]?.value}</td>
              {/* Leere Spalte ohne Rahmen/Linien */}
              <td className="noborder-cell"></td>
              {/* Zweites Feld */}
              {row[1] ? (
                <>
                  <th className="text-md-end" style={{ width: '10%' }}>
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
  );
};

export default TaskView;
