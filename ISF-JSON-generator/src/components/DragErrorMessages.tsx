import React from 'react';

interface DragErrorMessagesProps {
    errorMessages: string[];
}

const DragErrorMessages: React.FC<DragErrorMessagesProps> = ({ errorMessages }) => {
    const renderMessage = (message: string) => {
        const parts = splitMessageIntoHyperlinks(message);
        return parts.map((part, index) => renderHyperlink(part, index));
    };

    const splitMessageIntoHyperlinks = (message: string) => {
        return message.split(/(\[.*?\]\(.*?\))/);
    };

    const renderHyperlink = (part: string, index: number) => {
        const match = part.match(/\[(.*?)\]\((.*?)\)/);
        if (match) {
            const [, text, url] = match;
            return createLink(text, url, index);
        }
        return <span key={index}>{part}</span>;
    };

    const createLink = (text: string, url: string, index: number) => (
        <a
            key={index}
            href={url}
            target="_blank"
            rel="noopener noreferrer"
            className="text-blue-500 hover:underline"
        >
            {text}
        </a>
    );

    return (
        <div className="flex flex-col items-center justify-center h-full w-full text-red-500 font-bold text-2xl gap-4">
            {errorMessages.map((message, index) => (
                <p key={index}>{renderMessage(message)}</p>
            ))}
            <hr className="my-5 border-t-1 border-gray-600 border-opacity-33 w-1/4" />
            <p className="text-gray-500 text-sm cursor-default">You can still attempt to drop in another mod.</p>
            <p className="mt-1 text-gray-500 text-xs cursor-default">If you believe this is incorrect, please report it on our mod page.</p>
        </div>
    );
};

export default DragErrorMessages;
