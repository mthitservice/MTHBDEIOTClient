import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import icon from '../../../assets/images/mthuabdedsbarcodescanner.png';
import mthlogo from '../../../assets/images/mthitservicelogo.png';
import Button from 'react-bootstrap/Button';
import { Layout } from './Layout';
import Form from 'react-bootstrap/Form';
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
        Barcode: form.Barcode.value,
      });
    }

    setValidated(true);
  };
  // Usenavigate to redirect to the page

  return (
    <Layout>
      <div className="ScanPage container row ">
        <div className="col text-md-end">
          <img alt="icon" src={icon} />
        </div>
        <div className="col text-md-start">
          <Form noValidate validated={validated} onSubmit={handleSubmit}>
            <fieldset>
              <Form.Group className="mb-3">
                <h2>Bitte Auftragstasche scannen...</h2>
                <Form.Control id="Barcode" placeholder="..." required />
                <Form.Control.Feedback type="invalid">
                  Auftragsnummer erforderlich
                </Form.Control.Feedback>
              </Form.Group>
            </fieldset>
          </Form>
        </div>
        <div className="col text-md-end">
          <img alt="icon" src={mthlogo} />
        </div>
      </div>
    </Layout>
  );
}
export default ScanPage;
