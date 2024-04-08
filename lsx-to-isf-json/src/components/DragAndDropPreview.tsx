import React from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faSave } from '@fortawesome/free-solid-svg-icons';
import { Prism as SyntaxHighlighter } from 'react-syntax-highlighter';
import { atomDark } from 'react-syntax-highlighter/dist/cjs/styles/prism';

interface DragAndDropPreviewProps {
    jsonOutput: string;
    templateNames: string[];
    handleSaveJSON: () => void;
}

const DragAndDropPreview: React.FC<DragAndDropPreviewProps> = ({
    jsonOutput,
    templateNames,
    handleSaveJSON,
}) => {
    return (
        <div className="w-full max-w-[50%] mx-4 mt-8">
            <div className="flex flex-col">
                <div>
                    <b className="text-xl mt-4 mb-2">Templates included in the JSON:</b>
                    <ul className="list-disc pl-8 mb-8">
                        {templateNames.map((templateName) => (
                            <li key={templateName}>{templateName}</li>
                        ))}
                    </ul>
                </div>
                <div className="flex flex-col">
                    <button
                        onClick={handleSaveJSON}
                        className="bg-[#6f69e0] text-white font-bold py-4 px-4 mt-0 rounded transition-colors duration-150 ease-in-out hover:bg-[#544fb8] flex items-center justify-center"
                    >
                        <FontAwesomeIcon icon={faSave} className="mr-2 text-xl flex items-center" />
                        <span className="text-center text-xl flex items-center">Save ISF JSON</span>
                    </button>
                    <p className="mt-4 mb-2">JSON preview:</p>
                    <div className="max-h-[35vh] rounded-4 overflow-auto">
                        <SyntaxHighlighter
                            onClick={handleSaveJSON}
                            title="Click to save ISF JSON"
                            language="json"
                            style={atomDark} className="p-4 rounded-lg"
                            customStyle={{ cursor: 'pointer', backgroundColor: '#1e1e1e', color: 'white' }}
                        >
                            {jsonOutput}
                        </SyntaxHighlighter>

                    </div>
                </div>
            </div>
        </div>
    );
};

export default DragAndDropPreview;
