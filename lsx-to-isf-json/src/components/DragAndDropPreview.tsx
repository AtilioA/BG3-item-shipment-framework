// src/components/DragAndDrop/DragAndDropPreview.tsx
import React from 'react';

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
    <div className="mt-8 w-full max-h-[50vh] overflow-auto">
      <hr className="border-gray-600 my-4" />
      <b className="text-xl mt-4 mb-2">Templates included in the JSON:</b>
      <ul className="list-disc pl-8 mb-8">
        {templateNames.map((templateName) => (
          <li key={templateName}>{templateName}</li>
        ))}
      </ul>
      <button
        onClick={handleSaveJSON}
        className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 mt-0 rounded"
      >
        Save JSON
      </button>
      <p className="mt-4 mb-2">JSON preview:</p>
      <pre
        onClick={handleSaveJSON}
        style={{ cursor: 'pointer' }}
        title="Click to save ISF JSON"
        className="mt-4 p-4 bg-gray-800 rounded-lg text-white"
      >
        {jsonOutput}
      </pre>
    </div>
  );
};

export default DragAndDropPreview;
