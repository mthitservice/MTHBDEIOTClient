import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import icon from '../../../assets/icon.svg';
import '../App.css';
import './StartPage.css';

type Env = {
  APP_NAME: string;
  APP_VERSION: string;
  APP_COPYRIGHT: string;
  APP_AUTHOR: string;
  APP_LICENSE: string;
  APP_DESCRIPTION: string;
};

export function StartPage() {
  const router = useNavigate();
  const [name, setName] = useState<Env | null>(null);
  const [config, setConfig] = useState<any | null>(null);
  useEffect(() => {
    window.electron.dbConfig
      .getInitialConfig()
      .then((res: any) => {
        console.log('Initial config:', res);
        setTimeout(() => {
          if (res && res.length > 1) {
            // Navigate to the main application page if initialized
            router('/main');
          } else {
            // Navigate to the setup page if not initialized
            router('/config');
          }
        }, 2000);
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

  // Usenavigate to redirect to the page

  return (
    <div className="d-flex flex-column min-vh-100">
      <div className="MainApplicationHello">
        <img width="80%" alt="icon" src={icon} />
      </div>
      <div className="MainFooter">
        <h2>
          {name?.APP_NAME} {name?.APP_VERSION}
        </h2>
        <h5>
          {name?.APP_COPYRIGHT} | {name?.APP_AUTHOR}
        </h5>
        <p>{name?.APP_LICENSE}</p>
        <p>{name?.APP_DESCRIPTION}</p>
      </div>
    </div>
  );
}
export default StartPage;
