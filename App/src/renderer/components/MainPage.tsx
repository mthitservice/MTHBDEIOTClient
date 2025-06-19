import { useState, useEffect } from 'react';
import { Layout } from './Layout';
import icon from '../../../assets/icon.svg';
import Button from 'react-bootstrap/Button';
import Form from 'react-bootstrap/Form';
import 'bootstrap/dist/css/bootstrap.min.css';

type Env = {
  APP_NAME: string;
  APP_VERSION: string;
  APP_COPYRIGHT: string;
  APP_AUTHOR: string;
  APP_LICENSE: string;
  APP_DESCRIPTION: string;
};

export function MainPage() {
  const [name, setName] = useState<Env | null>(null);

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
    <Layout>
      <div className="MainPage">
        <h1>Hauptseite</h1>
        <p>
          Dieses Gerät ist noch nicht konfiguriert. Legen Sie einen Namen fest
          und die IPV4 Adresse des BDE Servers.
        </p>

        <p>
          {name?.APP_NAME} {name?.APP_VERSION}
        </p>
      </div>
    </Layout>
  );
}
export default MainPage;
