import React from 'react';

const Footer: React.FC = () => {
  return (
    <footer className="fixed bottom-0 w-full bg-gray-800 py-2 text-center text-sm border-t border-gray-500 border-opacity-50">
      <p className="text-gray-400 text-xs">Processing is done locally and no data is sent to any servers.</p>
      <p className='text-gray-400 text-xs'>Built by <a href='https://www.nexusmods.com/baldursgate3/users/9505990?tab=user+files' className="font-bold text-[#7f78ff]">Volitio</a>.</p>
    </footer>
  );
};

export default Footer;
