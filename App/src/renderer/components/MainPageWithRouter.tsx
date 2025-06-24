import React from 'react';
import { useNavigate } from 'react-router-dom';
import MainPage from './MainPage';

const MainPageWithRouter = (props: any) => {
  const navigate = useNavigate();
  return <MainPage {...props} navigate={navigate} />;
};

export default MainPageWithRouter;
