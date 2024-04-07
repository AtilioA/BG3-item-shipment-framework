// src/components/DragAndDrop/DragAndDropPreview.tsx
import React from 'react';

interface DragAndDropPreviewProps {
  jsonOutput: string;
  handleSaveJSON: () => void;
}

const DragAndDropPreview: React.FC<DragAndDropPreviewProps> = ({
  jsonOutput,
  handleSaveJSON,
}) => {
  return (
    <div className="mt-8 w-full max-h-[50vh] overflow-auto">
      <button
        onClick={handleSaveJSON}
        className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
      >
        Save JSON
      </button>
      <hr className="border-gray-600 my-4" />
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
