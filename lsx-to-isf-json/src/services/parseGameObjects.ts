/**
 * Represents the data of a game object.
 */
export interface GameObjectData {
  templateUUID: string | null;
  templateName: string | null;
  isContainer: boolean;
}

/**
 * Parses a XML document containing Root Template data (.lsx).
 * @param xmlDoc - The XML document (.lsx) to parse.
 * @returns An array of game object data.
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
  return gameObjectsData;
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

  return { templateUUID, templateName, isContainer };
}
