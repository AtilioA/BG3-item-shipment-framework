/**
 * Represents the data of a game object.
 */
export interface GameObjectData {
    templateUUID: string | null;
    templateName: string | null;
    templateStats: string | null;
    isContainer: boolean;
}

export function sortGameObjectData(data: GameObjectData[]): GameObjectData[] {
    // Sort the data by templateName
    return data.sort((a, b) => {
        if (a.templateName && b.templateName) {
            return a.templateName.localeCompare(b.templateName);
        }
        return 0;
    });
}

/**
 * Parses a XML document containing Root Template data (.lsx).
 * @param xmlDoc - The XML document (.lsx) to parse.
 * @returns An array of game object data, containing the template UUID, template name, and template stats, sorted by template name.
 */
export function parseRootTemplate(xmlDoc: Document): GameObjectData[] {
    const gameObjectsData: GameObjectData[] = [];
    const gameObjectsNodes = getGameObjectsNodes(xmlDoc);
    gameObjectsNodes.forEach(node => {
        const gameObjectData = parseGameObjectNode(node);
        if (gameObjectData.templateName && gameObjectData.templateUUID) {
            gameObjectsData.push(gameObjectData);
        }
    });
    return sortGameObjectData(gameObjectsData);
}

/**
 * Retrieves the game objects nodes from the given XML document.
 * @param xmlDoc - The XML document to search.
 * @returns An array of game objects nodes.
 */
function getGameObjectsNodes(xmlDoc: Document): Element[] {
    // Select all GameObjects nodes directly under a <children> element. Do not get deeper nodes.
    return Array.from(xmlDoc.querySelectorAll('node[id="GameObjects"]'));
}

/**
 * Parses the game object node and extracts the relevant data.
 * @param node - The game object node to parse.
 * @returns The game object data.
 */
function parseGameObjectNode(node: Element): GameObjectData {
    let templateUUID: string | null = null;
    let templateName: string | null = null;
    let templateStats: string | null = null;
    let isContainer = false;

    // Directly iterate over immediate children of the node that are <attribute> elements
    Array.from(node.children).forEach((child) => {
        // Ensure we are only working with <attribute> elements, and not other types of nodes
        if (child.nodeName.toLowerCase() === 'attribute') {
            const attr = child as Element;
            switch (attr.getAttribute('id')) {
            case 'Name':
                templateName = attr.getAttribute('value') || null;
                break;
            case 'Stats':
                templateStats = attr.getAttribute('value') || null;
                break;
            case 'MapKey':
                templateUUID = attr.getAttribute('value') || null;
                break;
            case 'InventoryType':
                // If InventoryType is found, set isContainer to true
                isContainer = attr.getAttribute('value') != undefined;
                break;
            }
        }
    });

    // NOTE: it might be best to just only use Stats. But then again, some authors might use Name instead, so for now, we'll just use Stats if Name is not found.
    if (!templateName) {
        console.warn(`Template name not found for game object node: ${node.outerHTML}. Defaulting to Stats value of "${templateStats}".`);
        templateName = templateStats || null;
    }

    return { templateUUID, templateName, templateStats, isContainer };
}
