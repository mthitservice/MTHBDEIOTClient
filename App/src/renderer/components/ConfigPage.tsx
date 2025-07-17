import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
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
};

export function ConfigPage() {
  const [name, setName] = useState<Env | null>(null);
  const [validated, setValidated] = useState(false);
  const [configData, setConfigData] = useState(false);
  const router = useNavigate();
  useEffect(() => {
    window.electron.dbConfig
      .readAllConfig()
      .then((res) => {
        setConfigData(res);

        return res;
      })
      .catch((err) => {
        console.error('Error fetching config data:', err);
      });
  }, []);

  const handleSubmit = (event: any) => {
    const form = event.currentTarget;
    if (form.checkValidity() === false) {
      event.preventDefault();
      event.stopPropagation();
      console.log('Form validation failed');
    } else {
      console.log('Form validation passed');

      event.preventDefault();
      console.log('Form submitted:', {
        deviceName: form.DeviceName.value,
        ipv4Address: form.disabledSelect.value,
      });
      window.electron.dbConfig
        .createOrUpdate('deviceName', form.DeviceName.value)
        .then(() => {
          console.log('Device name saved successfully');
          return true;
        })
        .catch((err) => {
          console.error('Error saving device name:', err);
          throw err;
        });
      window.electron.dbConfig
        .createOrUpdate('ipv4Address', form.disabledSelect.value)
        .then(() => {
          console.log('IPV4 address saved successfully');
          return true;
        })
        .catch((err) => {
          console.error('Error saving IPV4 address:', err);
          throw err;
        });
      if (window.electron?.app) {
        window.electron.app.restart();
      }
    }

    setValidated(true);
  };
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

  return (
    <div className="d-flex flex-column min-vh-100">
      <div className="BdeConfig container ">
        <div class="alert alert-warning" role="alert">
          Dieses Gerät ist noch nicht konfiguriert. <br />
          Legen Sie einen Namen fest und die IPV4 Adresse des BDE Servers.
        </div>
        <h2>Konfiguration</h2>

        <Form noValidate validated={validated} onSubmit={handleSubmit}>
          <fieldset>
            <Form.Group className="mb-3">
              <Form.Label></Form.Label>
              <Form.Label htmlFor="DeviceName">Gerätename</Form.Label>
              <Form.Control id="DeviceName" placeholder="BDE00x" required />
              <Form.Control.Feedback type="invalid">
                Der Gerätename ist erforderlich.
              </Form.Control.Feedback>
            </Form.Group>
            <Form.Group className="mb-3">
              <Form.Label htmlFor="disabledSelect">IPV4 Adresse</Form.Label>
              <Form.Control
                id="disabledSelect"
                placeholder="10.10.10.0"
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
