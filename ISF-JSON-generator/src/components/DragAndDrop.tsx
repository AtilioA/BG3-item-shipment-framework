import React, { useCallback, useEffect, useState } from 'react';
import DragAndDropPreview from './DragAndDropPreview';
import { GameObjectData } from '@/services/parseGameObjects';
import { constructJSON } from '@/services/xmlToJson';
import { gatherData, parseLSXFiles, parseTreasureTables, removeItemsFromLSX } from '@/services/parseFolder';
import WarningModal from './WarningModal';
import LoadingSpinner from './LoadingSpinner';
import { MAX_NON_CONTAINER_ITEMS } from '@/config/config';
import DragErrorMessages from './DragErrorMessages';

const DragAndDropContainer: React.FC = () => {
    // JSON output states
    const [jsonOutput, setJsonOutput] = useState('');

    // Drag and drop states
    const [isDragging, setIsDragging] = useState(false);
    const [isProcessing, setIsProcessing] = useState(false);
    const [errorMessages, setErrorMessages] = useState<string[]>([]);

    // Folder states
    const [isFolderLoaded, setIsFolderLoaded] = useState(false);
    const [modName, setModName] = useState('Mod');

    // Parsed data states
    const [gameObjectData, setGameObjectData] = useState<GameObjectData[]>([]);
    const [filteredObjectData, setFilteredObjectData] = useState<GameObjectData[]>([]);
    const [nonContainerItemCount, setNonContainerItemCount] = useState(0);
    const [showWarningModal, setShowWarningModal] = useState(false);
    const [selectedTemplates, setSelectedTemplates] = useState<string[]>(
        gameObjectData.map((gameObject) => gameObject.templateUUID || '')
    );

    // Handle template selection for JSON output; add or remove template UUIDs from the selectedTemplates array based on the checkbox state
    const handleTemplateSelection = (templateUUID: string, isSelected: boolean) => {
        setSelectedTemplates((prevSelectedTemplates) => {
            if (isSelected) {
                return [...prevSelectedTemplates, templateUUID];
            } else {
                return prevSelectedTemplates.filter((uuid) => uuid !== templateUUID);
            }
        });
    };

    function resetState(rootItem: FileSystemEntry) {
        setGameObjectData([]);
        setModName(rootItem.name);
        setJsonOutput('');
        setErrorMessages([]);
        setSelectedTemplates([]);
        setShowWarningModal(false);
        setIsFolderLoaded(false);
        setGameObjectData([]);
        setFilteredObjectData([]);
    }

    // Pipeline for processing dropped folder
    const executePipeline = useCallback(async (rootItem: FileSystemEntry) => {
        setIsProcessing(true);

        // Clean up previous data
        resetState(rootItem);

        const files = await gatherData(rootItem);
        const lsxData = await parseLSXFiles(files);
        const treasureData = await parseTreasureTables(files);
        const filteredData = removeItemsFromLSX(lsxData, treasureData);
        const validData = filteredData.validItems;
        setSelectedTemplates(validData.map((gameObject) => gameObject.templateUUID || ''));
        setGameObjectData(validData);

        setFilteredObjectData(filteredData.filteredItems);

        // Count non-container items
        const nonContainerItems = validData.filter(item => item.isContainer === false);
        setNonContainerItemCount(nonContainerItems.length);
        if (nonContainerItems.length > MAX_NON_CONTAINER_ITEMS) {
            console.debug(`Too many items outside of a container (${nonContainerItemCount}). Showing warning modal.`);
            setShowWarningModal(true);
        }

        setIsProcessing(false);

        if (validData.length === 0) {
            console.error('No valid mod templates found in the dropped folder.');
            setErrorMessages([
                'No valid mod templates found in the dropped folder.',
                'Ensure the folder contains a mod that has root templates.',
                'If you believe this is an error, please report it on our mod page.'
            ]);
        }

    }, [nonContainerItemCount]);

    useEffect(() => {
        if (gameObjectData.length > 0 || filteredObjectData.length > 0) {
            setIsFolderLoaded(true);

            // Construct JSON output
            console.debug(`Constructing JSON with ${selectedTemplates.length} selected templates.`);
            const filterSelectedTemplates: GameObjectData[] = [...gameObjectData, ...filteredObjectData].filter((data) => selectedTemplates.includes(data.templateUUID || ''));
            const ISFJSON = constructJSON(filterSelectedTemplates);
            setJsonOutput(JSON.stringify(ISFJSON, null, 2));
        }
    }, [gameObjectData, filteredObjectData, selectedTemplates]);

    // For some reason, React.DragEvent<HTMLDivElement> will 'break' this
    const onDrop = useCallback((event: any) => {
        event.preventDefault();
        if (event.dataTransfer === null) {
            console.error('Data transfer is null');
            return;
        }

        if (isProcessing) {
            return;
        }

        const items = event.dataTransfer.items;

        for (let i = 0; i < items.length; i++) {
            const entry = items[i].webkitGetAsEntry ? items[i].webkitGetAsEntry() : items[i].getAsEntry();

            if (entry) {
                executePipeline(entry);
            }
        }
        setIsDragging(false);
    }, [executePipeline, isProcessing]);

    const onDragEnter = useCallback((event: React.DragEvent<HTMLDivElement>) => {
        if (isProcessing) {
            return;
        }

        setIsDragging(true);
        event.preventDefault();
    }, [isProcessing]);

    const onDragLeave = useCallback((event: React.DragEvent<HTMLDivElement>) => {
        if (isProcessing) {
            return;
        }

        setIsDragging(false);
        event.preventDefault();
    }, [isProcessing]);

    const onPaste = useCallback((event: React.ClipboardEvent<HTMLDivElement>) => {
        if (isProcessing) {
            return;
        }
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
    }, [executePipeline, isProcessing]);

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
        if (isProcessing) {
            return <LoadingSpinner />;
        } else if (errorMessages.length > 0) {
            return <DragErrorMessages errorMessages={errorMessages} />;
        } else if (isDragging) {
            return (
                <p className="text-2xl text-blue-500 font-bold">Drop to generate the ISF config JSON</p>
            );
        } else if (isFolderLoaded) {
            return (
                <div className="flex flex-col items-center text-xl text-gray-400">
                    <p><span className='font-bold'>{modName}</span> has been parsed successfully.</p>
                    <p className="ml-2 text-base text-gray-500 cursor-default">You can still drop in another mod.</p>
                </div>
            );
        } else {
            return (
                <>
                    <p className="text-xl text-gray-400 text-center">Drag and drop your main mod folder here to automatically generate an ISF JSON for integration</p>
                </>
            );
        }
    };

    const getBorderClass = () => {
        if (isDragging) {
            return 'border-2 border-solid border-blue-500';
        } else if (isFolderLoaded) {
            return '';
        } else {
            return 'border-2 border-dashed border-gray-400';
        }
    };

    return (
        <div
            onDrop={onDrop}
            onDragEnter={onDragEnter}
            onDragLeave={onDragLeave}
            onPaste={onPaste}
            onDragOver={(event: React.DragEvent<HTMLDivElement>) => event.preventDefault()}
            className={`flex flex-col items-center ${isFolderLoaded ? 'justify-start' : 'justify-center'} h-full w-full ${getBorderClass()}} ${isProcessing ? 'cursor-wait' : 'cursor-auto'}`}
        >
            <div className="flex flex-col items-center justify-center h-[100px] w-full px-2 my-4">
                {renderContent()}
            </div>
            {
                jsonOutput && (
                    <>
                        <hr className="w-screen border-1 rounded-[10px] border-gray-500 opacity-[50%]" />
                        <DragAndDropPreview
                            jsonOutput={jsonOutput}
                            handleSaveJSON={handleSaveJSON}
                            gameObjectData={gameObjectData}
                            filteredObjectData={filteredObjectData}
                            handleTemplateSelection={handleTemplateSelection}
                            selectedTemplates={selectedTemplates}
                        />
                    </>
                )
            }
            <WarningModal
                isVisible={showWarningModal}
                setIsVisible={setShowWarningModal}
                onClose={() => {
                    setShowWarningModal(false);
                    setIsDragging(false);
                }}
            />
        </div >
    );
};
export default DragAndDropContainer;
