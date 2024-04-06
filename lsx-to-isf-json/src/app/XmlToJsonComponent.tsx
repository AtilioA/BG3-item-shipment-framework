import React, { useCallback, useState } from 'react';
import { FileRejection, useDropzone } from 'react-dropzone';
import { constructJSON, parseXML } from './utils/xmlToJson';

export const XmlToJsonComponent: React.FC = () => {
  const [jsonOutput, setJsonOutput] = useState('');

  const onDrop = useCallback((acceptedFiles: File[], fileRejections: FileRejection[]) => {
    // Only one file is accepted
    const file = acceptedFiles[0];
    const reader = new FileReader();

    reader.onload = (event) => {
      const xmlContent = (event.target as FileReader).result;
      if (typeof xmlContent !== 'string') {
        alert('Error reading LSX file.');
        return;
      }
      const mapKeys = parseXML(xmlContent);
      const finalJSON = constructJSON(mapKeys);
      setJsonOutput(JSON.stringify(finalJSON, null, 2));
    };

    reader.readAsText(file);
  }, []);

  const { getRootProps, getInputProps } = useDropzone({ onDrop });

  const handlePaste = async (event: React.ClipboardEvent<HTMLDivElement>) => {
    const text = event.clipboardData.getData('Text');
    if (!text) {
      console.info('No text found in clipboard.');
    } else {
      const mapKeys = parseXML(text);
      const finalJSON = constructJSON(mapKeys);
      setJsonOutput(JSON.stringify(finalJSON, null, 2));
    }
  };

  const handleSaveJSON = () => {
    const element = document.createElement('a');
    const file = new Blob([jsonOutput], { type: 'application/json' });
    element.href = URL.createObjectURL(file);
    element.download = 'ItemShipmentFrameworkConfig.json';
    document.body.appendChild(element);
    element.click();
    document.body.removeChild(element);
  };

  return (
    <div className="flex flex-col items-center justify-center w-full max-w-3xl">
      <div
        {...getRootProps()}
        onPaste={handlePaste}
        className="w-full h-64 p-8 border-2 border-dashed border-blue-500 rounded-lg cursor-pointer flex items-center justify-center"
      >
        <input {...getInputProps()} />
        <p className="text-lg text-white">Drag and drop an LSX file here, or paste its content.</p>
      </div>
      {jsonOutput && (
        <div className="mt-8 w-full max-h-[50vh] overflow-auto">
          <button
            onClick={handleSaveJSON}
            className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
          >
            Save JSON
          </button>
          <hr className="border-gray-600 my-4" />
          <p className='mt-4 mb-2'>JSON preview:</p>
          <pre
            onClick={handleSaveJSON}
            style={{ cursor: 'pointer' }}
            title="Click to save ISF JSON"
            className="mt-4 p-4 bg-gray-800 rounded-lg text-white"
          >
            {jsonOutput}
          </pre>
        </div>
      )}
    </div>
  );
};
