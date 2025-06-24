import React from 'react';

interface StatusIndicatorProps {
  status: number;
}

const statusColors: Record<number, string> = {
  0: 'gray',
  1: 'green',
  2: 'yellow',
  3: 'red',
  4: '#026898',
};

const StatusIndicator: React.FC<StatusIndicatorProps> = ({ status }) => {
  const color = statusColors[status] || 'black';

  return (
    <div
      style={{
        width: '16px',
        height: '16px',
        backgroundColor: color,
        borderRadius: '4px',
        margin: 'auto',
      }}
      title={`Status ${status}`}
    />
  );
};

export default StatusIndicator;
