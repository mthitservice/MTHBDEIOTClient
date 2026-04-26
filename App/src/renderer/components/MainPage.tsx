import React from 'react';
import Toast from 'react-bootstrap/Toast';
import ToastContainer from 'react-bootstrap/ToastContainer';
import TableView from '../helper/TableView';
import TaskView from '../helper/TaskView';
import dataRaw from '../helper/bde_tasks_test.json';
import LogRaw from '../helper/bde_log_test.json';
import { Layout } from './Layout';
import BarCode from '../helper/BarCode';
import 'bootstrap/dist/css/bootstrap.min.css';
import './MainPage.css';

interface MainPageProps {
  onBarcodeScanned?: (barcode: any) => void;
  navigate?: (path: string) => void;
}

interface ToastMessage {
  id: number;
  text: string;
  timestamp: string;
}

interface MainPageState {
  toasts: ToastMessage[];
  status: string;
  selectedTask: any | null;
  tasks: any[];
  workloadSource: 'portal' | 'local';
}
// Sortiere die Daten nach PDatum (ältestes zuerst)
const fallbackData = [...dataRaw].sort(
  (a, b) => new Date(a.PDatum).getTime() - new Date(b.PDatum).getTime(),
);

function toDateString(value: any): string {
  if (!value) return new Date().toISOString();
  const parsed = new Date(value);
  return Number.isNaN(parsed.getTime()) ? new Date().toISOString() : parsed.toISOString();
}

function mapPortalOrderToTask(order: any) {
  return {
    Terminstatus: Number(order?.Terminstatus ?? order?.dueStatus ?? 0),
    PDatum: toDateString(
      order?.PDatum ||
        order?.plannedProductionTime ||
        order?.plannedProductionUtc ||
        order?.productionDate,
    ),
    LDatum: toDateString(
      order?.LDatum ||
        order?.deliveryDate ||
        order?.deliveryDateUtc ||
        order?.dueDate,
    ),
    AuftrNr: String(order?.AuftrNr || order?.orderNumber || order?.id || ''),
    Anzahl: Number(order?.Anzahl ?? order?.quantity ?? order?.plannedQuantity ?? 0),
    AnzahlGesamt: Number(order?.AnzahlGesamt ?? order?.totalQuantity ?? 0),
    Objekt: order?.Objekt || order?.title || order?.name || '-',
    Auftraggeber: order?.Auftraggeber || order?.customerName || '-',
    Prozessstatus: order?.Prozessstatus || order?.processStatus || '-',
    Status: order?.Status || order?.status || '-',
    Kundennummer: order?.Kundennummer || order?.customerNumber || '-',
    Artikelnummer: order?.Artikelnummer || order?.articleNumber || '-',
    Kundenbetreuer: order?.Kundenbetreuer || order?.accountManager || '-',
    Maschine: order?.Maschine || order?.machineName || '-',
    Anschrift: order?.Anschrift || order?.address || '-',
    PLZ_Ort: order?.PLZ_Ort || order?.city || '-',
    Telefon: order?.Telefon || order?.phone || '-',
    Email: order?.Email || order?.email || '-',
    Ansprechpartner: order?.Ansprechpartner || order?.contactPerson || '-',
    Ersteller: order?.Ersteller || order?.createdBy || '-',
    Beschreibung: order?.Beschreibung || order?.description || '',
  };
}

class MainPage extends React.Component<MainPageProps, MainPageState> {
  buffer: string;

  timeout: NodeJS.Timeout | undefined;

  tableViewRef: any;

  toastIdCounter: number;

  constructor(props: any) {
    super(props);
    this.buffer = '';
    this.timeout = undefined;

    this.toastIdCounter = 0;

    this.tableViewRef = React.createRef();

    this.handleKeyDown = this.handleKeyDown.bind(this);
    this.handleBarcodeEvent = this.handleBarcodeEvent.bind(this);

    this.addToast = this.addToast.bind(this);

    this.state = {
      toasts: [],
      status: 'start',
      selectedTask: null,
      tasks: fallbackData,
      workloadSource: 'local',
    };
  }

  async componentDidMount() {
    document.body.addEventListener('keydown', this.handleKeyDown, true);
    document.addEventListener('barcode-scan-complete', this.handleBarcodeEvent);
    await this.loadWorkloadFromPortal();
  }

  componentWillUnmount() {
    document.body.removeEventListener('keydown', this.handleKeyDown, true);
    document.removeEventListener(
      'barcode-scan-complete',
      this.handleBarcodeEvent,
    );
  }

  handleBarcodeEvent(e: any) {
    console.log('Barcode erkannt:', e.detail);

    // Automatische Aktionen basierend auf Barcode
    const barcode = e.detail?.value || e.detail;
    if (barcode) {
      this.handleBarcodeAction(barcode);
    }

    if (this.props.onBarcodeScanned) {
      this.props.onBarcodeScanned(e.detail);
    }
  }

  handleBarcodeAction = (code: string) => {
    // Automatische Aktionen basierend auf Barcode
    switch (code) {
      case '000001': {
        // Zurück (nur im start-Status)
        if (this.state.status === 'start') {
          this.handleGoPrev();
        }
        break;
      }

      case '000002': {
        // Vor (nur im start-Status)
        if (this.state.status === 'start') {
          this.handleGoNext();
        }
        break;
      }

      case '000003': {
        // Liste nach oben (nur im function-Status)
        if (this.state.status === 'function') {
          this.handleGoUp();
        }
        break;
      }

      case '000004': {
        // Liste nach unten (nur im function-Status)
        if (this.state.status === 'function') {
          this.handleGoDown();
        }
        break;
      }

      case '000005': {
        // Auftrag scannen
        this.handleGoScan();
        break;
      }

      case '000006': {
        // Standard Funktionen (nur im function-Status)
        if (this.state.status === 'function') {
          this.handleGoFunction();
        }
        break;
      }

      case '000007': {
        // Weitere Funktionen (nur im start-Status)
        if (this.state.status === 'start') {
          this.handleGoFunction();
        }
        break;
      }

      case '000008': {
        // Auftrag auswählen (nur im function-Status)
        if (this.state.status === 'function') {
          this.handleGoTask();
        }
        break;
      }

      case '000009': {
        // Zurück zur Liste (nur wenn selectedTask vorhanden)
        if (this.state.selectedTask) {
          this.handleBackToList();
        }
        break;
      }

      default: {
        // Prüfen ob es eine Auftragsnummer ist (ab 6-stellig)
        if (/^\d{6,}$/.test(code)) {
          this.addToast(`Auftragsnummer gescannt: ${code}`);
          // Hier könnte weitere Logik für Auftragsnummern implementiert werden
        } else {
          this.addToast(`Unbekannter Barcode: ${code}`);
        }
        break;
      }
    }
  };

  handleKeyDown(e: any) {
    if (e.key.length > 1 && e.key !== 'Enter') return;

    if (e.key === 'Enter') {
      const trimmed = this.buffer.trim();

      if (/^\d{6,}$/.test(trimmed)) {
        const event = new CustomEvent('barcode-scan-complete', {
          detail: { type: 'auftragsnummer', value: trimmed },
        });
        document.dispatchEvent(event);
      } else if (/^\d{2}$/.test(trimmed)) {
        const event = new CustomEvent('barcode-scan-complete', {
          detail: { type: '2-digit', value: trimmed },
        });
        document.dispatchEvent(event);
      } else {
        console.warn('Ungültiger Barcode:', trimmed);
      }

      this.buffer = '';
      return;
    }

    this.buffer += e.key;

    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      this.buffer = '';
    }, 1000);
  }

  addToast(message: string) {
    const newToast: ToastMessage = {
      id: this.toastIdCounter++,
      text: message,
      timestamp: new Date().toLocaleTimeString(),
    };

    this.setState((prevState) => ({
      toasts: [...prevState.toasts, newToast],
    })); // Optional: Toast nach 5 Sekunden automatisch entfernen

    setTimeout(() => {
      this.setState((prevState) => ({
        toasts: prevState.toasts.filter((t) => t.id !== newToast.id),
      }));
    }, 5000);
  }

  loadWorkloadFromPortal = async () => {
    try {
      const config = await window.electron.dbConfig.readAllConfig();
      const configList = Array.isArray(config) ? config : [];
      const clientIdentifier =
        configList.find((item: any) => item.key === 'clientIdentifier')?.value ||
        configList.find((item: any) => item.key === 'deviceName')?.value;

      if (!clientIdentifier) {
        this.addToast('Kein clientIdentifier konfiguriert. Verwende lokale Testdaten.');
        return;
      }

      const response = await window.electron.portalApi.getWorkload(clientIdentifier, 1, 100);
      const orders = Array.isArray(response?.Orders) ? response.Orders : [];

      if (orders.length === 0) {
        this.addToast('Portal verbunden, aber keine Aufträge für diesen Client gefunden.');
        this.setState({ tasks: [], workloadSource: 'portal' });
        return;
      }

      const mapped = orders
        .map(mapPortalOrderToTask)
        .sort((a: any, b: any) => new Date(a.PDatum).getTime() - new Date(b.PDatum).getTime());

      this.setState({ tasks: mapped, workloadSource: 'portal' });
      this.addToast(`Portal-Aufträge geladen: ${mapped.length}`);
    } catch (error) {
      console.error('Portal-Workload konnte nicht geladen werden:', error);
      this.addToast('Portal nicht erreichbar. Verwende lokale Testdaten.');
    }
  };

  handleGoNext = () => {
    console.log('Next');
    this.tableViewRef.current?.handleNext();
  };

  handleGoPrev = () => {
    console.log('Prev');
    this.tableViewRef.current?.handlePrev();
  };

  handleGoUp = () => {
    console.log('Up');
    this.tableViewRef.current?.handlePrevTask();
  };

  handleGoDown = () => {
    console.log('Down');
    this.tableViewRef.current?.handleNextTask();
  };

  handleGoScan = () => {
    if (this.props.navigate) {
      this.props.navigate('/scan');
    }
  };

  handleGoFunction = () => {
    if (this.state.status === 'start') {
      // zurück zu Start
      this.setState({ status: 'function', selectedTask: null });
    } else {
      this.setState({ status: 'start' });
    }
  };

  handleGoTask = () => {
    // Auftrag auswählen: Hole den aktuell markierten Auftrag aus TableView
    const selected = this.tableViewRef.current?.getSelectedTask();
    if (selected) {
      this.setState({ selectedTask: selected });
    } else {
      // Optional: Hinweis, wenn kein Auftrag markiert ist
      this.addToast('Bitte zuerst einen Auftrag in der Liste markieren.');
    }
  };

  handleSelectTask = (task: any) => {
    this.setState({ selectedTask: task });
  };

  handleBackToList = () => {
    this.setState({ selectedTask: null });
  };

  render() {
    const { selectedTask, tasks, workloadSource } = this.state;
    return (
      <div>
        <Layout>
          <div className="MainPage">
            <ToastContainer
              position="top-end"
              style={{ margin: 20, zIndex: 9999 }}
            >
                           {' '}
              {this.state.toasts.map((toast) => (
                <Toast key={toast.id} bg="light">
                                   {' '}
                  <Toast.Header className="bg-warning" closeButton={false}>
                                       {' '}
                    <strong className="me-auto fc-white">Information</strong>
                                        <small>{toast.timestamp}</small>
                                     {' '}
                  </Toast.Header>
                                    <Toast.Body>{toast.text}</Toast.Body>
                                 {' '}
                </Toast>
              ))}
                         {' '}
            </ToastContainer>
            {!selectedTask && <h2>Auftragsübersicht</h2>}
            {!selectedTask && (
              <p className="text-muted">
                Datenquelle: {workloadSource === 'portal' ? 'Portal API' : 'Lokale Testdaten'}
              </p>
            )}

            <div>
              <div className="row MainPageCodeArea">
                {selectedTask ? (
                  <>
                    <TaskView Task={selectedTask} LogData={LogRaw} />
                    <div className="row MainPageBarcodeArea">
                      <div className="col-sm">
                        <BarCode
                          code="000009"
                          text={
                            <>
                              <i className="bi bi-arrow-left-square-fill" />{' '}
                              Zurück zur Liste
                            </>
                          }
                          onClick={this.handleBackToList}
                        />
                      </div>
                    </div>
                  </>
                ) : (
                  <>
                    <TableView
                      ref={this.tableViewRef}
                      Auftraege={tasks}
                      itemsPerPage={13}
                      showPager={false}
                      onSelectTask={this.handleSelectTask}
                    />
                    {this.state.status === 'start' && (
                      <div className="row MainPageBarcodeArea">
                        <div className="col-sm">
                          <BarCode
                            code="000005"
                            text={
                              <>
                                <i className="bi bi-upc-scan" /> Auftrag scannen
                              </>
                            }
                            onClick={this.handleGoScan}
                          />
                        </div>
                        <div className="col-sm">
                          <BarCode
                            code="000007"
                            text={
                              <>
                                <i className="bi bi-briefcase-fill" /> weitere
                                Funktionen
                              </>
                            }
                            onClick={this.handleGoFunction}
                          />
                        </div>
                        <div className="col-sm">
                          <BarCode
                            code="000001"
                            text={
                              <>
                                <i className="bi bi-arrow-left-square-fill" />{' '}
                                Zurück
                              </>
                            }
                            onClick={this.handleGoPrev}
                          />
                        </div>
                        <div className="col-sm">
                          <BarCode
                            code="000002"
                            text={
                              <>
                                <i className="bi bi-arrow-right-square-fill" />{' '}
                                Vor
                              </>
                            }
                            onClick={this.handleGoNext}
                          />
                        </div>
                      </div>
                    )}
                    {this.state.status === 'function' && (
                      <div className="row MainPageBarcodeArea">
                        <div className="col-sm">
                          <BarCode
                            code="000008"
                            text={
                              <>
                                <i className="bi bi-border-style" /> Auftrag
                                auswählen
                              </>
                            }
                            onClick={this.handleGoTask}
                          />
                        </div>
                        <div className="col-sm">
                          <BarCode
                            code="000006"
                            text={
                              <>
                                <i className="bi bi-briefcase-fill" /> Standard
                                Funktionen
                              </>
                            }
                            onClick={this.handleGoFunction}
                          />
                        </div>
                        <div className="col-sm">
                          <BarCode
                            code="000003"
                            text={
                              <>
                                <i className="bi bi-arrow-up-square-fill" />{' '}
                                Liste nach oben
                              </>
                            }
                            onClick={this.handleGoUp}
                          />
                        </div>
                        <div className="col-sm">
                          <BarCode
                            code="000004"
                            text={
                              <>
                                <i className="bi bi-arrow-down-square-fill" />{' '}
                                Liste nach unten
                              </>
                            }
                            onClick={this.handleGoDown}
                          />
                        </div>
                      </div>
                    )}
                  </>
                )}
              </div>
            </div>
          </div>
        </Layout>
      </div>
    );
  }
}

export default MainPage;
