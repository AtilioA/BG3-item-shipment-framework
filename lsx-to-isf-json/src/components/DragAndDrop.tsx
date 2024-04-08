import React, { useCallback, useEffect, useState } from 'react';
import DragAndDropPreview from './DragAndDropPreview';
import { GameObjectData } from '@/services/parseGameObjects';
import { constructJSON } from '@/services/xmlToJson';
import { gatherData, parseLSXFiles, parseTreasureTables, removeItemsFromLSX } from '@/services/parseFolder';

const DragAndDropContainer: React.FC = () => {
    const [jsonOutput, setJsonOutput] = useState('');
    const [isDragging, setIsDragging] = useState(false);
    const [isFolderLoaded, setIsFolderLoaded] = useState(false);
    const [modName, setModName] = useState('Mod');
    const [gameObjectData, setGameObjectData] = useState<GameObjectData[]>([]);
    const [selectedTemplateNames, setSelectedTemplateNames] = useState<string[]>([]);

    // Pipeline for processing dropped folder
    const executePipeline = useCallback(async (rootItem: FileSystemEntry) => {
        setModName(rootItem.name);
        const files = await gatherData(rootItem);
        const lsxData = await parseLSXFiles(files);
        const treasureData = await parseTreasureTables(files);
        const finalData = removeItemsFromLSX(lsxData, treasureData);
        setGameObjectData(finalData);

        console.debug("Final data: ", finalData);
        if (finalData.length > 0) {
            setIsFolderLoaded(true);
        }

        // Extract template names from finalData to display in the preview
        const templateNames = finalData.map(item => item.templateName).filter(name => name !== null) as string[];
        if (templateNames.length > 0) {
            setSelectedTemplateNames(templateNames);
        }

        // Construct JSON output
        const ISFJSON = constructJSON(finalData);
        setJsonOutput(JSON.stringify(ISFJSON, null, 2));
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

    const onDragEnter = useCallback((event: React.DragEvent<HTMLDivElement>) => {
        setIsDragging(true);
        event.preventDefault();
    }, []);

    const onDragLeave = useCallback((event: React.DragEvent<HTMLDivElement>) => {
        setIsDragging(false);
        event.preventDefault();
    }, []);

    const onPaste = useCallback((event: React.ClipboardEvent<HTMLDivElement>) => {
        setIsFolderLoaded(false);
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

    // Allow drag and drop to work on the entire document (i.e. + child elements). This adds drag and drop event listeners to the document itself, not just the component.
    useEffect(() => {
        const handleDragOver = (event: DragEvent) => {
            event.preventDefault();
            setIsDragging(true);
        };

        const handleDragEnter = (event: DragEvent) => {
            event.preventDefault();
            setIsDragging(true);
        };

        const handleDragLeave = (event: DragEvent) => {
            event.preventDefault();
            setIsDragging(false);
        };

        document.addEventListener('dragover', handleDragOver);
        document.addEventListener('dragenter', handleDragEnter);
        document.addEventListener('dragleave', handleDragLeave);

        return () => {
            document.removeEventListener('dragover', handleDragOver);
            document.removeEventListener('dragenter', handleDragEnter);
            document.removeEventListener('dragleave', handleDragLeave);
        };
    }, [onDrop]);

    const handleSaveJSON = () => {
        const element = document.createElement('a');
        const file = new Blob([jsonOutput], { type: 'application/json' });
        element.href = URL.createObjectURL(file);
        element.download = 'ItemShipmentFrameworkConfig.json';
        document.body.appendChild(element);
        element.click();
        document.body.removeChild(element);
    };

    const renderContent = () => {
        if (isDragging) {
            return (
                <p className="text-2xl text-blue-500 font-bold">Drop to generate the ISF config JSON</p>
            );
        } else if (isFolderLoaded) {
            return (
                <div className="flex flex-col items-center text-xl text-gray-400">
                    <p className='text-bold'>{modName} parsed successfully.</p>
                    <p className="ml-2">You can still drop in another mod.</p>
                </div>
            );
        } else {
            return (
                <p className="text-xl text-gray-400">Drag and drop or paste your mod folder here</p>
            );
        }
    };

    const getBorderClass = () => {
        if (isDragging) {
            return 'border-blue-500';
        } else if (isFolderLoaded) {
            return 'border-gray-800';
        } else {
            return 'border-gray-400';
        }
    };

    return (
        <div
            onDrop={onDrop}
            onDragEnter={onDragEnter}
            onDragLeave={onDragLeave}
            onPaste={onPaste}
            onDragOver={(event: React.DragEvent<HTMLDivElement>) => event.preventDefault()}
            className={`flex flex-col items-center ${isFolderLoaded ? 'justify-start' : 'justify-center'} h-screen w-full border-2 border-dashed ${getBorderClass()}`}
        >
            <div className="flex flex-col items-center justify-center h-[100px] w-full my-4">
                {renderContent()}
            </div>
            {jsonOutput && (
                <>
                    <hr className="w-screen border-1 rounded-[10px] border-gray-500 opacity-[50%]" />
                    <DragAndDropPreview
                        jsonOutput={jsonOutput}
                        handleSaveJSON={handleSaveJSON}
                        templateNames={selectedTemplateNames}
                    />
                </>
            )}
        </div>
    );
};
export default DragAndDropContainer;
