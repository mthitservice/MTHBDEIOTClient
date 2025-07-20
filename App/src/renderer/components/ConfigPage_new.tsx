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
};

export function ConfigPage() {
  const [name, setName] = useState<Env | null>(null);
  const [validated, setValidated] = useState(false);
  const [deviceName, setDeviceName] = useState('');
  const [ipv4Address, setIpv4Address] = useState('');

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

          if (deviceNameEntry) setDeviceName(deviceNameEntry.value);
          if (ipv4Entry) setIpv4Address(ipv4Entry.value);
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
        return res;
      })
      .catch((err) => {
        // Error fetching environment variables
        throw err;
      });
  }, [ipv4Address]);

  const handleSubmit = (event: any) => {
    const form = event.currentTarget;
    if (form.checkValidity() === false) {
      event.preventDefault();
      event.stopPropagation();
      // Form validation failed
    } else {
      // Form validation passed
      event.preventDefault();

      // Save form data using state values
      window.electron.dbConfig
        .createOrUpdate('deviceName', deviceName)
        .then(() => {
          // Device name saved successfully
          return true;
        })
        .catch((err) => {
          // Error saving device name
          throw err;
        });
      window.electron.dbConfig
        .createOrUpdate('ipv4Address', ipv4Address)
        .then(() => {
          // IPV4 address saved successfully
          return true;
        })
        .catch((err) => {
          // Error saving IPV4 address
          throw err;
        });
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

            <Button type="submit" className="btn">
              Speichern und Verbinden
            </Button>
          </fieldset>
        </Form>

        <p>
          {name?.APP_NAME} {name?.APP_VERSION}
        </p>

        <AutoUpdater />
      </div>
    </div>
  );
}
export default ConfigPage;
