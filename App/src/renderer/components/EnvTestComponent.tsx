import React from 'react';

export const EnvTestComponent: React.FC = () => {
  return (
    <div style={{ 
      position: 'fixed', 
      top: '10px', 
      right: '10px', 
      background: '#f0f0f0', 
      padding: '10px', 
      border: '1px solid #ccc',
      fontSize: '12px',
      fontFamily: 'monospace',
      zIndex: 9999
    }}>
      <div><strong>ENV Variables Test:</strong></div>
      <div>APP_NAME: {process.env.APP_NAME || 'undefined'}</div>
      <div>APP_AUTHOR: {process.env.APP_AUTHOR || 'undefined'}</div>
      <div>APP_COPYRIGHT: {process.env.APP_COPYRIGHT || 'undefined'}</div>
      <div>NODE_ENV: {process.env.NODE_ENV || 'undefined'}</div>
    </div>
  );
};
