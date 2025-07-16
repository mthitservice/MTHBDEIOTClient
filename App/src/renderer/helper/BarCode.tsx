import React, { useState, useEffect } from 'react';
import Barcode from 'react-barcode';
import './BarCode.css';
import 'bootstrap/dist/css/bootstrap.min.css';
interface BarCodeProps {
  code: string;
  text: string;
  onClick: any | null;
}

class BarCode extends React.Component<BarCodeProps> {
  constructor(props: BarCodeProps) {
    super(props);
  }

  render() {
    return (
      <div className="BdeBarCodeArea container">
        <div className="row text-md-center">
          <div className="column text-md-start" onClick={this.props.onClick}>
            <Barcode
              value={this.props.code}
              displayValue={false}
              ean128={false}
              format={'CODE39'}
              height={60}
              width={3}
              className="BdeBarCode"
              background="#ffffff"
              lineColor="#000000"
              margin={2}
            />
          </div>
        </div>
        <div className="row text-md-start">
          <div className="column text-md-left ">{this.props.text}</div>
        </div>
      </div>
    );
  }
}

export default BarCode;
