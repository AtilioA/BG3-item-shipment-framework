import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import '../styles/globals.css';
import { Analytics } from "@vercel/analytics/next";

const inter = Inter({ subsets: ['latin'] });

export const metadata: Metadata = {
    title: 'ISF config generator',
    description: 'Parses a mod folder into an Item Shipment Framework config JSON file.',
};

export default function RootLayout({
    children,
}: Readonly<{
    children: React.ReactNode;
}>) {
    return (
        <html lang="en">
            <Analytics />
            <body className={inter.className}>
                {children}
            </body>
        </html>
    );
}
