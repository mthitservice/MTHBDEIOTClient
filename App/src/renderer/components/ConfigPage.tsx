import { useState, useEffect } from 'react';
import Button from 'react-bootstrap/Button';
import Form from 'react-bootstrap/Form';
import 'bootstrap/dist/css/bootstrap.min.css';
import './ConfigPage.css';

export function ConfigPage() {
  const [name, setName] = useState({});
  const [validated, setValidated] = useState(false);

  const handleSubmit = (event) => {
    const form = event.currentTarget;
    if (form.checkValidity() === false) {
      event.preventDefault();
      event.stopPropagation();
    }

    setValidated(true);
    const rows = window.electron.dbQuery().then((res) => {
      console.log('Database query result:', res);
      return res;
    });
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
    <div className="BdeConfig">
      <h1>Konfiguration</h1>
      <p>
        Dieses Gerät ist noch nicht konfiguriert. Legen Sie einen Namen fest und
        die IPV4 Adresse des BDE Servers.
      </p>
      <Form noValidate validated={validated} onSubmit={handleSubmit}>
        <fieldset>
          <Form.Group className="mb-3">
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

          <Button type="submit" className="btn btn-warning">
            Speichern und Verbinden
          </Button>
        </fieldset>
      </Form>
      <p></p>
      <p>
        {name?.APP_NAME} {name?.APP_VERSION}
      </p>
    </div>
  );
}
export default ConfigPage;
