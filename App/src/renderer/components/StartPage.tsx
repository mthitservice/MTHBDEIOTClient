import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import icon from '../../../assets/icon.svg';
import '../App.css';

export function StartPage() {
  const [name, setName] = useState({});
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

  const router = useNavigate();
  setTimeout(() => {
    router('/config');
  }, 3000);
  return (
    <div>
      <div className="MainApplicationHello">
        <img width="80%" alt="icon" src={icon} />
      </div>
      <div className="MainFooter">
        <h1>
          {name?.APP_NAME} {name?.APP_VERSION}
        </h1>
        <h2>
          {name?.APP_COPYRIGHT} | {name?.APP_AUTHOR}
        </h2>
        <p>{name?.APP_LICENSE}</p>
        <p>{name?.APP_DESCRIPTION}</p>
      </div>
    </div>
  );
}
export default StartPage;
