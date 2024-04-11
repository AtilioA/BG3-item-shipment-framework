import React, { useState } from 'react';

interface CheckboxProps {
    checked: boolean;
    onClick: () => void;
    className?: string;
    children?: React.ReactNode;
}

const Checkbox: React.FC<CheckboxProps> = ({ checked, onClick, className = '', children }) => {
    const [isPressed, setIsPressed] = useState(false);
    const [isHovered, setIsHovered] = useState(false);

    const handleMouseDown = () => {
        setIsPressed(true);
    };

    const handleMouseUp = () => {
        setIsPressed(false);
    };

    const handleMouseEnter = () => {
        setIsHovered(true);
    };

    const handleMouseLeave = () => {
        setIsHovered(false);
    };

    return (
        <div
            className={`flex items-center cursor-pointer select-none ${className} hover:text-volition-purple transition-colors`}
            onClick={onClick}
            onMouseDown={handleMouseDown}
            onMouseUp={handleMouseUp}
            onMouseEnter={handleMouseEnter}
            onMouseLeave={handleMouseLeave}
        >
            <div
                className={`w-4 h-4 mr-2 rounded-sm transition-colors ${checked
                    ? `bg-volition-purple ${isPressed ? 'animation-press' : ''}`
                    : `bg-gray-200 border-gray-400 hover:border-volition-purple ${isPressed ? 'scale-95 transition-transform duration-100' : ''} ${isHovered ? 'bg-gray-400' : ''}`
                }`}
            >
                {checked && (
                    <div className="w-full h-full rounded-sm bg-white flex items-center justify-center">
                        <div className={`w-3 h-3 bg-volition-purple rounded-sm transition-transform scale-100 ${isPressed ? 'animation-press-text' : ''}`} />
                    </div>
                )}
            </div>
            <span className={`font-bold select-none transition-colors ${isPressed ? 'animation-press-text' : ''}`}>
                {children}
            </span>
        </div>
    );
};
export default Checkbox;
