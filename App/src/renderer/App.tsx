import React, { useEffect } from 'react';
import {
  MemoryRouter as Router,
  Routes,
  Route,
  useNavigate,
} from 'react-router-dom';

import { StartPage } from './components/StartPage';
import { ConfigPage } from './components/ConfigPage';
import MainPageWithRouter from './components/MainPageWithRouter';
import { ScanPage } from './components/ScanPage';
import { EnvTestComponent } from './components/EnvTestComponent';
import './App.css';

// Component that handles IPC events and navigation
function AppWithNavigation() {
  const navigate = useNavigate();

  useEffect(() => {
    // Setup IPC listeners for keyboard shortcuts
    const removeNavigateToConfigListener = window.electron.ipcRenderer.on(
      'navigate-to-config',
      () => {
        navigate('/config');
      },
    );

    const removeEscapeListener = window.electron.ipcRenderer.on(
      'escape-pressed',
      () => {
        // Navigate back or to start page
        navigate(-1);
      },
    );

    // Cleanup listeners
    return () => {
      removeNavigateToConfigListener?.();
      removeEscapeListener?.();
    };
  }, [navigate]);

  return (
    <Routes>
      <Route path="/" element={<StartPage />} />
      <Route path="/config" element={<ConfigPage />} />
      <Route path="/main" element={<MainPageWithRouter />} />
      <Route path="/scan" element={<ScanPage />} />
    </Routes>
  );
}

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
      .catch(() => {
        // Error handling for environment variables
      });
  }, []);

  return (
    <Router>
      <AppWithNavigation />
      <EnvTestComponent />
    </Router>
  );
}
