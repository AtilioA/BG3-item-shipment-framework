import { GameObjectData, parseRootTemplate } from './parseGameObjects';
import { ParsedTreasureTableData, parseTreasureTableData } from './parseTreasureTable';

interface FileAndPath {
    file: File;
    path: string;
}

export interface FilteredLSXData {
    validItems: GameObjectData[];
    filteredItems: GameObjectData[];
}

// Step 1: Gathering data from the dropped folder
export async function gatherData(item: FileSystemEntry, path: string = ''): Promise<FileAndPath[]> {
    const files: { file: File, path: string }[] = [];
    await processEntry(item, path, files);
    return files;
};

async function processEntry(entry: FileSystemEntry, path: string, files: { file: File, path: string }[]) {
    if (entry.isFile) {
        const fileEntry = entry as FileSystemFileEntry;
        const file: File = await new Promise((resolve) => fileEntry.file(resolve));
        files.push({ file, path: `${path}/${fileEntry.name}` });
    } else if (entry.isDirectory) {
        const dirReader = (entry as FileSystemDirectoryEntry).createReader();
        const readEntries: FileSystemEntry[] = await new Promise((resolve, reject) => dirReader.readEntries(resolve, reject));
        for (const childEntry of readEntries) {
            await processEntry(childEntry, `${path}/${childEntry.name}`, files);
        }
    }
}

// Step 2: Parsing LSX file(s?) from RootTemplates
export async function parseLSXFiles(files: FileAndPath[]): Promise<GameObjectData[]> {
    const lsxFiles = files.filter((file) => file.file.name.endsWith('.lsx') && file.path.includes('RootTemplates'));
    console.debug('LSX files: ', lsxFiles);
    const parsedData: GameObjectData[] = [];
    for (const file of lsxFiles) {
        const text = await file.file.text();
        const xmlDoc = new DOMParser().parseFromString(text, 'text/xml');
        const parsed = parseRootTemplate(xmlDoc);
        parsedData.push(...parsed);
    }
    console.debug('Parsed data: ', parsedData);
    return parsedData;
};

// Step 3: Parsing Treasure Table file(s?)
export async function parseTreasureTables(files: FileAndPath[]): Promise<ParsedTreasureTableData[]> {
    const treasureFiles = files.filter((file) => file.file.name.endsWith('TreasureTable.txt') && file.path.includes('Generated'));
    console.debug('Treasure files: ', treasureFiles);
    const treasureData: ParsedTreasureTableData[] = [];
    for (const file of treasureFiles) {
        const text = await file.file.text();
        const parsed = parseTreasureTableData(text);
        treasureData.push(parsed);
    }

    console.debug('Treasure data: ', treasureData);
    return treasureData;
};


// Step 4: Removing items that are already in Treasure Tables
export function removeItemsFromLSX(lsxData: GameObjectData[], treasureData: ParsedTreasureTableData[]): FilteredLSXData {
    const validItems: GameObjectData[] = [];
    const filteredItems: GameObjectData[] = [];

    const allTreasureItems = treasureData.flatMap(data => [...data.validTreasureItems, ...data.filteredTreasureItems]);

    for (const lsxItem of lsxData) {
        if (allTreasureItems.some((treasureItem) => treasureItem.templateName === lsxItem.templateName || treasureItem.templateName === lsxItem.templateStats)) {
            filteredItems.push(lsxItem);
        } else {
            validItems.push(lsxItem);
        }
    }

    return { validItems, filteredItems };
}
