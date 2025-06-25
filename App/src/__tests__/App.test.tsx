import '@testing-library/jest-dom';
import { render, waitFor, screen } from '@testing-library/react';
import MainPage from '../renderer/components/MainPage';

import App from '../renderer/App';

beforeAll(() => {
  // Falls `window.electron` noch nicht existiert
  if (!window.electron) {
    (window as any).electron = {};
  }

  window.electron.getEnv = jest.fn().mockResolvedValue({
    APP_NAME: 'TestApp',
    APP_VERSION: '1.0.0',
  });

  // Mock für window.electron.dbConfig.getInitialConfig
  window.electron.dbConfig = {
    getInitialConfig: jest.fn().mockResolvedValue({}),
  };
});

describe('App', () => {
  it('should render without crashing', async () => {
    const { container } = render(<App />);
    await waitFor(() => {
      expect(container).toBeTruthy();
    });
  });
});
describe('MainPage', () => {
  it('rendert die Überschrift "Auftragsübersicht"', () => {
    render(<MainPage />);
    expect(screen.getByText(/Auftragsübersicht/i)).toBeInTheDocument();
  });

  it('zeigt die TableView-Komponente an, wenn kein Auftrag ausgewählt ist', () => {
    render(<MainPage />);
    // Suche nach einem typischen Tabellen-Header
    const headers = screen.getAllByText(/AuftrNr|Auftragsnummer|Objekt/i);
    expect(headers.length).toBeGreaterThan(0);
  });

  it('zeigt keine Auftragsdetails an, wenn kein Auftrag ausgewählt ist', () => {
    render(<MainPage />);
    expect(screen.queryByText(/Auftragsdetails/i)).not.toBeInTheDocument();
  });
});
