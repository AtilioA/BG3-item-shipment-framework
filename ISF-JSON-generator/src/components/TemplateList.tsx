import React from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faCopy, faSave } from '@fortawesome/free-solid-svg-icons';
import { GameObjectData } from '@/services/parseGameObjects';

interface TemplateListProps {
    gameObjectData: GameObjectData[];
    selectedTemplates: string[];
    handleTemplateSelection: (templateUUID: string, isSelected: boolean) => void;
    handleSaveJSON: () => void;
}

const TemplateList: React.FC<TemplateListProps> = ({
    gameObjectData,
    selectedTemplates,
    handleTemplateSelection,
    handleSaveJSON
}) => {
    return (
        <div className="flex-1 overflow-auto">
            <b className="text-xl mt-4 mb-">Templates parsed from the JSON for shipping:</b>
            <ul className="list-disc pl-4 mb-8 mt-2 max-h-[20vh] overflow-auto select-none">
                {gameObjectData.map((gameObject) => (
                    <li key={gameObject.templateUUID} className="flex items-center justify-between mx-2 select-none">
                        <div className="flex items-center cursor-pointer select-none" onClick={() => handleTemplateSelection(gameObject.templateUUID || '', !selectedTemplates.includes(gameObject.templateUUID || ''))}>
                            <input
                                type="checkbox"
                                checked={selectedTemplates.includes(gameObject.templateUUID || '')}
                                readOnly
                                className="mr-2 cursor-pointer select-none"
                            />
                            <span className="font-bold select-none">{gameObject.templateName}</span>
                        </div>
                        <div className="flex items-center">
                            <span className="text-right cursor-pointer select-none" onClick={() => handleTemplateSelection(gameObject.templateUUID || '', !selectedTemplates.includes(gameObject.templateUUID || ''))}>({gameObject.templateUUID})</span>
                            <button
                                onClick={() => {
                                    navigator.clipboard.writeText(gameObject.templateUUID || '');
                                    console.log(`Copied template UUID: ${gameObject.templateUUID}`);
                                }}
                                className="ml-2 text-gray-400 hover:text-gray-500 focus:outline-none"
                            >
                                <FontAwesomeIcon icon={faCopy} className="text-lg" />
                            </button>
                        </div>
                    </li>
                ))}
            </ul>
            <div className="flex flex-col">

                <button
                    onClick={handleSaveJSON}
                    className="bg-volition-purple/80 text-white font-bold py-4 px-4 mt-0 rounded transition-hover hover:bg-volition-purple/60 flex items-center justify-center"
                >
                    <FontAwesomeIcon icon={faSave} className="mr-2 text-xl flex items-center" />
                    <p className="text-center text-xl flex items-center">Save ISF JSON</p>
                </button>
                <p className="mt-1 text-center text-base text-gray-500 cursor-default">*Place this JSON alongside your mod&apos;s meta.lsx file.</p>
            </div>
        </div>
    );
};

export default TemplateList;
