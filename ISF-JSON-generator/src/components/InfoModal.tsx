import React from 'react';
import Modal from './Modal';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faInfoCircle } from '@fortawesome/free-solid-svg-icons';

interface InfoModalProps {
    isVisible: boolean;
    setIsVisible: (isVisible: boolean) => void;
    onClose: () => void;
}

const InfoModal: React.FC<InfoModalProps> = ({ isVisible, setIsVisible, onClose }) => {
    return (
        <Modal isVisible={isVisible} setIsVisible={setIsVisible} onClose={onClose}>
            <div className='mb-4 flex flex-row items-center align-middle'>
                <FontAwesomeIcon
                    icon={faInfoCircle}
                    className="mr-2 text-gray-600 hover:text-gray-500 cursor-default"
                />
                <h2 className="text-2xl font-bold">Templates</h2>
            </div>
            <p>You can remove/add templates with the checkboxes and also review the (collapsed) ignored templates to see if anything is missing. Feel free to report issues on our mod page.</p>
            <div className="flex justify-end mt-4">
                <button
                    className="bg-volition-purple hover:bg-volition-purple/80 transition-hover text-white font-bold py-2 px-4 rounded"
                    onClick={onClose}
                >
                    OK
                </button>
            </div>
        </Modal>
    );
};

export default InfoModal;
