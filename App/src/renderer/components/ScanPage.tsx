import React, { useState, useEffect, useRef } from 'react';
// ...deine weiteren Imports...

import { useNavigate } from 'react-router-dom';
import icon from '../../../assets/images/mthuabdedsbarcodescanner.png';
import mthlogo from '../../../assets/images/mthitservicelogo.png';
import { Layout } from './Layout';
import Form from 'react-bootstrap/Form';
import Toast from 'react-bootstrap/Toast';
import UserSelect from '../helper/UserSelect';
import ToastContainer from 'react-bootstrap/ToastContainer';

import TaskScan from '../helper/TaskScan';
import './ScanPage.css';

type Env = {
  APP_NAME: string;
  APP_VERSION: string;
  APP_COPYRIGHT: string;
  APP_AUTHOR: string;
  APP_LICENSE: string;
  APP_DESCRIPTION: string;
};

export function ScanPage() {
  const router = useNavigate();
  const [name, setName] = useState<Env | null>(null);
  const [validated, setValidated] = useState(false);
  const [config, setConfig] = useState<any | null>(null);
  const [counter, setCounter] = useState(60); // 60 Sekunden Countdown
  const timerRef = useRef<NodeJS.Timeout | null>(null);
  const inputRef = useRef<HTMLInputElement>(null);
  const [barcode, setBarcode] = useState<string>('');
  const [showTaskScan, setShowTaskScan] = useState(false);
  const [showUserSelect, setShowUserSelect] = useState(false);
  const [selectedUser, setSelectedUser] = useState<any>(null);

  const [toast, setToast] = useState<{
    show: boolean;
    msg: string;
    timestamp: string;
  }>({
    show: false,
    msg: '',
    timestamp: new Date().toLocaleTimeString(),
  });

  const focusInput = () => {
    inputRef.current && inputRef.current.focus();
  };

  // Fokus nach jedem Render und bei User-Activity
  useEffect(() => {
    focusInput();
  });

  useEffect(() => {
    window.electron.dbConfig
      .getInitialConfig()
      .then((res: any) => {
        console.log('Initial config:', res);

        setConfig(res);
      })
      .catch((err: any) => {
        console.error('Error fetching initial config:', err);
      });
  }, []);
  useEffect(() => {
    window.electron
      .getEnv()
      .then((res) => {
        setName(res);
        return res;
      })
      .catch((err) => {
        console.error('Error fetching environment variables:', err);
      });
  }, []);
  useEffect(() => {
    // Timer nur starten, wenn TaskScan NICHT angezeigt wird
    if (!showTaskScan) {
      timerRef.current = setInterval(() => {
        setCounter((prev) => prev - 1);
      }, 1000);
    }

    // Timer stoppen, wenn TaskScan angezeigt wird oder beim Unmount
    return () => {
      if (timerRef.current) {
        clearInterval(timerRef.current);
        timerRef.current = null;
      }
    };
  }, [showTaskScan]); // <--- showTaskScan als Dependency

  // Bei Ablauf des Counters automatisch weiterleiten
  useEffect(() => {
    if (counter <= 0) {
      router('/main');
    }
  }, [counter, router]);

  // Reset bei Eingabe oder Scan
  const handleUserActivity = () => {
    setCounter(60);
    focusInput();
  };

  useEffect(() => {
    // Keydown für Scan/Eingabe
    const handleKeyDown = (e: KeyboardEvent) => {
      handleUserActivity();
      // Wenn Enter gedrückt wird, TaskScan anzeigen
      if (e.key === 'Enter' && inputRef.current) {
        setBarcode(inputRef.current.value);
        setShowTaskScan(true);
      }
    };
    // Input für Textboxen
    const handleInput = (e: Event) => {
      handleUserActivity();
    };

    window.addEventListener('keydown', handleKeyDown);
    window.addEventListener('input', handleInput);

    return () => {
      window.removeEventListener('keydown', handleKeyDown);
      window.removeEventListener('input', handleInput);
    };
  }, []);

  const handleSubmit = (event: any) => {
    const form = event.currentTarget;
    if (form.checkValidity() === false) {
      event.preventDefault();
      event.stopPropagation();
    } else {
      event.preventDefault();
      // Hier ggf. weitere Logik
    }
    setValidated(true);
  };
  // Usenavigate to redirect to the page
  const handleBackToScan = () => {
    setShowTaskScan(false);
    setBarcode('');
    setTimeout(() => focusInput(), 100);
  };

  const handleBarcodeAction = (code: string) => {
    setToast({
      show: true,
      msg: `Barcode-Aktion: ${code}`,
      timestamp: new Date().toLocaleTimeString(),
    });
    if (code === '000001') {
      setShowUserSelect(true); // Userauswahl anzeigen
    } else if (code === '000006') {
      router('/main');
    }
  };

  // Barcode-Aktionen aus UserSelect
  const handleUserSelectBarcode = (code: string) => {
    if (code === '000010') {
      // Weiter zum Auftrag starten
      setShowUserSelect(false);
      setShowTaskScan(false);
      setToast({
        show: true,
        msg: `Auftrag wird für ${selectedUser?.Name || 'unbekannt'} gestartet!`,
        timestamp: new Date().toLocaleTimeString(),
      });
      // Hier ggf. weitere Logik für Auftragsstart
    } else if (code === '000011') {
      // Zurück zu TaskScan
      setShowUserSelect(false);
    }
  };

  // User-Auswahl aus UserSelect
  const handleUserSelect = (user: any) => {
    setSelectedUser(user);
    setToast({
      show: true,
      msg: `Mitarbeiter ausgewählt: ${user.Name}`,
      timestamp: new Date().toLocaleTimeString(),
    });
  };

  return (
    <>
      <ToastContainer position="top-end" style={{ margin: 20, zIndex: 9999 }}>
                     {' '}
        <Toast
          key={toast.id}
          onClose={() => setToast({ ...toast, show: false })}
          show={toast.show}
          delay={5000}
          autohide
          style={{ width: '300px', marginTop: '10px' }}
        >
                           {' '}
          <Toast.Header className="bg-warning" closeButton={false}>
                               {' '}
            <strong className="me-auto fc-white">Information</strong>
                                <small>{toast.timestamp}</small>
                             {' '}
          </Toast.Header>
                            <Toast.Body>{toast.msg}</Toast.Body>
                         {' '}
        </Toast>
                   {' '}
      </ToastContainer>
      <Layout>
        {' '}
        {!showTaskScan && !showUserSelect ? (
          <div className="ScanPage container row ">
            <div className="col text-md-end">
              <img alt="icon" src={icon} />
            </div>
            <div className="col text-md-start">
              <Form noValidate validated={validated} onSubmit={handleSubmit}>
                <fieldset>
                  <Form.Group className="mb-3">
                    <h2>Bitte Auftragstasche scannen...</h2>
                    <Form.Control
                      id="Barcode"
                      placeholder="..."
                      required
                      ref={inputRef}
                      autoFocus
                    />
                    <Form.Control.Feedback type="invalid">
                      Auftragsnummer erforderlich
                    </Form.Control.Feedback>
                    <div
                      className="text-md-center"
                      style={{ fontSize: 18, marginBottom: 8, marginTop: 12 }}
                    >
                      Automatische Rückkehr in: <b>{counter}</b> Sekunden
                    </div>
                  </Form.Group>
                </fieldset>
              </Form>
            </div>
            <div className="col text-md-end">
              <img alt="icon" src={mthlogo} />
            </div>
          </div>
        ) : showTaskScan && !showUserSelect ? (
          <TaskScan
            barcode={barcode}
            onBack={handleBackToScan}
            onBarcodeAction={handleBarcodeAction}
          />
        ) : (
          <UserSelect
            onUserSelect={handleUserSelect}
            onBarcodeAction={handleUserSelectBarcode}
            selectedUser={selectedUser}
          />
        )}
      </Layout>
    </>
  );
}
export default ScanPage;
