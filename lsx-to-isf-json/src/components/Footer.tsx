import React from 'react';
import KofiWidget from './KofiWidget';

const Footer: React.FC = () => {
    return (
        <footer className="fixed bottom-0 h-[78px] w-full bg-gray-800 py-2 flex items-center justify-center text-center text-sm border-t border-gray-500 border-opacity-50">
            <div>
                <p className="text-gray-400 text-sm">Processing is done locally and no data is sent to any servers.</p>
                <p className='text-gray-400 text-base'>Built by <a href='https://www.nexusmods.com/baldursgate3/users/9505990?tab=user+files' className="font-bold text-[#7f78ff]">Volitio</a>.</p>
            </div>
            <KofiWidget />
        </footer>
    );
};

export default Footer;
