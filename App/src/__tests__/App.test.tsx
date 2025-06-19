import '@testing-library/jest-dom';
import { render, waitFor } from '@testing-library/react';

import App from '../renderer/App';

// Mock für window.electron.getEnv
beforeAll(() => {
  // Falls `window.electron` noch nicht existiert
  if (!window.electron) {
    (window as any).electron = {};
  }

  window.electron.getEnv = jest.fn().mockResolvedValue({
    APP_NAME: 'TestApp',
    APP_VERSION: '1.0.0',
  });
});

describe('App', () => {
  it('should render without crashing', async () => {
    const { container } = render(<App />);
    await waitFor(() => {
      expect(container).toBeTruthy();
    });
  });
});
