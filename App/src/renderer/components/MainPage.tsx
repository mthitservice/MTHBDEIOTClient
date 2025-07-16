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
}
// Sortiere die Daten nach PDatum (ältestes zuerst)
const data = [...dataRaw].sort(
  (a, b) => new Date(a.PDatum).getTime() - new Date(b.PDatum).getTime(),
);

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
    };
  }

  componentDidMount() {
    document.body.addEventListener('keydown', this.handleKeyDown, true);
    document.addEventListener('barcode-scan-complete', this.handleBarcodeEvent);
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
    if (this.props.onBarcodeScanned) {
      this.props.onBarcodeScanned(e.detail);
    }
  }

  handleKeyDown(e: any) {
    if (e.key.length > 1 && e.key !== 'Enter') return;

    if (e.key === 'Enter') {
      const trimmed = this.buffer.trim();

      if (/^\d{6}$/.test(trimmed)) {
        this.addToast('Barcode:' + trimmed);
        const event = new CustomEvent('barcode-scan-complete', {
          detail: { type: '6-digit', value: trimmed },
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
    const { selectedTask } = this.state;
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
                              <i className="bi bi-arrow-left-square-fill"></i>{' '}
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
                      Auftraege={data}
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
                                <i className="bi bi-upc-scan"></i> Auftrag
                                scannen
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
                                <i className="bi bi-briefcase-fill"></i> weitere
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
                                <i className="bi bi-arrow-left-square-fill"></i>{' '}
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
                                <i className="bi bi-arrow-right-square-fill"></i>{' '}
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
                                <i className="bi bi-border-style"></i> Auftrag
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
                                <i className="bi bi-briefcase-fill"></i>{' '}
                                Standard Funktionen
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
                                <i className="bi bi-arrow-up-square-fill"></i>{' '}
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
                                <i className="bi bi-arrow-down-square-fill"></i>{' '}
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
