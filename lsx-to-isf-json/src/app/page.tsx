"use client"

import React from 'react';
import { XmlToJsonComponent } from './XmlToJsonComponent';

const Page: React.FC = () => {
  return (
    <div className="flex flex-col items-center justify-center h-screen bg-gray-900 text-white">
      <h1 className="text-3xl items-center align-center font-bold mb-4 mt-0">LSX to ISF config JSON converter</h1>
      <XmlToJsonComponent />
    </div>
  );
};

export default Page;
