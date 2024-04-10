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
            className={`flex items-center cursor-pointer select-none ${className}`}
            onClick={onClick}
        >
            <input
                type="checkbox"
                checked={checked}
                readOnly
                className="mr-2 cursor-pointer select-none"
            />
            <span className="font-bold select-none">
                {children}
            </span>
        </div>
    );
};

export default Checkbox;
