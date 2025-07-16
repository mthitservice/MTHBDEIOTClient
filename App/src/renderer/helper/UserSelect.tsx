import React from 'react';
import data from './bde_user_test.json';
import BarCode from './BarCode';
import Stack from 'react-bootstrap/Stack';
import Card from 'react-bootstrap/Card';
import icon from '../../../assets/icons/person-bounding-box.svg';

interface UserSelectProps {
  onUserSelect: (user: any) => void;
  onBarcodeAction: (code: string) => void;
  selectedUser: any;
}

const UserSelect: React.FC<UserSelectProps> = ({
  onUserSelect,
  onBarcodeAction,
  selectedUser,
}) => {
  const selectPrevUser = () => {
    if (!selectedUser) return;
    const idx = data.findIndex(
      (u) => u.MitarbeiterNr === selectedUser.MitarbeiterNr,
    );
    if (idx > 0) onUserSelect(data[idx - 1]);
  };
  const selectNextUser = () => {
    if (!selectedUser) return;
    const idx = data.findIndex(
      (u) => u.MitarbeiterNr === selectedUser.MitarbeiterNr,
    );
    if (idx < data.length - 1) onUserSelect(data[idx + 1]);
  };

  return (
    <div className="TaskViewArea container mt-4">
      <h2 className="mb-4">Mitarbeiterauswahl</h2>
      <div
        className="MainPageBarcodeArea row mb-4"
        style={{
          display: 'flex',
          flexWrap: 'wrap',
          gap: '16px',
          justifyContent: 'flex-start',
        }}
      >
        {data.map((user, idx) => (
          <BarCode
            code={user.MitarbeiterNr}
            text={user.Name}
            onClick={() => onUserSelect(user)}
          />
        ))}
      </div>

      <div className="row MainPageBarcodeArea">
        <div className="col-sm">
          <BarCode
            code="000010"
            text={<>Weiter zum Auftrag starten</>}
            onClick={() => onBarcodeAction('000010')}
          />
        </div>
        <div className="col-sm">
          <BarCode
            code="000011"
            text={<>Zurück</>}
            onClick={() => onBarcodeAction('000011')}
          />
        </div>
        <div className="col-sm">
          <BarCode
            code="000012"
            text={<>Vorheriger Mitarbeiter</>}
            onClick={selectPrevUser}
          />
        </div>
        <div className="col-sm">
          <BarCode
            code="000013"
            text={<>Nächster Mitarbeiter</>}
            onClick={selectNextUser}
          />
        </div>
      </div>
    </div>
  );
};

export default UserSelect;
