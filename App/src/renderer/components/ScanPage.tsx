import React, { useState, useEffect, useRef, useCallback } from 'react';
// ...deine weiteren Imports...

import { useNavigate } from 'react-router-dom';
import icon from '../../../assets/images/mthuabdedsbarcodescanner.png';
import mthlogo from '../../../assets/images/mthitservicelogo.png';
import { Layout } from './Layout';
import Form from 'react-bootstrap/Form';
import Toast from 'react-bootstrap/Toast';
import UserSelect from '../helper/UserSelect';
import ToastContainer from 'react-bootstrap/ToastContainer';
import data from '../helper/bde_user_test.json';

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
  const handleUserActivity = useCallback(() => {
    setCounter(60);
    focusInput();
  }, []);

  const handleBarcodeAction = useCallback(
    (code: string) => {
      // Automatische Aktionen basierend auf Barcode
      switch (code) {
        case '000001': {
          // Auftrag starten
          setShowUserSelect(true); // Userauswahl anzeigen
          break;
        }

        case '000002': {
          // Auftrag beenden
          setToast({
            show: true,
            msg: 'Auftrag beenden - Funktion wird implementiert',
            timestamp: new Date().toLocaleTimeString(),
          });
          // Hier weitere Logik für Auftrag beenden
          break;
        }

        case '000003': {
          // Problem melden
          setToast({
            show: true,
            msg: 'Problem melden - Funktion wird implementiert',
            timestamp: new Date().toLocaleTimeString(),
          });
          // Hier weitere Logik für Problem melden
          break;
        }

        case '000005': {
          // Auftrag scannen - warten auf Auftragsnummer
          setToast({
            show: true,
            msg: 'Auftrag scannen - Bitte Auftragsnummer eingeben/scannen',
            timestamp: new Date().toLocaleTimeString(),
          });
          // Focus auf Eingabefeld für Auftragsnummer
          focusInput();
          break;
        }

        case '000006': {
          // Abbrechen/Zurück zum Hauptmenü
          router('/main');
          break;
        }

        case '000010': {
          // Weiter zum Auftrag starten (aus UserSelect)
          if (selectedUser) {
            setShowUserSelect(false);
            setShowTaskScan(false);
            setToast({
              show: true,
              msg: `Auftrag wird für ${selectedUser.Name} gestartet!`,
              timestamp: new Date().toLocaleTimeString(),
            });
            // Hier weitere Logik für Auftragsstart
          } else {
            setToast({
              show: true,
              msg: 'Bitte zuerst einen Mitarbeiter auswählen',
              timestamp: new Date().toLocaleTimeString(),
            });
          }
          break;
        }

        case '000011': {
          // Zurück (aus UserSelect)
          setShowUserSelect(false);
          break;
        }

        case '000012': {
          // Vorheriger Mitarbeiter
          if (selectedUser && data.length > 0) {
            const currentIndex = data.findIndex(
              (user) => user.MitarbeiterNr === selectedUser.MitarbeiterNr,
            );
            if (currentIndex > 0) {
              const prevUser = data[currentIndex - 1];
              setSelectedUser(prevUser);
              setToast({
                show: true,
                msg: `Mitarbeiter: ${prevUser.Name}`,
                timestamp: new Date().toLocaleTimeString(),
              });
            }
          }
          break;
        }

        case '000013': {
          // Nächster Mitarbeiter
          if (selectedUser && data.length > 0) {
            const currentIndex = data.findIndex(
              (user) => user.MitarbeiterNr === selectedUser.MitarbeiterNr,
            );
            if (currentIndex < data.length - 1) {
              const nextUser = data[currentIndex + 1];
              setSelectedUser(nextUser);
              setToast({
                show: true,
                msg: `Mitarbeiter: ${nextUser.Name}`,
                timestamp: new Date().toLocaleTimeString(),
              });
            }
          }
          break;
        }

        default: {
          // Prüfen ob es eine Auftragsnummer ist (ab 6-stellig)
          if (/^\d{6,}$/.test(code)) {
            setToast({
              show: true,
              msg: `Auftragsnummer gescannt: ${code}`,
              timestamp: new Date().toLocaleTimeString(),
            });
            // TaskScan-Komponente mit Auftragsnummer anzeigen
            setShowTaskScan(true);
            // Hier könnte weitere Logik für Auftragsnummer-Verarbeitung implementiert werden
          } else {
            // Prüfen ob es eine Mitarbeiternummer ist
            const userData = data?.find((user) => user.MitarbeiterNr === code);
            if (userData) {
              setSelectedUser(userData);
              setToast({
                show: true,
                msg: `Mitarbeiter ausgewählt: ${userData.Name}`,
                timestamp: new Date().toLocaleTimeString(),
              });
            } else {
              setToast({
                show: true,
                msg: `Unbekannter Barcode: ${code}`,
                timestamp: new Date().toLocaleTimeString(),
              });
            }
          }
          break;
        }
      }
    },
    [router, selectedUser],
  );

  useEffect(() => {
    // Keydown für Scan/Eingabe
    const handleKeyDown = (e: KeyboardEvent) => {
      handleUserActivity();
      // Wenn Enter gedrückt wird, nur Barcode setzen und TaskScan anzeigen
      if (e.key === 'Enter' && inputRef.current) {
        const scannedCode = inputRef.current.value.trim();
        setBarcode(scannedCode);

        // Automatisch die entsprechende Barcode-Aktion ausführen
        if (scannedCode) {
          handleBarcodeAction(scannedCode);
        }

        // Input-Feld leeren für nächsten Scan
        inputRef.current.value = '';
      }
    };

    // Input für Textboxen
    const handleInput = () => {
      handleUserActivity();
    };

    window.addEventListener('keydown', handleKeyDown);
    window.addEventListener('input', handleInput);

    return () => {
      window.removeEventListener('keydown', handleKeyDown);
      window.removeEventListener('input', handleInput);
    };
  }, [handleBarcodeAction, handleUserActivity]);

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

  // Barcode-Aktionen aus UserSelect
  const handleUserSelectBarcode = (code: string) => {
    // Verwende die gleiche handleBarcodeAction Funktion
    handleBarcodeAction(code);
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
