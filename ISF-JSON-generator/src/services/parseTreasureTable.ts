import { VANILLA_TREASURE_TABLES } from '@/data/vanillaTreasureTables';

export interface TreasureItem {
    treasureName: string;
    templateName: string;
};

export interface ParsedTreasureTableData {
    validTreasureItems: TreasureItem[];
    filteredTreasureItems: TreasureItem[];
}

export function isVanillaTreasureTable(treasureTable: string): boolean {
    return VANILLA_TREASURE_TABLES[treasureTable] == true;
}

export function parseTreasureTableData(fileContent: string): ParsedTreasureTableData {
    const lines = fileContent.split('\n');
    const validTreasureItems: TreasureItem[] = [];
    const filteredTreasureItems: TreasureItem[] = [];
    let currentTreasureTable = '';

    for (const line of lines) {
        if (line.startsWith('new treasuretable')) {
            currentTreasureTable = line.split('"')[1];
            continue;
        }

        if (!line.startsWith('object category') || isVanillaTreasureTable(currentTreasureTable)) {
            continue;
        }

        const parts = line.split('"');
        if (parts.length < 2) {
            continue;
        }

        const treasureName = parts[1];
        const templateName = treasureName.startsWith('I_') ? treasureName.substring(2) : treasureName;

        if (isVanillaTreasureTable(currentTreasureTable)) {
            filteredTreasureItems.push({ treasureName, templateName });
        } else {
            validTreasureItems.push({ treasureName, templateName });
        }
    }

    return { validTreasureItems, filteredTreasureItems };
}
