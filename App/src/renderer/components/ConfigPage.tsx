import { useState, useEffect } from 'react';
import Button from 'react-bootstrap/Button';
import Form from 'react-bootstrap/Form';
import 'bootstrap/dist/css/bootstrap.min.css';
import '../App.css';
import './ConfigPage.css';
import AutoUpdater from './AutoUpdater';

type Env = {
  APP_NAME: string;
  APP_VERSION: string;
  APP_COPYRIGHT: string;
  APP_AUTHOR: string;
  APP_LICENSE: string;
  APP_DESCRIPTION: string;
  API_KEY: string;
  API_DEFAULT_IP: string;
  API_IP: string;
  PORTAL_API_BASE_URL?: string;
};

export function ConfigPage() {
  const [name, setName] = useState<Env | null>(null);
  const [validated, setValidated] = useState(false);
  const [deviceName, setDeviceName] = useState('');
  const [ipv4Address, setIpv4Address] = useState('');
  const [portalBaseUrl, setPortalBaseUrl] = useState('');
  const [clientIdentifier, setClientIdentifier] = useState('');
  const [clientMode, setClientMode] = useState('druckmaschine');
  const [assignedDeviceId, setAssignedDeviceId] = useState('');
  const [registerInfo, setRegisterInfo] = useState('');

  useEffect(() => {
    window.electron.dbConfig
      .readAllConfig()
      .then((res) => {
        // Lade existierende Werte falls vorhanden
        if (res && Array.isArray(res)) {
          const deviceNameEntry = res.find(
            (item: any) => item.key === 'deviceName',
          );
          const ipv4Entry = res.find((item: any) => item.key === 'ipv4Address');
          const portalUrlEntry = res.find((item: any) => item.key === 'portalBaseUrl');
          const clientIdentifierEntry = res.find((item: any) => item.key === 'clientIdentifier');
          const clientModeEntry = res.find((item: any) => item.key === 'clientMode');
          const assignedDeviceIdEntry = res.find((item: any) => item.key === 'assignedDeviceId');

          if (deviceNameEntry) setDeviceName(deviceNameEntry.value);
          if (ipv4Entry) setIpv4Address(ipv4Entry.value);
          if (portalUrlEntry) setPortalBaseUrl(portalUrlEntry.value);
          if (clientIdentifierEntry) setClientIdentifier(clientIdentifierEntry.value);
          if (clientModeEntry) setClientMode(clientModeEntry.value);
          if (assignedDeviceIdEntry) setAssignedDeviceId(assignedDeviceIdEntry.value);
        }

        return res;
      })
      .catch((err) => {
        // Error fetching config data
        throw err;
      });
  }, []);

  useEffect(() => {
    window.electron
      .getEnv()
      .then((res) => {
        setName(res);
        // Setze Default-IP falls noch nicht gesetzt
        if (!ipv4Address && res.API_DEFAULT_IP) {
          setIpv4Address(res.API_DEFAULT_IP);
        }
        if (!portalBaseUrl && res.PORTAL_API_BASE_URL) {
          setPortalBaseUrl(res.PORTAL_API_BASE_URL);
        }
        return res;
      })
      .catch((err) => {
        // Error fetching environment variables
        throw err;
      });
  }, [ipv4Address]);

  const handleSubmit = async (event: any) => {
    const form = event.currentTarget;
    if (form.checkValidity() === false) {
      event.preventDefault();
      event.stopPropagation();
      // Form validation failed
    } else {
      // Form validation passed
      event.preventDefault();

      try {
        await Promise.all([
          window.electron.dbConfig.createOrUpdate('deviceName', deviceName),
          window.electron.dbConfig.createOrUpdate('ipv4Address', ipv4Address),
          window.electron.dbConfig.createOrUpdate('portalBaseUrl', portalBaseUrl),
          window.electron.dbConfig.createOrUpdate(
            'clientIdentifier',
            clientIdentifier || deviceName,
          ),
          window.electron.dbConfig.createOrUpdate('clientMode', clientMode),
          window.electron.dbConfig.createOrUpdate('assignedDeviceId', assignedDeviceId),
        ]);

        try {
          await window.electron.portalApi.registerClient({
            clientIdentifier: clientIdentifier || deviceName,
            displayName: deviceName,
            hostName: deviceName,
            ipAddress: ipv4Address,
            fallbackIpAddress: name?.API_DEFAULT_IP || '',
            softwareVersion: name?.APP_VERSION || '0.0.0',
            clientMode,
            assignedDeviceId: assignedDeviceId || null,
          });
          setRegisterInfo('Client erfolgreich im Portal registriert.');
        } catch (registerError: any) {
          console.warn('Portal-Registrierung fehlgeschlagen:', registerError);
          setRegisterInfo(
            `Konfiguration gespeichert, Portal-Registrierung fehlgeschlagen: ${registerError?.message || 'Unbekannter Fehler'}`,
          );
        }
      } catch (saveError) {
        console.error('Fehler beim Speichern der Konfiguration:', saveError);
        setRegisterInfo('Konfiguration konnte nicht gespeichert werden.');
        setValidated(true);
        return;
      }

      if (window.electron?.app) {
        window.electron.app.restart();
      }
    }

    setValidated(true);
  };

  return (
    <div className="d-flex flex-column min-vh-100">
      <div className="BdeConfig container ">
        <div className="alert alert-warning" role="alert">
          Dieses Gerät ist noch nicht konfiguriert. <br />
          Legen Sie einen Namen fest und die IPV4 Adresse des BDE Servers.
        </div>
        <h2>Konfiguration</h2>

        <Form noValidate validated={validated} onSubmit={handleSubmit}>
          <fieldset>
            <Form.Group className="mb-3">
              <Form.Label />
              <Form.Label htmlFor="DeviceName">Gerätename</Form.Label>
              <Form.Control
                id="DeviceName"
                placeholder="BDE00x"
                value={deviceName}
                onChange={(e) => setDeviceName(e.target.value)}
                required
              />
              <Form.Control.Feedback type="invalid">
                Der Gerätename ist erforderlich.
              </Form.Control.Feedback>
            </Form.Group>
            <Form.Group className="mb-3">
              <Form.Label htmlFor="disabledSelect">IPV4 Adresse</Form.Label>
              <Form.Control
                id="disabledSelect"
                placeholder={name?.API_DEFAULT_IP || '10.10.10.1'}
                value={ipv4Address}
                onChange={(e) => setIpv4Address(e.target.value)}
                required
              />
              <Form.Control.Feedback type="invalid">
                Die IPV4 Adresse des Servers ist erforderlich.
              </Form.Control.Feedback>
            </Form.Group>

            <Form.Group className="mb-3">
              <Form.Label htmlFor="portalBaseUrl">Portal URL</Form.Label>
              <Form.Control
                id="portalBaseUrl"
                placeholder="https://bdeds.druckerei-schuetz.local"
                value={portalBaseUrl}
                onChange={(e) => setPortalBaseUrl(e.target.value)}
                required
              />
              <Form.Control.Feedback type="invalid">
                Die Portal URL ist erforderlich.
              </Form.Control.Feedback>
            </Form.Group>

            <Form.Group className="mb-3">
              <Form.Label htmlFor="clientIdentifier">Client Identifier</Form.Label>
              <Form.Control
                id="clientIdentifier"
                placeholder="raspi-druck-01"
                value={clientIdentifier}
                onChange={(e) => setClientIdentifier(e.target.value)}
                required
              />
              <Form.Control.Feedback type="invalid">
                Die Client-ID ist erforderlich.
              </Form.Control.Feedback>
            </Form.Group>

            <Form.Group className="mb-3">
              <Form.Label htmlFor="clientMode">Client Modus</Form.Label>
              <Form.Select
                id="clientMode"
                value={clientMode}
                onChange={(e) => setClientMode(e.target.value)}
              >
                <option value="druckmaschine">Druckmaschine</option>
                <option value="weiterverarbeitung">Weiterverarbeitung</option>
                <option value="infomonitor">Infomonitor</option>
              </Form.Select>
            </Form.Group>

            <Form.Group className="mb-3">
              <Form.Label htmlFor="assignedDeviceId">
                Zugeordnete Maschinen-ID (optional)
              </Form.Label>
              <Form.Control
                id="assignedDeviceId"
                placeholder="GUID aus Portal-Deviceverwaltung"
                value={assignedDeviceId}
                onChange={(e) => setAssignedDeviceId(e.target.value)}
              />
            </Form.Group>

            <Button type="submit" className="btn">
              Speichern und Verbinden
            </Button>
          </fieldset>
        </Form>

        {registerInfo && <div className="alert alert-info mt-3">{registerInfo}</div>}

        <p>
          {name?.APP_NAME} {name?.APP_VERSION}
        </p>

        <AutoUpdater />
      </div>
    </div>
  );
}
export default ConfigPage;
