import React from 'react';
import { useNavigate } from 'react-router-dom';
import { ModeRouter } from './ModeRouter';

/**
 * MainPageWithRouter: Integration von ModeRouter mit React Router
 * Der ModeRouter wählt basierend auf clientMode die richtige Komponente
 */
function MainPageWithRouter(props: any) {
  const navigate = useNavigate();
  return <ModeRouter {...props} navigate={navigate} />;
}

export default MainPageWithRouter;
