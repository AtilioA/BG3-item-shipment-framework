import React from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faSave } from '@fortawesome/free-solid-svg-icons';
import { Prism as SyntaxHighlighter } from 'react-syntax-highlighter';
import { atomDark } from 'react-syntax-highlighter/dist/cjs/styles/prism';
import { GameObjectData } from '@/services/parseGameObjects';

interface DragAndDropPreviewProps {
    jsonOutput: string;
    handleSaveJSON: () => void;
    gameObjectData: GameObjectData[];
}

const DragAndDropPreview: React.FC<DragAndDropPreviewProps> = ({
    jsonOutput,
    handleSaveJSON,
    gameObjectData
}) => {
    // Split the JSON output into lines and limit it to 500 lines
    const lines = jsonOutput.split('\n');
    const truncatedJsonOutput = lines.length > 500
        ? `${lines.slice(0, 500).join('\n')}\n...\n(JSON output has been truncated.)\n(Please download it and view it full in a text editor.)`
        : jsonOutput;


    return (
        <div className="w-full max-w-[50%] mx-4 mt-8 flex flex-col">
            <div className="flex-1 overflow-scroll">
                <b className="text-xl mt-4 mb-">Templates included in the JSON for shipping:</b>
                <ul className="list-disc pl-4 mb-8 mt-2 max-h-[20vh] overflow-auto">
                    {gameObjectData.map((gameObject) => (
                        <li key={gameObject.templateUUID} className="flex justify-between mx-2">
                            <span className="font-bold">{gameObject.templateName}</span>
                            <span className="text-right">({gameObject.templateUUID})</span>
                        </li>
                    ))}
                </ul>
            </div>
            <div className="flex flex-col">
                <button
                    onClick={handleSaveJSON}
                    className="bg-volition-purple/80 text-white font-bold py-4 px-4 mt-0 rounded transition-hover hover:bg-volition-purple/60 flex items-center justify-center"
                >
                    <FontAwesomeIcon icon={faSave} className="mr-2 text-xl flex items-center" />
                    <p className="text-center text-xl flex items-center">Save ISF JSON</p>
                </button>
                <p className="mt-1 text-center text-base text-gray-500 cursor-default">*Save this JSON beside your mod's meta.lsx file.</p>
                <hr className="w-full border-1 rounded-[10px] mt-4 border-gray-500 opacity-[50%]" />

                <p className="mt-4 mb-2">JSON preview:</p>
                <div className="rounded-4 overflow-auto max-h-[40vh]">
                    <SyntaxHighlighter
                        onClick={handleSaveJSON}
                        title="Click to save ISF JSON"
                        language="json"
                        style={atomDark} className="p-4 rounded-lg"
                        customStyle={{ cursor: 'pointer', backgroundColor: '#1e1e1e', color: 'white' }}
                    >
                        {truncatedJsonOutput}
                    </SyntaxHighlighter>
                </div>
            </div>
        </div>
    );
};

export default DragAndDropPreview;
