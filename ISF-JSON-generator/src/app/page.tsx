"use client"

import DragAndDropContainer from '@/components/DragAndDrop';
import Footer from '@/components/Footer';
import React from 'react';

import Image from 'next/image';

const Page: React.FC = () => {
    return (
        <div className="flex flex-col items-center justify-start h-screen bg-gray-900 text-white">
            <h1 className="text-3xl items-center align-center font-bold mb-6 mt-4">
                <a href="/" className="text-center hover:text-gray-400 transition-hover flex items-center">
                    <Image src="/Item_CONT_GEN_Mailbox_C.png" alt="ISF icon" width={40} height={40} className="mr-2" />
                    ISF config JSON generator
                </a>
            </h1>
            <div className="flex-1 w-full overflow-y-auto">
                <DragAndDropContainer />
            </div>
            <Footer />
        </div>
    );
};

export default Page;
