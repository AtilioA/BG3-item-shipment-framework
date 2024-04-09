import { VANILLA_TREASURE_TABLES } from "@/data/vanillaTreasureTables";

export interface TreasureItem {
    treasureName: string;
    templateName: string;
};

export function isVanillaTreasureTable(treasureTable: string): boolean {
    return VANILLA_TREASURE_TABLES[treasureTable] == true;
}

export function parseTreasureTableData(fileContent: string): TreasureItem[] {
    const lines = fileContent.split('\n');
    const treasureItems: TreasureItem[] = [];
    let currentTreasureTable = '';

    lines.forEach(line => {
        // Check if the line denotes a new treasure table
        if (line.startsWith('new treasuretable')) {
            currentTreasureTable = line.split('"')[1]; // Extract the treasure table name
        } else if (line.startsWith('object category') && !isVanillaTreasureTable(currentTreasureTable)) {
            // Extract the first string after 'object category', ignoring 'TUT_Chest_Potions' table
            // console.log(currentTreasureTable)
            const parts = line.split('"');
            if (parts.length >= 2) {
                const treasureName = parts[1];
                const templateName = treasureName.startsWith('I_') ? treasureName.substring(2) : treasureName;
                treasureItems.push({ treasureName, templateName });
            }
        }
    });

    return treasureItems;
}
