import React from 'react';

interface CheckboxProps {
    checked: boolean;
    onClick: () => void;
    className?: string;
    children?: React.ReactNode;
}

const Checkbox: React.FC<CheckboxProps> = ({ checked, onClick, className = '', children }) => {
    return (
        <div
            className={`flex items-center cursor-pointer select-none ${className} hover:text-volition-purple transition-colors`}
            onClick={onClick}
        >
            <div
                className={`w-4 h-4 mr-2 rounded-sm transition-colors ${checked
                    ? 'bg-volition-purple'
                    : 'bg-gray-200 border-gray-400 hover:border-volition-purple'
                    }`}
            >
                {checked && (
                    <div className="w-full h-full rounded-sm bg-white flex items-center justify-center">
                        <div className="w-3 h-3 bg-volition-purple rounded-sm transition-transform scale-100" />
                    </div>
                )}
            </div>
            <span className="font-bold select-none transition-colors">
                {children}
            </span>
        </div>
    );
};

export default Checkbox;
