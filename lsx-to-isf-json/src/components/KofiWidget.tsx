import { useEffect, useState } from 'react';

const KofiWidget: React.FC = () => {
    const [loaded, setLoaded] = useState(false);

    useEffect(() => {
        const kofiScript = document.createElement("script");
        kofiScript.src = "https://storage.ko-fi.com/cdn/scripts/overlay-widget.js";
        kofiScript.async = true;
        kofiScript.addEventListener('load', () => setLoaded(true));
        document.body.appendChild(kofiScript);
    }, []);

    useEffect(() => {
        if (!loaded) return;
        (window as any).kofiWidgetOverlay.draw('volitio', {
            'type': 'floating-chat',
            'floating-chat.donateButton.text': 'Tip Volitio',
            'floating-chat.donateButton.background-color': '#6c66dd',
            'floating-chat.donateButton.text-color': '#fff'
        });
    }, [loaded]);

    return null;
};

export default KofiWidget;
