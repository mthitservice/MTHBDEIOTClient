import React, { useEffect } from 'react';
import { MemoryRouter as Router, Routes, Route } from 'react-router-dom';
import { StartPage } from './components/StartPage';
import { ConfigPage } from './components/ConfigPage';
import { MainPage } from './components/MainPage';

export default function App() {
  useEffect(() => {
    // This is where you can add any side effects or initializations
    // For example, fetching initial data or setting up listeners
    window.electron
      .getEnv()
      .then((res) => {
        document.title = `${res.APP_NAME} | ${res.APP_VERSION}`;
        return null;
      })
      .catch((err) => {
        console.error('Failed to get environment variables:', err);
      });
  }, []);
  return (
    <Router>
      <Routes>
        <Route path="/" element={<StartPage />} />
        <Route path="/config" element={<ConfigPage />} />
        <Route path="/main" element={<MainPage />} />
      </Routes>
    </Router>
  );
}
