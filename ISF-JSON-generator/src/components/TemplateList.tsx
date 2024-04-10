import React, { useState } from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faCopy, faCheck } from '@fortawesome/free-solid-svg-icons';
import { GameObjectData } from '@/services/parseGameObjects';
import SaveJSONButton from './SaveJSON';
import Checkbox from './Checkbox';

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
    const [copiedUUID, setCopiedUUID] = useState<string | null>(null);
    const [copiedUUIDTimeout, setCopiedUUIDTimeout] = useState<ReturnType<typeof setTimeout> | null>(null);

    // Handle copying the UUID to the clipboard and setting the copiedUUID state used for styling
    const handleCopyUUID = (uuid: string) => {
        navigator.clipboard.writeText(uuid);
        setCopiedUUID(uuid);

        // Clear the previous timeout if it exists
        if (copiedUUIDTimeout) {
            clearTimeout(copiedUUIDTimeout);
        }

        // Set a new timeout to reset the copiedUUID state
        const newTimeout = setTimeout(() => {
            setCopiedUUID(null);
        }, 2000);
        setCopiedUUIDTimeout(newTimeout);
    };

    return (
        <div className="flex-1 overflow-auto">
            <b className="text-xl mt-4 mb-">Templates parsed from the JSON for shipping:</b>
            <ul className="list-disc pl-4 mb-8 mt-2 max-h-[20vh] overflow-auto select-none">
                {gameObjectData.map((gameObject) => (
                    <li key={gameObject.templateUUID} className="flex items-center justify-between mx-2 select-none">
                        <Checkbox
                            checked={selectedTemplates.includes(gameObject.templateUUID || '')}
                            onClick={() => handleTemplateSelection(gameObject.templateUUID || '', !selectedTemplates.includes(gameObject.templateUUID || ''))}
                        >
                            {gameObject.templateName}
                        </Checkbox>
                        <div className="flex items-center">
                            <span className="text-right cursor-pointer select-none" onClick={() => handleTemplateSelection(gameObject.templateUUID || '', !selectedTemplates.includes(gameObject.templateUUID || ''))}>({gameObject.templateUUID})</span>
                            <button
                                onClick={() => handleCopyUUID(gameObject.templateUUID || '')}
                                className={`ml-2 text-gray-400 hover:text-gray-500 focus:outline-none transition-colors duration-200 ${copiedUUID === gameObject.templateUUID ? 'text-green-500' : ''}`}
                            >
                                <FontAwesomeIcon icon={copiedUUID === gameObject.templateUUID ? faCheck : faCopy} className="text-lg" />
                            </button>
                        </div>
                    </li>
                ))}
            </ul>
            <SaveJSONButton handleSaveJSON={handleSaveJSON} />
        </div>
    );
};

export default TemplateList;
