import React, { useState, useEffect } from 'react';
import Modal from './Modal';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faCheckCircle } from '@fortawesome/free-solid-svg-icons';

interface ConfirmationModalProps {
    isVisible: boolean;
    setIsVisible: (isVisible: boolean) => void;
    onClose: () => void;
}

export default function ConfirmationModal({ isVisible, setIsVisible, onClose }: ConfirmationModalProps) {

    return (
        <Modal isVisible={isVisible} setIsVisible={setIsVisible} onClose={onClose}>
            <div className='mb-4 flex flex-row items-center align-middle'>
                <FontAwesomeIcon
                    icon={faCheckCircle}
                    className="mr-2 text-green-500 hover:text-green-600 cursor-default"
                />
                <h2 className="text-2xl font-bold">Integration completed 🎉!</h2>
            </div>
            <p>Ensure that this JSON file is placed next to your mod&apos;s <span className='text-metalsx'>meta.lsx</span> file and retains its original name (<b>ItemShipmentFrameworkConfig.json</b>).</p>
            <hr className="w-full my-4 border-1 rounded-[10px] border-gray-500 opacity-[50%]" />
            <p>You can now optionally add ISF as a dependency in your mod page.</p>
            <div className="flex justify-end mt-4">
                <button
                    className="bg-volition-purple hover:bg-volition-purple/80 transition-hover text-white font-bold py-2 px-4 rounded"
                    onClick={() => {
                        onClose();
                        setIsVisible(false);
                    }}
                >
                    OK
                </button>
            </div>
        </Modal>
    );
}
