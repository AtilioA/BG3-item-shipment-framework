import { GameObjectData, parseRootTemplate } from "./parseGameObjects";
import { TreasureItem, parseTreasureTableData } from "./parseTreasureTable";

// Step 1: Gathering data from the dropped folder
export async function gatherData(item: FileSystemEntry, path: string = ''): Promise<File[]> {
    let files: File[] = [];
    if (item.isFile) {
        const fileEntry = item as FileSystemFileEntry;
        const file: File = await new Promise((resolve) => fileEntry.file(resolve));
        files.push(file);
    } else if (item.isDirectory) {
        const dirReader = (item as FileSystemDirectoryEntry).createReader();
        let readEntries: FileSystemEntry[] = await new Promise((resolve, reject) => dirReader.readEntries(resolve, reject));
        for (let entry of readEntries) {
            const entryFiles = await gatherData(entry, `${path}/${entry.name}`);
            files = files.concat(entryFiles);
        }
    }

    return files;
};

// Step 2: Parsing LSX file(s?) from RootTemplates
export async function parseLSXFiles(files: File[]): Promise<GameObjectData[]> {
    const lsxFiles = files.filter((file) => file.name.endsWith('.lsx') && file.webkitRelativePath.includes('RootTemplates'));
    console.debug("LSX files: ", lsxFiles);
    const parsedData: GameObjectData[] = [];
    for (let file of lsxFiles) {
        const text = await file.text();
        const xmlDoc = new DOMParser().parseFromString(text, 'text/xml');
        const parsed = parseRootTemplate(xmlDoc);
        parsedData.push(...parsed);
    }
    console.debug("Parsed data: ", parsedData);
    return parsedData;
};

// Step 3: Parsing Treasure Table file(s?)
export async function parseTreasureTables(files: File[]): Promise<TreasureItem[]> {
    const treasureFiles = files.filter((file) => file.name.endsWith('TreasureTable.txt') && file.webkitRelativePath.includes('Generated'));
    console.debug("Treasure files: ", treasureFiles)
    const treasureData: TreasureItem[] = [];
    for (let file of treasureFiles) {
        const text = await file.text();
        const parsed = parseTreasureTableData(text);
        treasureData.push(...parsed);
    }

    console.debug("Treasure data: ", treasureData);
    return treasureData;
};

// Step 4: Removing items that are already in Treasure Tables
export function removeItemsFromLSX(lsxData: GameObjectData[], treasureData: TreasureItem[]): GameObjectData[] {
    return lsxData.filter((lsxItem) => !treasureData.some((treasureItem) => treasureItem.templateName === lsxItem.templateName));
};
