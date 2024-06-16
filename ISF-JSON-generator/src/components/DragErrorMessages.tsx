import React from 'react';

interface DragErrorMessagesProps {
    errorMessages: string[];
}

const DragErrorMessages: React.FC<DragErrorMessagesProps> = ({ errorMessages }) => {
    return (
        <div className="flex flex-col items-center justify-center h-full w-full text-red-500 font-bold text-2xl">
            {errorMessages.map((message, index) => (
                <p key={index}>{message}</p>
            ))}
            <p className="mt-4 text-gray-500 text-sm cursor-default">You can still attempt dropping in another mod.</p>
        </div>
    );
};

export default DragErrorMessages;
