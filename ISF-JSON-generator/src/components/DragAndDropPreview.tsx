import React from 'react';
import { Prism as SyntaxHighlighter } from 'react-syntax-highlighter';
import { atomDark } from 'react-syntax-highlighter/dist/cjs/styles/prism';
import { GameObjectData } from '@/services/parseGameObjects';
import TemplateList from './TemplateList';

interface DragAndDropPreviewProps {
    jsonOutput: string;
    handleSaveJSON: () => void;
    gameObjectData: GameObjectData[];
    handleTemplateSelection: (templateUUID: string, isSelected: boolean) => void;
    selectedTemplates: string[];
}

const DragAndDropPreview: React.FC<DragAndDropPreviewProps> = ({
    jsonOutput,
    handleSaveJSON,
    gameObjectData,
    handleTemplateSelection,
    selectedTemplates,
}) => {
    // Split the JSON output into lines and limit it to 500 lines
    const lines = jsonOutput.split('\n');
    const truncatedJsonOutput = lines.length > 500
        ? `${lines.slice(0, 500).join('\n')}\n...\n(JSON output has been truncated.)\n(Please download it and view it full in a text editor.)`
        : jsonOutput;

    return (
        <div className="w-full max-w-[50%] mx-4 mt-8 flex flex-col">
            <TemplateList
                gameObjectData={gameObjectData}
                selectedTemplates={selectedTemplates}
                handleTemplateSelection={handleTemplateSelection}
                handleSaveJSON={handleSaveJSON}
            />
            <div className="flex flex-col">
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
