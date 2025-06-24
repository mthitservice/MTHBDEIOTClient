import React, { useState, useEffect } from 'react';
import Table from 'react-bootstrap/Table';
import './TableView.css';

import 'bootstrap/dist/css/bootstrap.min.css';
import StatusIndicator from './StatusIndicator';
import moment from 'moment';

interface BdeTask {
  Terminstatus: number;
  PDatum: string;

  AuftrNr: string;
  Anzahl: number;
  Objekt: string;
  Auftraggeber: string;
  Prozessstatus: string;
  Status: string;
}

const bdeTaskKeys: (keyof BdeTask)[] = [
  'Terminstatus',
  'PDatum',

  'AuftrNr',
  'Anzahl',
  'Objekt',
  'Auftraggeber',
  'Prozessstatus',
  'Status',
];

interface TableViewProps {
  Auftraege: BdeTask[] | null;
  itemsPerPage: number | 5;
  showPager: boolean | true;
  onSelectTask?: (task: BdeTask) => void; // <-- Ergänz
}
interface TableViewState {
  ausgewaehlterIndex: number; // Index statt Objekt

  ausgewaehlterAuftrag: BdeTask | null;
  Auftraege: BdeTask[];
  currentPage: number;
}
class TableView extends React.Component<TableViewProps, TableViewState> {
  constructor(props: TableViewProps) {
    super(props);

    this.state = {
      ausgewaehlterIndex: -1,
      ausgewaehlterAuftrag: null,
      Auftraege: this.props.Auftraege || [],
      currentPage: 0,
      itemsPerPage: this.props.itemsPerPage,
      showPager: this.props.showPager,
    };
    this.theTable = this;
  }
  public getSelectedTask = () => {
    const itemsPerPage = this.state.itemsPerPage;
    const startIndex = this.state.currentPage * itemsPerPage;
    const currentData = this.props.Auftraege.slice(
      startIndex,
      startIndex + itemsPerPage,
    );
    return currentData[this.state.ausgewaehlterIndex] || null;
  };

  public handleNext = () => {
    const itemsPerPage = this.state.itemsPerPage;
    const totalPages = Math.ceil(this.props.Auftraege.length / itemsPerPage);
    if (this.state.currentPage < totalPages - 1) {
      this.setState({
        currentPage: this.state.currentPage + 1,
        ausgewaehlterIndex: -1,
      });
    }
  };

  public handlePrev = () => {
    if (this.state.currentPage > 0) {
      this.setState({
        currentPage: this.state.currentPage - 1,
        ausgewaehlterIndex: -1,
      });
    }
  };

  public handleNextTask = () => {
    if (this.state.ausgewaehlterIndex >= this.state.itemsPerPage - 1) return;
    this.setState((prevState) => ({
      ausgewaehlterIndex: Math.min(
        prevState.ausgewaehlterIndex + 1,
        this.props.Auftraege.length - 1,
      ),
    }));
  };

  public handlePrevTask = () => {
    if (this.state.ausgewaehlterIndex <= 0) return;
    this.setState((prevState) => ({
      ausgewaehlterIndex: Math.max(prevState.ausgewaehlterIndex - 1, 0),
    }));
  };
  render() {
    const itemsPerPage = this.state.itemsPerPage;

    const totalPages = Math.ceil(this.props.Auftraege.length / itemsPerPage);
    const { currentPage } = this.state;
    const startIndex = currentPage * itemsPerPage;
    const currentData = this.props.Auftraege.slice(
      startIndex,
      startIndex + itemsPerPage,
    );

    const handleNext = () => {
      console.log('start');
      if (this.state.currentPage < totalPages - 1) {
        console.log('++');
        this.setState({
          currentPage: this.state.currentPage + 1,
          ausgewaehlterIndex: -1,
          ausgewaehlterAuftrag: null,
        });
        if (this.props.onSelectTask) this.props.onSelectTask(null);
      }
    };

    const handlePrev = () => {
      if (this.state.currentPage > 0) {
        this.setState({
          currentPage: this.state.currentPage - 1,
          ausgewaehlterIndex: -1,
          ausgewaehlterAuftrag: null,
        });
        if (this.props.onSelectTask) this.props.onSelectTask(null);
      }
    };
    const handleNextTask = () => {
      const itemsPerPage = this.state.itemsPerPage;
      const startIndex = this.state.currentPage * itemsPerPage;
      const currentData = this.props.Auftraege.slice(
        startIndex,
        startIndex + itemsPerPage,
      );
      console.log(this.state.ausgewaehlterIndex);
      console.log(this.props.itemsPerPage);
      if (this.state.ausgewaehlterIndex >= this.props.itemsPerPage - 1) return;
      const newIndex = this.state.ausgewaehlterIndex + 1;

      this.setState({
        ausgewaehlterIndex: newIndex,
        ausgewaehlterAuftrag: currentData[newIndex] || null,
        ausgewaehlterAuftrag: currentData[newIndex] || null,
      });
      if (this.props.onSelectTask)
        this.props.onSelectTask(currentData[newIndex] || null);
    };
    const handlePrevTask = () => {
      const itemsPerPage = this.state.itemsPerPage;
      const startIndex = this.state.currentPage * itemsPerPage;
      const currentData = this.props.Auftraege.slice(
        startIndex,
        startIndex + itemsPerPage,
      );

      if (this.state.ausgewaehlterIndex <= 0) return;
      const newIndex = this.state.ausgewaehlterIndex - 1;
      this.setState({
        ausgewaehlterIndex: newIndex,
        ausgewaehlterAuftrag: currentData[newIndex] || null,
      });
      if (this.props.onSelectTask)
        this.props.onSelectTask(currentData[newIndex] || null);
      this.props.onSelectTask(currentData[newIndex] || null);
    };

    return (
      <div className="TableViewArea container">
        <Table striped hover>
          <thead>
            <tr>
              {bdeTaskKeys.map((key) => {
                if (
                  key === 'Terminstatus' ||
                  key === 'LDatum' ||
                  key === 'PDatum' ||
                  key === 'AuftrNr' ||
                  key === 'Anzahl'
                ) {
                  return (
                    <th className="bg-orange fc-white col-1" key={key}>
                      {key}
                    </th>
                  );
                } else {
                  return (
                    <th className="bg-orange fc-white col-2" key={key}>
                      {key}
                    </th>
                  );
                }
              })}
            </tr>
          </thead>
          <tbody>
            {currentData.map((task, index) => {
              const globalIndex = +index;
              const isSelected = globalIndex === this.state.ausgewaehlterIndex;
              return (
                <tr
                  key={index}
                  className={`${task.Prozessstatus == 'in Bearbeitung' ? 'blink-blue' : ''} ${
                    isSelected ? 'selected-row' : ''
                  } ${task.Status == 'Problem' ? 'problem' : ''}`}
                  style={{ cursor: 'pointer' }}
                  onClick={() =>
                    this.props.onSelectTask && this.props.onSelectTask(task)
                  } // <-- Ergänzt
                >
                  {bdeTaskKeys.map((col) => {
                    return (
                      <td
                        key={col}
                        className={
                          isSelected
                            ? 'selected-marker row-marker '
                            : 'row-marker'
                        }
                      >
                        {col === 'Terminstatus' ? (
                          <StatusIndicator status={task[col] as number} />
                        ) : col === 'LDatum' ? (
                          <span>{moment(task[col]).format('DD.MM.YYYY')}</span>
                        ) : col === 'PDatum' ? (
                          <span>{moment(task[col]).format('DD.MM.YYYY')}</span>
                        ) : (
                          String(task[col])
                        )}
                      </td>
                    );
                  })}
                </tr>
              );
            })}
          </tbody>
          <tfoot>
            <tr>
              <td colSpan={8}>
                <span className="tblfoot" style={{ margin: '0 1rem' }}>
                  Anzahl Aufträge: {this.props.Auftraege.length} | Seite{' '}
                  {this.state.currentPage + 1} von {totalPages}
                </span>
              </td>
            </tr>
          </tfoot>
        </Table>
        {this.state.showPager && (
          <>
            <div style={{ marginTop: '1rem' }}>
              <button
                onClick={handlePrev}
                disabled={this.state.currentPage === 0}
              >
                Zurück
              </button>
              <span style={{ margin: '0 1rem' }}>
                Seite {this.state.currentPage + 1} von {totalPages}
              </span>
              <button
                onClick={handleNext}
                disabled={this.state.currentPage >= totalPages - 1}
              >
                Weiter
              </button>
            </div>

            <div style={{ marginTop: '1rem' }}>
              <button onClick={handlePrevTask}>
                <i class="bi bi-arrow-up-square-fill"></i> Nach oben
              </button>
              <button onClick={handleNextTask} style={{ marginLeft: '1rem' }}>
                <i class="bi bi-arrow-down-square-fill"></i> Nach unten
              </button>
            </div>
          </>
        )}
      </div>
    );
  }
}

export default TableView;
