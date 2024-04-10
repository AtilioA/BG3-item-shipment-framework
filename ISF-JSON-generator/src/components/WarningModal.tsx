import { MAX_NON_CONTAINER_ITEMS } from '@/config/config';
import React, { useState } from 'react';

interface WarningModalProps {
    isVisible: boolean;
    onClose: () => void;
}

const WarningModal: React.FC<WarningModalProps> = ({ isVisible, onClose }) => {
    const [hasClickedLink, setHasClickedLink] = useState(false);

    if (!isVisible) return null;

    return (
        <div className="fixed inset-0 z-10 flex items-center justify-center overflow-y-auto bg-gray-900 bg-opacity-75">
            <div className="rounded-lg shadow-lg p-6 max-w-lg w-full bg-gray-800">
                <h2 className="text-2xl font-bold mb-4">Warning</h2>
                <p>This mod contains <span className='font-bold'>over {MAX_NON_CONTAINER_ITEMS} items outside of a container</span>.</p>
                <p>This will lead to a cluttered mailbox for your users.</p>
                <p>Please consider <a
                    className='font-bold text-volition-purple hover:text-volition-purple/80 transition-hover'
                    href="https://www.nexusmods.com/baldursgate3/mods/8418"
                    target="_blank"
                    rel="noopener noreferrer"
                    onClick={() => setHasClickedLink(true)}
                >adding these items to a container</a>.</p>

                <div className="flex justify-end mt-4">
                    <button
                        className="bg-gray-500 hover:bg-gray-600 transition-hover text-white font-bold py-2 px-4 mr-2 rounded"
                        onClick={onClose}
                    >
                        Let them eat cake
                    </button>
                    <button
                        className="bg-volition-purple hover:bg-volition-purple/80 transition-hover text-white font-bold py-2 px-4 rounded mr-2"
                        onClick={() => {
                            if (!hasClickedLink) {
                                window.open("https://www.nexusmods.com/baldursgate3/mods/8418", "_blank");
                                setHasClickedLink(true);
                            }
                            onClose();
                        }}
                    >
                        I&apos;ll do it
                    </button>
                </div>
            </div>
        </div>
    );
};

export default WarningModal;
