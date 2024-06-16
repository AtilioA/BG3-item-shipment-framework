import React, { useState, useEffect } from 'react';

interface ConfirmationModalProps {
    onClose: () => void;
}

export default function ConfirmationModal({ onClose }: ConfirmationModalProps) {
    const [isModalVisible, setIsModalVisible] = useState(true);

    useEffect(() => {
        // Add event listener to handle clicks outside the modal, then use it to close the modal
        const handleOutsideClick = (event: MouseEvent) => {
            const target = event.target as Element;
            if (target && !target.closest('.modal')) {
                onClose();
                setIsModalVisible(false);
            }
        };

        document.addEventListener('click', handleOutsideClick);
        return () => {
            document.removeEventListener('click', handleOutsideClick);
        };
    }, [onClose]);

    const renderModalContent = () => {
        return (
            <div className="modal rounded-lg shadow-lg p-6 max-w-xl w-full bg-gray-800">
                <h2 className="text-2xl font-bold mb-4">Integration completed 🎉!</h2>
                <p>Ensure that this JSON file is placed next to your mod&apos;s <span className='text-metalsx'>meta.lsx</span> file and retains its original name (<b>ItemShipmentFrameworkConfig.json</b>).</p>
                <hr className="w-full my-4 border-1 rounded-[10px] border-gray-500 opacity-[50%]" />

                <p>You can now optionally add ISF as a dependency in your mod page.</p>
                <div className="flex justify-end mt-4">
                    <button
                        className="bg-volition-purple hover:bg-volition-purple/80 transition-hover text-white font-bold py-2 px-4 rounded"
                        onClick={() => {
                            onClose();
                            setIsModalVisible(false);
                        }}
                    >
                        OK
                    </button>
                </div>
            </div>
        );
    };

    return (
        isModalVisible && (
            <div className="fixed inset-0 z-10 flex items-center justify-center overflow-y-auto bg-gray-900 bg-opacity-75">
                {renderModalContent()}
            </div>
        )
    );
};
