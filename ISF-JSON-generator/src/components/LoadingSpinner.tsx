import React from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faSpinner } from '@fortawesome/free-solid-svg-icons';

const LoadingSpinner: React.FC = () => {
    return (
        <div className="flex items-center justify-center h-full flex-col gap-4">
            <p><i>Attempting to parse mod...</i></p>
            <FontAwesomeIcon
                icon={faSpinner}
                className="fa-spin text-gray-00 text-4xl"
            />
        </div>
    );
};

export default LoadingSpinner;
