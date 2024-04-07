import React, { useCallback, useEffect, useState } from 'react';
import DragAndDropPreview from './DragAndDropPreview';
import { GameObjectData, parseRootTemplate } from '@/services/parseGameObjects';
import { TreasureItem, parseTreasureTableData } from '@/services/parseTreasureTable';
import { constructJSON } from '@/services/xmlToJson';

const DragAndDropContainer: React.FC = () => {
  const [jsonOutput, setJsonOutput] = useState('');
  const [isDragging, setIsDragging] = useState(false);
  const [gameObjectData, setGameObjectData] = useState<GameObjectData[]>([]);

  // Step 1: Gathering Data
  interface FileAndPath {
    file: File;
    path: string;
  }

  const gatherData = useCallback(async (item: FileSystemEntry, path: string = ''): Promise<FileAndPath[]> => {
    let files: FileAndPath[] = [];
    if (item.isFile) {
      // Correct handling of FileSystemFileEntry to get a File object
      const fileEntry = item as FileSystemFileEntry;
      const file: File = await new Promise((resolve) => fileEntry.file(resolve));
      files.push({ file: file, path: `${path}/${file.name}` });
    } else if (item.isDirectory) {
      const dirReader = (item as FileSystemDirectoryEntry).createReader();
      let readEntries: FileSystemEntry[] = await new Promise((resolve, reject) => dirReader.readEntries(resolve, reject));
      for (let entry of readEntries) {
        const entryFiles = await gatherData(entry, `${path}/${entry.name}`);
        files = files.concat(entryFiles);
      }
    }

    return files;
  }, []);

  // Step 2: Parsing LSX Files
  const parseLSXFiles = async (files: FileAndPath[]): Promise<GameObjectData[]> => {
    console.log(files);
    const lsxFiles = files.filter((file) => file.file.name.endsWith('.lsx') && file.file.webkitRelativePath.includes('RootTemplates'));
    const parsedData: GameObjectData[] = [];
    for (let file of lsxFiles) {
      const text = await file.file.text();
      const xmlDoc = new DOMParser().parseFromString(text, 'text/xml');
      const parsed = parseRootTemplate(xmlDoc);
      parsedData.push(...parsed);
    }
    return parsedData;
  };

  // Step 3: Parsing Treasure Table Files
  const parseTreasureTables = async (files: File[]): Promise<TreasureItem[]> => {
    const treasureFiles = files.filter((file) => file.name.endsWith('.txt') && file.webkitRelativePath.includes('Generated'));
    const treasureData: TreasureItem[] = [];
    for (let file of treasureFiles) {
      const text = await file.text();
      const parsed = parseTreasureTableData(text);
      treasureData.push(...parsed);
    }
    return treasureData;
  };

  // Step 4: Removing Items
  const removeItemsFromLSX = (lsxData: GameObjectData[], treasureData: TreasureItem[]): GameObjectData[] => {
    return lsxData.filter((lsxItem) => !treasureData.some((treasureItem) => treasureItem.templateName === lsxItem.templateName));
  };

  // Pipeline Executor
  const executePipeline = useCallback(async (rootItem: FileSystemEntry) => {
    const files = await gatherData(rootItem);
    const lsxData = await parseLSXFiles(files);
    const treasureData = await parseTreasureTables(files);
    const finalData = removeItemsFromLSX(lsxData, treasureData);
    setGameObjectData(finalData);
  }, [gatherData]);

  const onDrop = useCallback((event: React.DragEvent<HTMLDivElement>) => {
    event.preventDefault();
    const items: DataTransferItemList = event.dataTransfer.items;

    for (let i = 0; i < items.length; i++) {
      const item: DataTransferItem = items[i];
      const entry: FileSystemEntry | null = item.webkitGetAsEntry();
      if (entry) {
        executePipeline(entry);
      }
    }

    setIsDragging(false);
    event.preventDefault();
  }, [executePipeline]);


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
        executePipeline(entry);
      }
    }
    setIsDragging(false);
  }, [executePipeline]);

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
