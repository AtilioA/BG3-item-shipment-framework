import React, { useEffect } from 'react';

interface ModalProps {
    isVisible: boolean;
    setIsVisible: (isVisible: boolean) => void;
    onClose: () => void;
    children: React.ReactNode;
}

const Modal: React.FC<ModalProps> = ({ isVisible, setIsVisible, onClose, children }) => {
    useEffect(() => {
        const handleOutsideClick = (event: MouseEvent) => {
            const target = event.target as Element;
            if (target && !target.closest('.modal')) {
                onClose();
                setIsVisible(false);
            }
        };

        document.addEventListener('click', handleOutsideClick);
        return () => {
            document.removeEventListener('click', handleOutsideClick);
        };
    }, [onClose, setIsVisible]);

    if (!isVisible) {
        return null;
    }

    return (
        <div className="fixed inset-0 z-10 flex items-center justify-center overflow-y-auto bg-gray-900 bg-opacity-75">
            <div className="rounded-lg shadow-lg p-6 max-w-lg w-full bg-gray-800">
                {children}
                {/* <div className="flex justify-end mt-4">
                    <button
                        className="bg-gray-500 hover:bg-gray-600 transition-hover text-white font-bold py-2 px-4 rounded"
                        onClick={onClose}
                    >
                        Close
                    </button>
                </div> */}
            </div>
        </div>
    );
};

export default Modal;
