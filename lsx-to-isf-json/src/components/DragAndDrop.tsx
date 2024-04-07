// import { constructJSON, parseXML } from '@/services/xmlToJson';
import React, { useCallback, useState } from 'react';
import DragAndDropPreview from './DragAndDropPreview';

const DragAndDropContainer: React.FC = () => {
  const [jsonOutput, setJsonOutput] = useState('');
  const [isDragging, setIsDragging] = useState(false);

  const traverseFileTree = useCallback((item: FileSystemEntry, path: string = "") => {
    if (item.isFile) {
      const fileEntry = item as FileSystemFileEntry;
      fileEntry.file((file: File) => {
        console.log(`File: ${path}/${file.name}`);
        const fileReader = new FileReader();
        fileReader.onload = () => {
          // console.log(`Contents of ${path}/${file.name}:\n${fileReader.result}`);
        };
        fileReader.readAsText(file);
      });
    } else if (item.isDirectory) {
      const directoryEntry = item as FileSystemDirectoryEntry;
      const dirReader = directoryEntry.createReader();
      dirReader.readEntries((entries: FileSystemEntry[]) => {
        for (let i = 0; i < entries.length; i++) {
          traverseFileTree(entries[i], `${path}/${directoryEntry.name}`);
        }
      });
    }
  }, []);

  const onDrop = useCallback((event: React.DragEvent<HTMLDivElement>) => {
    event.preventDefault();
    const items: DataTransferItemList = event.dataTransfer.items;

    for (let i = 0; i < items.length; i++) {
      const item: DataTransferItem = items[i];
      const entry: FileSystemEntry | null = item.webkitGetAsEntry();
      if (entry) {
        traverseFileTree(entry);
      }
    }

    setIsDragging(false);
    event.preventDefault();
  }, [traverseFileTree]);

  const handleSaveJSON = () => {
    const element = document.createElement('a');
    const file = new Blob([jsonOutput], { type: 'application/json' });
    element.href = URL.createObjectURL(file);
    element.download = 'ItemShipmentFrameworkConfig.json';
    document.body.appendChild(element);
    element.click();
    document.body.removeChild(element);
  };


  const onDragEnter = useCallback((event: React.DragEvent<HTMLDivElement>) => {
    setIsDragging(true);
    event.preventDefault();
  }, []);

  const onDragLeave = useCallback((event: React.DragEvent<HTMLDivElement>) => {
    setIsDragging(false);
    event.preventDefault();
  }, []);

  const onPaste = useCallback((event: React.ClipboardEvent<HTMLDivElement>) => {
    setIsDragging(true);
    event.preventDefault();
    const items: DataTransferItemList = event.clipboardData.items;

    for (let i = 0; i < items.length; i++) {
      const item: DataTransferItem = items[i];
      const entry: FileSystemEntry | null = item.webkitGetAsEntry();
      if (entry) {
        traverseFileTree(entry);
      }
    }
    setIsDragging(false);
  }, [traverseFileTree]);

  return (
    <div
      onDrop={onDrop}
      onDragEnter={onDragEnter}
      onDragLeave={onDragLeave}
      onPaste={onPaste}
      onDragOver={(event: React.DragEvent<HTMLDivElement>) => event.preventDefault()}
      className={`flex flex-col items-center justify-center my-2 w-full h-screen w-full border-2 border-dashed p-8 ${isDragging ? 'border-blue-500' : 'border-gray-400'
        }`}
    >
      {isDragging ? (
        <p className="text-blue-500 font-bold">Drop to generate the ISF config JSON</p>
      ) : (
        <>
          <p className="text-gray-400">Drag and drop or paste your mod folder here</p>
          <p className="text-gray-400"></p>
        </>
      )}
      {/* <FolderDropComponent /> */}
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
