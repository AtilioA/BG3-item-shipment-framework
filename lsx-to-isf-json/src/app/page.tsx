"use client"

import React from 'react';
import { XmlToJsonComponent } from './XmlToJsonComponent';

const Page: React.FC = () => {
  return (
    <div>
      <h1>Mod LSX to ISF config JSON converter</h1>
      <XmlToJsonComponent />
    </div>
  );
};

export default Page;
