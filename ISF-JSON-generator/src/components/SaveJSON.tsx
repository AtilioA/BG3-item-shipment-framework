import React from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faSave } from '@fortawesome/free-solid-svg-icons';

interface SaveJSONButtonProps {
    handleSaveJSON: () => void;
}

const SaveJSONButton: React.FC<SaveJSONButtonProps> = ({ handleSaveJSON }) => {
    return (
        <div className="flex flex-col">
            <button
                onClick={handleSaveJSON}
                className="bg-volition-purple/65 text-white font-bold py-4 px-4 mt-0 rounded transition-hover hover:bg-volition-purple/45 flex items-center justify-center"
            >
                <FontAwesomeIcon icon={faSave} className="mr-2 text-xl flex items-center" />
                <p className="text-center text-xl flex items-center">Save ISF JSON</p>
            </button>
            <p className="mt-1 text-center text-base text-gray-500 cursor-default">*Place this JSON alongside your mod&apos;s meta.lsx file.</p>
        </div>
    );
};

export default SaveJSONButton;
