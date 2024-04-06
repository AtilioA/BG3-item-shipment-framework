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

  const handlePaste = async (event) => {
    const text = event.clipboardData.getData('Text');
    if (text) {
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
    <div>
      <div {...getRootProps()} onPaste={handlePaste} style={{ border: '2px dashed #007bff', padding: '20px', cursor: 'pointer' }}>
        <input {...getInputProps()} />
        <p>Drag and drop an XML file here, or paste its content.</p>
      </div>
      {jsonOutput && (
        <>
          <button onClick={handleSaveJSON}>Save JSON</button>
          <pre onClick={handleSaveJSON} style={{ cursor: "pointer" }} title="Click to save ISF JSON">{jsonOutput}</pre>
        </>
      )}
    </div >
  );
};
