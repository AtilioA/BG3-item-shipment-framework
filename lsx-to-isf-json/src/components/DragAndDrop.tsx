import { constructJSON, parseXML } from '@/services/xmlToJson';
import React, { useCallback, useState } from 'react';
import { FileRejection, useDropzone } from 'react-dropzone';
import DragAndDropPreview from './DragAndDropPreview';
// import DragAndDropInput from './DragAndDropInput';
import FolderDropComponent from './DragDropFolder';

const DragAndDropContainer: React.FC = () => {
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
      <FolderDropComponent />
      {jsonOutput && (
        <DragAndDropPreview
          jsonOutput={jsonOutput}
          handleSaveJSON={handleSaveJSON}
        />
      )}
    </div>
  );
};

export default DragAndDropContainer;
