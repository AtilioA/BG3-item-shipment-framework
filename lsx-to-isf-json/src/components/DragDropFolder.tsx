import React, { useCallback } from 'react';

export default function FolderDropComponent() {
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
  }, [traverseFileTree]);

  return (
    <div
      onDrop={onDrop}
      onDragOver={(event: React.DragEvent<HTMLDivElement>) => event.preventDefault()}
      style={{ border: '2px dashed #ccc', padding: '20px', margin: '20px' }}
    >
      Drag and drop your mod folder here
    </div>
  );
}
