'use client';

import DragAndDropContainer from '@/components/DragAndDrop';
import Footer from '@/components/Footer';
import React from 'react';

import Image from 'next/image';

import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faGlobe, faBook } from '@fortawesome/free-solid-svg-icons';

const Page: React.FC = () => {
    return (
        <div className="flex flex-col items-center justify-start h-screen bg-gray-900 text-white">
            <h1 className="text-3xl items-center align-center font-bold mb-2 mt-4">
                <a href="/" className="text-center hover:text-gray-400 transition-hover flex items-center">
                    <Image src="/Item_CONT_GEN_Mailbox_C.png" alt="ISF icon" width={40} height={40} className="mr-2" />
                    Item Shipment Framework config JSON generator
                </a>
            </h1>
            <div className="flex items-center gap-4 mb-6">
                <a target="_blank" rel="noopener noreferrer" href="https://www.nexusmods.com/baldursgate3/mods/8295" className="hover:text-gray-400 transition-hover flex items-center">
                    <FontAwesomeIcon icon={faGlobe} className="mr-2 text-orange-400" />
                    Mod page
                </a>
                {/* <div className="border-r border-gray-600 h-8"></div> */}
                <a target="_blank" rel="noopener noreferrer" href="https://github.com/AtilioA/BG3-item-shipment-framework/wiki" className="hover:text-gray-400 transition-hover flex items-center">
                    <FontAwesomeIcon icon={faBook} className="mr-2 text-blue-400" />
                    Docs
                </a>
            </div>
            <div className="flex-1 w-full overflow-y-auto">
                <DragAndDropContainer />
            </div>
            <Footer />
        </div>
    );
};

export default Page;
