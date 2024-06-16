import { MAX_NON_CONTAINER_ITEMS } from '@/config/config';
import React, { useState } from 'react';
import Modal from './Modal';
import { faExclamationCircle } from '@fortawesome/free-solid-svg-icons';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

interface WarningModalProps {
    isVisible: boolean;
    setIsVisible: (isVisible: boolean) => void;
    onClose: () => void;
}

const WarningModal: React.FC<WarningModalProps> = ({ isVisible, setIsVisible, onClose }) => {
    const [hasClickedLink, setHasClickedLink] = useState(false);

    return (
        <Modal isVisible={isVisible} setIsVisible={setIsVisible} onClose={onClose}>
            <div className='mb-4 flex flex-row items-center align-middle'>
                <FontAwesomeIcon
                    icon={faExclamationCircle}
                    className="mr-2 text-yellow-500 hover:text-yellow-600 cursor-default"
                />
                <h2 className="text-2xl font-bold">Warning</h2>
            </div>
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
                            window.open('https://www.nexusmods.com/baldursgate3/mods/8418', '_blank');
                            setHasClickedLink(true);
                        }
                        onClose();
                    }}
                >
                    I&apos;ll do it
                </button>
            </div>
        </Modal>
    );
};

export default WarningModal;
